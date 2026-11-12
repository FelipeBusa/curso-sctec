-- =============================================================================
-- Construindo o Data Warehouse (Star Schema)
-- =============================================================================
-- Pré-requisito: já ter rodado 01_staging_elt_load.sql (precisa dos dados em
-- staging.*).
--
-- Grão da tabela de fatos (a frase mais importante deste arquivo):
--   "Uma linha representa um item de um pedido vendido em uma determinada
--    data, para um cliente, em uma loja."
--
-- A transformação (o "T" do ELT) acontece AQUI: staging (texto bruto) vira
-- dimensões e fatos tipados, com a duplicata do produto já resolvida e as
-- datas já normalizadas -- tudo em SQL, sem reabrir o Python.
--
-- Rode com:  psql -h localhost -U postgres -d vitrine -f sql/02_dw_star_schema.sql
-- (depois de 01_staging_elt_load.sql, na mesma sessão/pasta)
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS unaccent;

DROP SCHEMA IF EXISTS dw CASCADE;
CREATE SCHEMA dw;

-- -----------------------------------------------------------------------------
-- 1) Criar as dimensões vazias
-- -----------------------------------------------------------------------------
CREATE TABLE dw.dim_tempo (
    sk_tempo    integer PRIMARY KEY,         -- AAAAMMDD, fácil de ler e de filtrar
    data        date    NOT NULL UNIQUE,
    dia         integer NOT NULL,
    mes         integer NOT NULL,
    nome_mes    text    NOT NULL,
    trimestre   integer NOT NULL,
    ano         integer NOT NULL
);

CREATE TABLE dw.dim_produto (
    sk_produto          serial PRIMARY KEY,
    id_produto_origem   integer        NOT NULL UNIQUE,
    nome_produto        text           NOT NULL,
    categoria           text           NOT NULL,   -- STAR: categoria embutida aqui
    marca               text           NOT NULL,
    preco_unitario      numeric(10,2)  NOT NULL,
    custo_unitario      numeric(10,2)  NOT NULL
);

CREATE TABLE dw.dim_cliente (
    sk_cliente          serial PRIMARY KEY,
    id_cliente_origem   integer NOT NULL UNIQUE,
    nome_cliente        text    NOT NULL,
    cidade              text    NOT NULL,
    segmento            text    NOT NULL,
    data_cadastro       date    NOT NULL
);

CREATE TABLE dw.dim_loja (
    sk_loja             serial PRIMARY KEY,
    id_loja_origem      integer NOT NULL UNIQUE,
    nome_loja           text    NOT NULL,
    cidade              text    NOT NULL,
    regiao              text    NOT NULL
);

CREATE TABLE dw.fato_vendas (
    sk_venda            serial PRIMARY KEY,
    id_venda_origem     integer        NOT NULL,
    sk_tempo            integer        NOT NULL REFERENCES dw.dim_tempo(sk_tempo),
    sk_produto          integer        NOT NULL REFERENCES dw.dim_produto(sk_produto),
    sk_cliente          integer        NOT NULL REFERENCES dw.dim_cliente(sk_cliente),
    sk_loja             integer        NOT NULL REFERENCES dw.dim_loja(sk_loja),
    quantidade          integer        NOT NULL,
    valor_unitario      numeric(10,2),             -- aceita NULL: a linha com valor ausente fica visível, não inventada
    desconto             numeric(10,2) NOT NULL DEFAULT 0,
    status_qualidade    text           NOT NULL DEFAULT 'ok'
);

-- -----------------------------------------------------------------------------
-- 2) dim_tempo: gerada, não importada (um calendário não "vem" de lugar nenhum)
-- -----------------------------------------------------------------------------
INSERT INTO dw.dim_tempo (sk_tempo, data, dia, mes, nome_mes, trimestre, ano)
SELECT
    to_char(d, 'YYYYMMDD')::int,
    d,
    extract(day   FROM d)::int,
    extract(month FROM d)::int,
    initcap(to_char(d, 'TMMonth')),
    extract(quarter FROM d)::int,
    extract(year  FROM d)::int
FROM generate_series('2025-01-01'::date, '2025-12-31'::date, interval '1 day') AS d;

-- -----------------------------------------------------------------------------
-- 3) dim_produto: carrega já RESOLVENDO a duplicata (101 / "tenis runner pro ")
--    Mantém a linha de id mais antigo como "canônica" por (nome sem acento,
--    preço). O DISTINCT ON abaixo é a transformação acontecendo.
-- -----------------------------------------------------------------------------
INSERT INTO dw.dim_produto (id_produto_origem, nome_produto, categoria, marca, preco_unitario, custo_unitario)
SELECT DISTINCT ON (lower(unaccent(trim(nome_produto))), preco_unitario::numeric)
    id_produto::int,
    trim(nome_produto),
    categoria,
    marca,
    preco_unitario::numeric,
    custo_unitario::numeric
FROM staging.produtos_raw
ORDER BY lower(unaccent(trim(nome_produto))), preco_unitario::numeric, id_produto::int ASC;

-- Mapa auxiliar: TODO id de origem (inclusive o duplicado) -> sk_produto canônico
CREATE TEMP TABLE map_produto AS
SELECT
    raw.id_produto::int AS id_produto_origem,
    dp.sk_produto
FROM staging.produtos_raw raw
JOIN dw.dim_produto dp
  ON lower(unaccent(trim(raw.nome_produto))) = lower(unaccent(trim(dp.nome_produto)))
 AND raw.preco_unitario::numeric = dp.preco_unitario;

-- -----------------------------------------------------------------------------
-- 4) dim_cliente e dim_loja: carga direta (essas vieram limpas do sistema de origem)
-- -----------------------------------------------------------------------------
INSERT INTO dw.dim_cliente (id_cliente_origem, nome_cliente, cidade, segmento, data_cadastro)
SELECT id_cliente::int, nome_cliente, cidade, segmento, data_cadastro::date
FROM staging.clientes_raw;

INSERT INTO dw.dim_loja (id_loja_origem, nome_loja, cidade, regiao)
SELECT id_loja::int, nome_loja, cidade, regiao
FROM staging.lojas_raw;

-- -----------------------------------------------------------------------------
-- 5) fato_vendas: aqui as datas em 2 formatos viram 1, o produto duplicado é
--    reapontado para o canônico, e o valor ausente é preservado como NULL +
--    sinalizado (nunca inventado).
-- -----------------------------------------------------------------------------
INSERT INTO dw.fato_vendas (id_venda_origem, sk_tempo, sk_produto, sk_cliente, sk_loja,
                            quantidade, valor_unitario, desconto, status_qualidade)
SELECT
    v.id_venda::int,
    to_char(
        CASE
            WHEN v.data_venda ~ '^\d{4}-\d{2}-\d{2}$' THEN v.data_venda::date
            WHEN v.data_venda ~ '^\d{2}/\d{2}/\d{4}$' THEN to_date(v.data_venda, 'DD/MM/YYYY')
        END,
        'YYYYMMDD'
    )::int AS sk_tempo,
    mp.sk_produto,
    dc.sk_cliente,
    dl.sk_loja,
    v.quantidade::int,
    NULLIF(v.valor_unitario, '')::numeric,
    v.desconto::numeric,
    CASE WHEN NULLIF(v.valor_unitario, '') IS NULL THEN 'valor_ausente_revisar' ELSE 'ok' END
FROM staging.vendas_raw v
JOIN map_produto   mp ON mp.id_produto_origem = v.id_produto::int
JOIN dw.dim_cliente dc ON dc.id_cliente_origem = v.id_cliente::int
JOIN dw.dim_loja    dl ON dl.id_loja_origem    = v.id_loja::int;

-- -----------------------------------------------------------------------------
-- 6) Conferência dos resultados
-- -----------------------------------------------------------------------------
SELECT 'dim_tempo'   AS tabela, count(*) FROM dw.dim_tempo
UNION ALL SELECT 'dim_produto', count(*) FROM dw.dim_produto
UNION ALL SELECT 'dim_cliente', count(*) FROM dw.dim_cliente
UNION ALL SELECT 'dim_loja',    count(*) FROM dw.dim_loja
UNION ALL SELECT 'fato_vendas', count(*) FROM dw.fato_vendas;

-- confirme que as 2 linhas que citavam o produto duplicado (101 e 118) agora
-- apontam para o MESMO sk_produto:
SELECT DISTINCT f.sk_produto, p.nome_produto
FROM dw.fato_vendas f JOIN dw.dim_produto p ON p.sk_produto = f.sk_produto
WHERE p.id_produto_origem = 101;

-- confirme a linha com valor ausente, agora sinalizada (não inventada):
SELECT * FROM dw.fato_vendas WHERE status_qualidade = 'valor_ausente_revisar';

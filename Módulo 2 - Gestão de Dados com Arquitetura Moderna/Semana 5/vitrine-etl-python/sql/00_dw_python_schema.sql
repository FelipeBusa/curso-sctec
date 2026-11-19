-- =============================================================================
-- Schema dw_python: onde o pipeline_etl.py (Parte 1) carrega os dados
-- =============================================================================
-- Pré-requisito: já ter rodado o pipeline da Semana 4 (pasta vitrine-dw/),
-- porque staging.vendas_raw precisa existir para a Parte 2 (carga
-- incremental). Rode a partir da raiz deste projeto (vitrine-etl-python/):
--   psql -h localhost -U postgres -d vitrine -f sql/00_dw_python_schema.sql
--
-- Por que criar as tabelas aqui em SQL, em vez de deixar o to_sql() do
-- Pandas criá-las sozinho (if_exists="replace")? Porque dessa forma sk_produto
-- e sk_cliente já nascem com UNIQUE em id_produto/id_cliente -- exatamente o
-- que o SCD Tipo 1 (ON CONFLICT, Parte 2) precisa para funcionar. O índice do
-- DataFrame no Python só preenche sk_produto/sk_cliente; quem garante a
-- integridade é o banco.
-- =============================================================================

DROP SCHEMA IF EXISTS dw_python CASCADE;
CREATE SCHEMA dw_python;

CREATE TABLE dw_python.dim_produto (
    sk_produto      integer PRIMARY KEY,        -- vem do índice do DataFrame (ver pipeline_etl.py)
    id_produto      integer NOT NULL UNIQUE,    -- já o id CANÔNICO (101, nunca 118)
    nome_produto    text    NOT NULL,
    categoria       text    NOT NULL
);

CREATE TABLE dw_python.dim_cliente (
    sk_cliente      integer PRIMARY KEY,
    id_cliente      integer NOT NULL UNIQUE,
    nome_cliente    text    NOT NULL,
    cidade          text    NOT NULL,
    segmento        text    NOT NULL
);

CREATE TABLE dw_python.fato_vendas (
    sk_venda            serial PRIMARY KEY,
    sk_produto          integer       NOT NULL REFERENCES dw_python.dim_produto(sk_produto),
    sk_cliente          integer       NOT NULL REFERENCES dw_python.dim_cliente(sk_cliente),
    data_venda          date          NOT NULL,
    quantidade          integer       NOT NULL,
    valor_unitario      numeric(10,2),                      -- aceita NULL (venda 38)
    receita             numeric(10,2),
    status_qualidade    text          NOT NULL DEFAULT 'ok'
);

-- Controle da carga incremental (Parte 2): guarda, por pipeline, a última
-- vez que ele rodou com sucesso.
CREATE TABLE dw_python.controle_etl (
    nome_pipeline   varchar(100) PRIMARY KEY,
    ultima_carga    timestamp NOT NULL
);
INSERT INTO dw_python.controle_etl (nome_pipeline, ultima_carga)
VALUES ('etl_vendas_vitrine', '1900-01-01');

-- dim_produto versionada (SCD Tipo 2, Parte 2): cada linha é uma versão de
-- um produto, válida entre data_inicio e data_fim.
CREATE TABLE dw_python.dim_produto_scd2 (
    sk_produto      serial PRIMARY KEY,
    id_produto      integer      NOT NULL,
    nome_produto    varchar(150) NOT NULL,
    categoria       varchar(100) NOT NULL,
    data_inicio     date         NOT NULL,
    data_fim        date,
    registro_atual  boolean      NOT NULL DEFAULT true
);

-- -----------------------------------------------------------------------------
-- staging.vendas_raw precisa de uma coluna updated_at para a carga
-- incremental (Parte 2) saber o que mudou desde a última vez. A Semana 4 não
-- precisou dela (sempre fazia Full Load); hoje ela entra em cena.
-- -----------------------------------------------------------------------------
ALTER TABLE staging.vendas_raw ADD COLUMN IF NOT EXISTS updated_at timestamp;
UPDATE staging.vendas_raw SET updated_at = '2026-01-01 00:00:00' WHERE updated_at IS NULL;

SELECT 'dw_python.dim_produto'      AS tabela, count(*) FROM dw_python.dim_produto
UNION ALL SELECT 'dw_python.dim_cliente',      count(*) FROM dw_python.dim_cliente
UNION ALL SELECT 'dw_python.fato_vendas',      count(*) FROM dw_python.fato_vendas
UNION ALL SELECT 'dw_python.controle_etl',     count(*) FROM dw_python.controle_etl
UNION ALL SELECT 'dw_python.dim_produto_scd2', count(*) FROM dw_python.dim_produto_scd2;

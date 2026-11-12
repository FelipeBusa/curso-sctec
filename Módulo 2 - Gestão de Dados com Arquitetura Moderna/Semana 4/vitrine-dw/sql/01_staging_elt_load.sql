-- =============================================================================
-- Staging / ELT -- carregar antes de transformar (a metade "L" do ELT)
-- =============================================================================
-- Carrega os arquivos BRUTOS de raw/ exatamente como estão (sem corrigir nada
-- ainda) em tabelas de staging com colunas em TEXTO. É o "L" (Load) do ELT.
-- A transformação (o "T") acontece depois, em SQL, no arquivo
-- 02_dw_star_schema.sql: aqui ainda não existe nenhuma coluna numérica nem
-- data de verdade, é tudo texto.
--
-- IMPORTANTE: rode a partir da RAIZ do projeto (pasta vitrine-dw/), porque os
-- caminhos dos arquivos abaixo são relativos a ela:
--   cd vitrine-dw
--   psql -h localhost -U postgres -d vitrine -f sql/01_staging_elt_load.sql
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS unaccent;

DROP SCHEMA IF EXISTS staging CASCADE;
CREATE SCHEMA staging;

-- -----------------------------------------------------------------------------
-- Tabelas de staging: tudo como TEXTO, de propósito. Isto é o "raw" dentro do
-- banco -- ninguém tentou adivinhar tipo de dado ainda.
-- -----------------------------------------------------------------------------
CREATE TABLE staging.lojas_raw (
    id_loja     text,
    nome_loja   text,
    cidade      text,
    regiao      text
);

CREATE TABLE staging.produtos_raw (
    id_produto      text,
    nome_produto    text,
    categoria       text,
    marca           text,
    preco_unitario  text,
    custo_unitario  text
);

CREATE TABLE staging.clientes_raw (
    id_cliente      text,
    nome_cliente    text,
    cidade          text,
    segmento        text,
    data_cadastro   text
);

CREATE TABLE staging.vendas_raw (
    id_venda        text,
    data_venda      text,
    id_cliente      text,
    id_produto      text,
    id_loja         text,
    quantidade      text,
    valor_unitario  text,
    desconto        text
);

-- JSON semiestruturado: guardamos o arquivo inteiro como 1 linha jsonb e só
-- "abrimos" ele depois, em SQL (jsonb_array_elements). É assim que se lida
-- com dado que "não chega como tabela pronta".
CREATE TABLE staging.pagamentos_raw (
    payload jsonb
);

-- -----------------------------------------------------------------------------
-- Carga (COPY): os arquivos CSV entram linha a linha, sem transformação.
-- -----------------------------------------------------------------------------
\copy staging.lojas_raw     FROM 'raw/lojas.csv'     WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');
\copy staging.produtos_raw  FROM 'raw/produtos.csv'  WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');
\copy staging.clientes_raw  FROM 'raw/clientes.csv'  WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');
\copy staging.vendas_raw    FROM 'raw/vendas.csv'    WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');


-- O JSON entra inteiro como um único documento (truque de demonstração: lê o
-- arquivo via shell e injeta como jsonb). Em uma arquitetura real, isso seria
-- feito por um conector/ingestão (Fivetran, Airbyte, um job Python, etc.).
-- (substituido: carga feita por sql/01b_pagamentos_insert.sql, mais robusto no Windows)
-- \set payload `type raw/pagamentos.json`
-- INSERT INTO staging.pagamentos_raw (payload) VALUES (:'payload'::jsonb);
\i sql/01b_pagamentos_insert.sql

----------------------------------------------
-- Consulta
SELECT COUNT(*) AS total_vendas
FROM staging.vendas_raw;


-- -----------------------------------------------------------------------------
-- Chegou tudo, mas ainda está "sujo":
-- -----------------------------------------------------------------------------
SELECT 'lojas_raw'     AS tabela, count(*) AS linhas FROM staging.lojas_raw
UNION ALL SELECT 'produtos_raw',  count(*) FROM staging.produtos_raw
UNION ALL SELECT 'clientes_raw',  count(*) FROM staging.clientes_raw
UNION ALL SELECT 'vendas_raw',    count(*) FROM staging.vendas_raw
UNION ALL SELECT 'pagamentos_raw (docs)', count(*) FROM staging.pagamentos_raw;

-- 2 formatos de data convivendo na mesma coluna de texto:
SELECT DISTINCT
    CASE WHEN data_venda ~ '^\d{4}-\d{2}-\d{2}$' THEN 'ISO (AAAA-MM-DD)'
         WHEN data_venda ~ '^\d{2}/\d{2}/\d{4}$' THEN 'BR (DD/MM/AAAA)'
         ELSE 'outro' END AS formato_de_data,
    count(*) AS ocorrencias
FROM staging.vendas_raw
GROUP BY 1;

-- A linha com valor_unitario ausente:
SELECT * FROM staging.vendas_raw WHERE valor_unitario = '' OR valor_unitario IS NULL;

-- O produto duplicado (mesmo nome/preço, grafias diferentes):
SELECT id_produto, nome_produto, preco_unitario
FROM staging.produtos_raw
WHERE lower(unaccent(trim(nome_produto))) IN (
    SELECT lower(unaccent(trim(nome_produto)))
    FROM staging.produtos_raw
    GROUP BY lower(unaccent(trim(nome_produto)))
    HAVING count(*) > 1
)
ORDER BY nome_produto;

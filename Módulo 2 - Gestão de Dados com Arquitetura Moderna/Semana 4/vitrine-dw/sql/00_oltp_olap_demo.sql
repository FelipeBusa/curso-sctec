-- =============================================================================
-- OLTP x OLAP — por que existem diferentes arquiteturas de processamento?
-- =============================================================================
-- Demonstração isolada e rápida, em um schema próprio que não interfere no
-- Data Warehouse construído nos arquivos seguintes. A pergunta que o exemplo
-- responde:
--   "Se o caixa precisa registrar uma venda agora, ele deveria esperar uma
--    consulta que analisa 10 milhões de vendas?"
--
-- Rode com:  psql -h localhost -U postgres -d vitrine -f sql/00_oltp_olap_demo.sql
-- =============================================================================
CREATE DATABASE vitrine;

DROP SCHEMA IF EXISTS oltp_demo CASCADE;
CREATE SCHEMA oltp_demo;

-- -----------------------------------------------------------------------------
-- Mundo OLTP: uma tabela de estoque simples, como a de um sistema de caixa.
-- -----------------------------------------------------------------------------
CREATE TABLE oltp_demo.estoque (
    id_produto  integer PRIMARY KEY,
    produto     text    NOT NULL,
    quantidade  integer NOT NULL
);

INSERT INTO oltp_demo.estoque (id_produto, produto, quantidade) VALUES
    (101, 'Tênis Runner Pro',   48),
    (106, 'Camiseta Dry Fit',  120),
    (114, 'Smartwatch Fit X',   30);

-- CONSULTA TRANSACIONAL (OLTP)
-- Objetivo: registrar UMA operação individual, com rapidez e consistência.
-- É exatamente o que acontece quando o caixa confirma uma venda.
UPDATE oltp_demo.estoque
SET quantidade = quantidade - 1
WHERE id_produto = 101;

SELECT * FROM oltp_demo.estoque ORDER BY id_produto;   -- o reflexo imediato do UPDATE

-- -----------------------------------------------------------------------------
-- Mundo OLAP: a mesma loja, agora com várias vendas já registradas.
-- -----------------------------------------------------------------------------
CREATE TABLE oltp_demo.vendas (
    produto     text           NOT NULL,
    valor_total numeric(10,2)  NOT NULL
);

INSERT INTO oltp_demo.vendas (produto, valor_total) VALUES
    ('Tênis Runner Pro', 399.90), ('Tênis Runner Pro', 399.90), ('Tênis Runner Pro', 799.80),
    ('Camiseta Dry Fit',  99.90), ('Camiseta Dry Fit', 199.80),
    ('Smartwatch Fit X', 899.90), ('Smartwatch Fit X', 1799.80), ('Smartwatch Fit X', 899.90);

-- CONSULTA ANALÍTICA (OLAP)
-- Objetivo: agregar MUITAS vendas para apoiar uma decisão de negócio.
SELECT
    produto,
    SUM(valor_total) AS faturamento
FROM oltp_demo.vendas
GROUP BY produto
ORDER BY faturamento DESC;

-- OLTP e OLAP são tipos de PROCESSAMENTO. Data Warehouse e Data Lake são
-- abordagens de ARMAZENAMENTO/ORGANIZAÇÃO. Eles convivem na mesma
-- arquitetura -- é o que os próximos arquivos (01 a 04) vão construir de
-- verdade.

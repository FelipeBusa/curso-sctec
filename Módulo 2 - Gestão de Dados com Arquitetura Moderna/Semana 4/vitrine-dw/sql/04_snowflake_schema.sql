-- =============================================================================
-- Star Schema x Snowflake Schema
-- =============================================================================
-- Parte do Star Schema já construído (02_dw_star_schema.sql), separa
-- "categoria" para fora de dim_produto e compara a MESMA pergunta de
-- negócio nos dois modelos. Pré-requisito: 02_dw_star_schema.sql já rodado.
--
-- Rode com:  psql -h localhost -U postgres -d vitrine -f sql/04_snowflake_schema.sql
-- =============================================================================

DROP SCHEMA IF EXISTS dw_snowflake CASCADE;
CREATE SCHEMA dw_snowflake;

-- -----------------------------------------------------------------------------
-- 1) Nova dimensão: dim_categoria (a normalização que caracteriza o snowflake)
-- -----------------------------------------------------------------------------
CREATE TABLE dw_snowflake.dim_categoria (
    sk_categoria    serial PRIMARY KEY,
    nome_categoria  text NOT NULL UNIQUE
);

INSERT INTO dw_snowflake.dim_categoria (nome_categoria)
SELECT DISTINCT categoria FROM dw.dim_produto ORDER BY 1;

-- -----------------------------------------------------------------------------
-- 2) dim_produto SEM a categoria embutida -- agora só uma chave estrangeira.
--    Mantém o MESMO sk_produto da star (inserido explicitamente, sem gerar
--    um novo), para a tabela de fatos poder ser reaproveitada sem duplicar.
-- -----------------------------------------------------------------------------
CREATE TABLE dw_snowflake.dim_produto (
    sk_produto          integer PRIMARY KEY,
    id_produto_origem   integer        NOT NULL UNIQUE,
    nome_produto        text           NOT NULL,
    marca               text           NOT NULL,
    preco_unitario      numeric(10,2)  NOT NULL,
    custo_unitario      numeric(10,2)  NOT NULL,
    sk_categoria        integer        NOT NULL REFERENCES dw_snowflake.dim_categoria(sk_categoria)
);

INSERT INTO dw_snowflake.dim_produto
    (sk_produto, id_produto_origem, nome_produto, marca, preco_unitario, custo_unitario, sk_categoria)
SELECT
    dp.sk_produto, dp.id_produto_origem, dp.nome_produto, dp.marca, dp.preco_unitario, dp.custo_unitario,
    dc.sk_categoria
FROM dw.dim_produto dp
JOIN dw_snowflake.dim_categoria dc ON dc.nome_categoria = dp.categoria;

-- -----------------------------------------------------------------------------
-- 3) fato_vendas: não precisa ser recriada. sk_produto é idêntico nos dois
--    modelos, então uma VIEW basta para "ligar" o snowflake à mesma fato.
-- -----------------------------------------------------------------------------
CREATE VIEW dw_snowflake.fato_vendas AS SELECT * FROM dw.fato_vendas;

-- -----------------------------------------------------------------------------
-- 4) Comparação: a MESMA pergunta ("faturamento por categoria"), 2 modelos.
-- -----------------------------------------------------------------------------

-- STAR -- 1 JOIN
SELECT
    p.categoria,
    SUM(f.quantidade * COALESCE(f.valor_unitario, 0) - f.desconto) AS faturamento
FROM dw.fato_vendas f
JOIN dw.dim_produto p ON f.sk_produto = p.sk_produto
GROUP BY p.categoria
ORDER BY faturamento DESC;

-- SNOWFLAKE -- 2 JOINs para a mesma resposta
SELECT
    c.nome_categoria,
    SUM(f.quantidade * COALESCE(f.valor_unitario, 0) - f.desconto) AS faturamento
FROM dw_snowflake.fato_vendas f
JOIN dw_snowflake.dim_produto  p ON f.sk_produto  = p.sk_produto
JOIN dw_snowflake.dim_categoria c ON p.sk_categoria = c.sk_categoria
GROUP BY c.nome_categoria
ORDER BY faturamento DESC;

-- O RESULTADO é idêntico nos dois -- o que muda é a estrutura e o número de
-- JOINs. Star = menos joins, mais simples de consumir. Snowflake = mais
-- normalizado, menos redundância (o nome da categoria existe 1 vez só, em
-- vez de repetido em toda linha de produto). Nenhum dos dois é
-- universalmente melhor.

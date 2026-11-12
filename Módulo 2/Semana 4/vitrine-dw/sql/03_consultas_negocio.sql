-- =============================================================================
-- Consultas de negócio sobre o Star Schema
-- =============================================================================
-- O mesmo modelo responde a perguntas diferentes só mudando o agrupamento --
-- é a ideia central deste arquivo. As 3 primeiras consultas são genéricas;
-- o desafio final usa o mesmo modelo para responder a uma pergunta mais
-- específica: por que faturar mais não significa lucrar mais.
--
-- Rode com:  psql -h localhost -U postgres -d vitrine -f sql/03_consultas_negocio.sql
-- (depois de 02_dw_star_schema.sql)
-- =============================================================================

import pandas as pd
from psycopg2.extras import execute_values
from PostgreSQL.banco import conectar


-- -----------------------------------------------------------------------------
-- 1) Faturamento por mês
-- -----------------------------------------------------------------------------
SELECT
    t.ano,
    t.mes,
    t.nome_mes,
    SUM(f.quantidade * COALESCE(f.valor_unitario, 0) - f.desconto) AS faturamento
FROM dw.fato_vendas f
JOIN dw.dim_tempo t ON f.sk_tempo = t.sk_tempo
GROUP BY t.ano, t.mes, t.nome_mes
ORDER BY t.ano, t.mes;

-- -----------------------------------------------------------------------------
-- 2) Os 5 produtos mais vendidos (por faturamento)
-- -----------------------------------------------------------------------------
SELECT
    p.nome_produto,
    p.categoria,
    SUM(f.quantidade) AS unidades_vendidas,
    SUM(f.quantidade * COALESCE(f.valor_unitario, 0) - f.desconto) AS faturamento
FROM dw.fato_vendas f
JOIN dw.dim_produto p ON f.sk_produto = p.sk_produto
GROUP BY p.nome_produto, p.categoria
ORDER BY faturamento DESC
LIMIT 5;

-- -----------------------------------------------------------------------------
-- 3) Clientes com maior valor total de compras
-- -----------------------------------------------------------------------------
SELECT
    c.nome_cliente,
    c.segmento,
    COUNT(*) AS numero_pedidos,
    SUM(f.quantidade * COALESCE(f.valor_unitario, 0) - f.desconto) AS valor_total
FROM dw.fato_vendas f
JOIN dw.dim_cliente c ON f.sk_cliente = c.sk_cliente
GROUP BY c.nome_cliente, c.segmento
ORDER BY valor_total DESC
LIMIT 10;

-- "novo" compra pouco mas aparece bastante? "recorrente" domina o topo?
-- Compare os segmentos antes de seguir para o desafio abaixo.

-- -----------------------------------------------------------------------------
-- Desafio: "a loja está vendendo mais, mas lucrando menos?"
-- -----------------------------------------------------------------------------

-- 4) Qual categoria vendeu mais UNIDADES? (não é a mesma coisa que faturamento)
SELECT
    p.categoria,
    SUM(f.quantidade) AS unidades_vendidas
FROM dw.fato_vendas f
JOIN dw.dim_produto p ON f.sk_produto = p.sk_produto
GROUP BY p.categoria
ORDER BY unidades_vendidas DESC;

-- -----------------------------------------------------------------------------
-- 5) Por que faturamento maior não significa lucro maior?
-- A resposta só é possível porque dim_produto guarda custo_unitario -- se o
-- modelo não tivesse esse atributo, essa pergunta de negócio não teria como
-- ser respondida. É o exemplo de que a modelagem tem que nascer da pergunta
-- de negócio, não o contrário.
-- -----------------------------------------------------------------------------
SELECT
    p.categoria,
    SUM(f.quantidade * COALESCE(f.valor_unitario, 0) - f.desconto)        AS faturamento,
    SUM(f.quantidade * p.custo_unitario)                                  AS custo_total,
    SUM(f.quantidade * COALESCE(f.valor_unitario, 0) - f.desconto)
        - SUM(f.quantidade * p.custo_unitario)                            AS lucro_bruto,
    ROUND(
        100.0 * (
            SUM(f.quantidade * COALESCE(f.valor_unitario, 0) - f.desconto)
            - SUM(f.quantidade * p.custo_unitario)
        ) / NULLIF(SUM(f.quantidade * COALESCE(f.valor_unitario, 0) - f.desconto), 0)
    , 1) AS margem_pct
FROM dw.fato_vendas f
JOIN dw.dim_produto p ON f.sk_produto = p.sk_produto
GROUP BY p.categoria
ORDER BY faturamento DESC;

-- A categoria com MAIOR faturamento costuma ser Eletrônicos (puxada por
-- volume de unidades), mas é também a de MENOR margem -- o custo_unitario
-- dela foi desenhado propositalmente perto do preço de venda. Faturamento
-- alto e lucro alto não são a mesma pergunta, e só dá pra responder a
-- segunda porque o modelo guardou o custo desde o início.

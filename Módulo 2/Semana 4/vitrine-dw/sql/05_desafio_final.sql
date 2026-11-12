-- =============================================================================
-- BLOCO 6 — Desafio final: "a loja está vendendo mais, mas lucrando menos?"
-- =============================================================================
-- Mostre as 4 perguntas na tela, rode uma consulta por vez, revele o
-- resultado aos poucos. Pré-requisito: 02_dw_star_schema.sql já rodado.
--
-- Rode com:  psql -h localhost -U postgres -d vitrine -f sql/05_desafio_final.sql
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Pergunta 1: Qual mês teve o maior faturamento?
-- -----------------------------------------------------------------------------
SELECT
    t.ano, t.mes, t.nome_mes,
    SUM(f.quantidade * COALESCE(f.valor_unitario, 0) - f.desconto) AS faturamento
FROM dw.fato_vendas f
JOIN dw.dim_tempo t ON f.sk_tempo = t.sk_tempo
GROUP BY t.ano, t.mes, t.nome_mes
ORDER BY faturamento DESC
LIMIT 1;

-- -----------------------------------------------------------------------------
-- Pergunta 2: Qual categoria vendeu mais UNIDADES? (não é a mesma coisa que
-- faturamento -- vale frisar isso em tela)
-- -----------------------------------------------------------------------------
SELECT
    p.categoria,
    SUM(f.quantidade) AS unidades_vendidas
FROM dw.fato_vendas f
JOIN dw.dim_produto p ON f.sk_produto = p.sk_produto
GROUP BY p.categoria
ORDER BY unidades_vendidas DESC;

-- -----------------------------------------------------------------------------
-- Pergunta 3: Quais clientes mais compraram?
-- -----------------------------------------------------------------------------
SELECT
    c.nome_cliente, c.segmento,
    SUM(f.quantidade * COALESCE(f.valor_unitario, 0) - f.desconto) AS valor_total
FROM dw.fato_vendas f
JOIN dw.dim_cliente c ON f.sk_cliente = c.sk_cliente
GROUP BY c.nome_cliente, c.segmento
ORDER BY valor_total DESC
LIMIT 5;

-- -----------------------------------------------------------------------------
-- Pergunta 4: Por que faturamento maior não significa lucro maior?
-- A resposta só é possível porque dim_produto guarda custo_unitario -- se o
-- modelo não tivesse esse atributo, essa pergunta de negócio não teria
-- como ser respondida. É o gancho para falar de modelagem ter que nascer
-- da pergunta de negócio, não o contrário.
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

-- Revele por último: a categoria com MAIOR faturamento costuma ser
-- Eletrônicos (puxada por volume de unidades), mas é também a de MENOR
-- margem -- o custo_unitario dela foi desenhado propositalmente perto do
-- preço de venda. É a virada de roteiro do bloco: faturamento alto e lucro
-- alto não são a mesma pergunta, e só dá pra responder a segunda porque o
-- modelo guardou o custo desde o início.

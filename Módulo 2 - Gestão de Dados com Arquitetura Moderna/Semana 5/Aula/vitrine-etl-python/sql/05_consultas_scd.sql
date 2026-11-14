-- =============================================================================
-- SCD Tipo 1 x Tipo 2: a mesma pergunta, respostas diferentes
-- =============================================================================
-- Pergunta: qual categoria aparece numa venda do Smartwatch Fit X em
-- 15/03/2026 (a venda nova de sql/02_simular_mudancas.sql)?
-- Rode com:
--   psql -h localhost -U postgres -d vitrine -f sql/05_consultas_scd.sql
-- =============================================================================

-- 1) SCD Tipo 1 (dim_produto comum, sem histórico): ERRADO. A dimensão só
--    guarda a categoria ATUAL (Wearables), mesmo para uma venda de março,
--    antes da mudança.
SELECT dp.categoria AS categoria_segundo_tipo1
FROM dw_python.fato_vendas f
JOIN dw_python.dim_produto dp ON dp.sk_produto = f.sk_produto
WHERE f.data_venda = '2026-03-15';

-- 2) SCD Tipo 2 (dim_produto_scd2, com histórico): CORRETO. Filtra a versão
--    vigente NA DATA da venda, não a de hoje.
SELECT scd.categoria AS categoria_segundo_tipo2
FROM dw_python.dim_produto_scd2 scd
WHERE scd.id_produto = 114
  AND DATE '2026-03-15' >= scd.data_inicio
  AND (scd.data_fim IS NULL OR DATE '2026-03-15' < scd.data_fim);

-- 3) A mesma consulta (2), só que genérica: versão vigente de QUALQUER
--    produto em QUALQUER data -- é o padrão que toda consulta de negócio
--    sobre dim_produto_scd2 vai usar.
SELECT *
FROM dw_python.dim_produto_scd2
WHERE id_produto = 114
  AND DATE '2026-03-15' >= data_inicio
  AND (data_fim IS NULL OR DATE '2026-03-15' < data_fim);

-- 4) Quantos clientes mudaram de cidade nos últimos 6 meses? (SCD Tipo 1 não
--    guarda a data da mudança -- é uma limitação dele; aqui só confirmamos
--    que a Laura está com a cidade nova)
SELECT id_cliente, nome_cliente, cidade
FROM dw_python.dim_cliente
WHERE id_cliente = 37;

-- 5) O pipeline consegue rodar de novo sem duplicar nada? Com if_exists=
--    "append" no Pandas, NÃO -- rodar pipeline_etl.py 2x duplica fato_vendas
--    inteiro. É exatamente por isso que a Parte 2 usa carga incremental
--    (scripts/05_carga_incremental.py) em vez de reexecutar o pipeline todo.

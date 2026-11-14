-- =============================================================================
-- SCD Tipo 2: nova versão, histórico preservado
-- =============================================================================
-- O Smartwatch Fit X (id_produto 114) migrou de Eletrônicos para Wearables
-- em 15/06/2026. A Vitrine quer comparar margem por categoria ao longo do
-- tempo -- ou seja, precisa saber que, ANTES dessa data, ele era
-- Eletrônicos. UPDATE fecha a versão antiga, INSERT cria a nova, tudo numa
-- transação só.
--
-- Rode só quando o valor realmente mudar (senão duplica versões iguais).
-- Rode com:
--   psql -h localhost -U postgres -d vitrine -f sql/04_scd_tipo2_produto.sql
-- =============================================================================

BEGIN;

UPDATE dw_python.dim_produto_scd2
SET data_fim = DATE '2026-06-15', registro_atual = FALSE
WHERE id_produto = 114 AND registro_atual = TRUE;

INSERT INTO dw_python.dim_produto_scd2 (
    id_produto, nome_produto, categoria, data_inicio, data_fim, registro_atual
) VALUES (
    114, 'Smartwatch Fit X', 'Wearables', DATE '2026-06-15', NULL, TRUE
);

COMMIT;

-- As duas versões, lado a lado:
SELECT sk_produto, id_produto, categoria, data_inicio, data_fim, registro_atual
FROM dw_python.dim_produto_scd2
WHERE id_produto = 114
ORDER BY data_inicio;

-- Só para efeito de COMPARAÇÃO em sql/05_consultas_scd.sql: simula o que
-- aconteceria se a Vitrine só tivesse a dim_produto comum (Tipo 1, sem
-- histórico) -- ela aplicaria o mesmo UPSERT que fizemos para a cliente em
-- sql/03_scd_tipo1_cliente.sql, sobrescrevendo a categoria para TODAS as
-- vendas desse produto, inclusive as antigas:
UPDATE dw_python.dim_produto
SET categoria = 'Wearables'
WHERE id_produto = 114;

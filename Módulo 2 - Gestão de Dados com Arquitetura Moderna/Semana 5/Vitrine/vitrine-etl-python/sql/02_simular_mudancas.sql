-- =============================================================================
-- "Seis meses depois": simula os dois eventos do slide 33 + 1 venda nova,
-- para a aula ter algo real para resolver com SCD e carga incremental.
-- =============================================================================
-- Evento 1: a Laura Macedo (id_cliente 37, nossa melhor cliente) mudou de
--           Belo Horizonte para Florianópolis.
-- Evento 2: o Smartwatch Fit X (id_produto 114) foi reclassificado de
--           Eletrônicos para Wearables, em 15/06/2026.
-- Evento 3: uma venda nova do Smartwatch Fit X em 15/03/2026 (ANTES da
--           reclassificação) entra em staging.vendas_raw com updated_at =
--           agora -- é o registro que a carga incremental vai pegar, e
--           também a venda que prova por que SCD Tipo 2 importa (ver
--           sql/04_consultas_scd.sql).
--
-- Rode com:
--   psql -h localhost -U postgres -d vitrine -f sql/02_simular_mudancas.sql
-- =============================================================================

-- Marca que a carga cheia da Parte 1 (pipeline_etl.py, 820 vendas) já
-- rodou -- a partir de agora, só o que mudar DEPOIS deste instante entra
-- pela carga incremental (scripts/05_carga_incremental.py). Sem isso, a
-- carga incremental reprocessaria as 820 vendas antigas também (seu
-- updated_at, de sql/00_dw_python_schema.sql, é 2026-01-01, bem depois do
-- valor inicial '1900-01-01' de controle_etl).
UPDATE dw_python.controle_etl
SET ultima_carga = '2026-01-02 00:00:00'
WHERE nome_pipeline = 'etl_vendas_vitrine';

-- Evento 3 primeiro, para já existir id_venda novo antes de qualquer coisa:
INSERT INTO staging.vendas_raw (id_venda, data_venda, id_cliente, id_produto, id_loja, quantidade, valor_unitario, desconto, updated_at)
SELECT
    (SELECT max(id_venda::int) FROM staging.vendas_raw) + 1,
    '2026-03-15',
    '37',     -- Laura Macedo
    '114',    -- Smartwatch Fit X
    '1',
    '1',
    '899.90',
    '0',
    now();

-- Evento 1: SCD Tipo 1 -- ver também sql/03_scd_tipo1_cliente.sql (o UPSERT
-- comentado passo a passo). Aqui é só o fato de origem mudando no cadastro:
UPDATE staging.clientes_raw
SET cidade = 'Florianópolis'
WHERE id_cliente = '37';

SELECT 'venda nova inserida' AS evento, count(*) FROM staging.vendas_raw WHERE id_cliente = '37' AND id_produto = '114' AND data_venda = '2026-03-15'
UNION ALL
SELECT 'cliente 37 cidade atual', 1 FROM staging.clientes_raw WHERE id_cliente = '37' AND cidade = 'Florianópolis';

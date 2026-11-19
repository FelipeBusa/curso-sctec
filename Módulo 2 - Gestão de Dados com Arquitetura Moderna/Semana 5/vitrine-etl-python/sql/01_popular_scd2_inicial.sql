-- =============================================================================
-- Carga inicial da dim_produto_scd2: 1 versão "vigente desde o início" para
-- cada produto (igual à dim_produto comum, só que agora com data_inicio e
-- data_fim). É o ponto de partida antes de qualquer mudança de categoria.
-- =============================================================================
-- Pré-requisito: sql/00_dw_python_schema.sql já rodado.
-- Rode com:
--   psql -h localhost -U postgres -d vitrine -f sql/01_popular_scd2_inicial.sql
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS unaccent;

INSERT INTO dw_python.dim_produto_scd2 (id_produto, nome_produto, categoria, data_inicio, data_fim, registro_atual)
SELECT DISTINCT ON (lower(unaccent(trim(nome_produto))), preco_unitario::numeric)
    id_produto::int,
    trim(nome_produto),
    categoria,
    DATE '2025-01-01',  -- início do histórico de vendas da Vitrine
    NULL,
    true
FROM staging.produtos_raw
ORDER BY lower(unaccent(trim(nome_produto))), preco_unitario::numeric, id_produto::int ASC;

SELECT * FROM dw_python.dim_produto_scd2 ORDER BY id_produto;

-- =============================================================================
-- SCD Tipo 1: sobrescrever o valor antigo
-- =============================================================================
-- A Laura Macedo (id_cliente 37) mudou de Belo Horizonte para Florianópolis
-- (ver sql/02_simular_mudancas.sql). Como é uma correção de cadastro -- não
-- importa onde ela morava quando comprou no passado -- a dimensão apenas
-- sobrescreve o valor antigo. Isso é SCD Tipo 1.
--
-- O INSERT ... ON CONFLICT só funciona porque id_cliente tem UNIQUE em
-- dw_python.dim_cliente (ver sql/00_dw_python_schema.sql).
--
-- Rode com:
--   psql -h localhost -U postgres -d vitrine -f sql/03_scd_tipo1_cliente.sql
-- =============================================================================

-- ANTES:
SELECT sk_cliente, id_cliente, nome_cliente, cidade FROM dw_python.dim_cliente WHERE id_cliente = 37;

INSERT INTO dw_python.dim_cliente (sk_cliente, id_cliente, nome_cliente, cidade, segmento)
SELECT sk_cliente, id_cliente, nome_cliente, 'Florianópolis', segmento
FROM dw_python.dim_cliente
WHERE id_cliente = 37
ON CONFLICT (id_cliente)
DO UPDATE SET cidade = EXCLUDED.cidade;

-- DEPOIS: mesma sk_cliente, cidade sobrescrita -- sem histórico.
SELECT sk_cliente, id_cliente, nome_cliente, cidade FROM dw_python.dim_cliente WHERE id_cliente = 37;

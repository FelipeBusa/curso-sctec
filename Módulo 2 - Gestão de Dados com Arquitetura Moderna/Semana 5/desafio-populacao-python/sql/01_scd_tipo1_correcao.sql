-- =============================================================================
-- Desafio -- Etapa 3: SCD Tipo 1 -- corrigir o nome do estado
-- =============================================================================
-- A carga inicial (scripts/03_carga_inicial.py) gravou "Pernanbuco" em vez
-- de "Pernambuco" para a sigla PE (de propósito -- ver ERRO_DIGITACAO
-- naquele script) -- nas DUAS versões, 2010 e 2022, porque é o mesmo nome
-- errado se repetindo. É uma correção de cadastro, sem motivo para guardar
-- histórico: igual à Vitrine corrigindo a cidade da Laura Macedo
-- (sql/03_scd_tipo1_cliente.sql). Isso é SCD Tipo 1.
--
-- TODO:
-- 1. Escreva um SELECT "ANTES" mostrando sk_estado, sigla, nome_estado,
--    ano_referencia de onde sigla = 'PE' (deve devolver 2 linhas: 2010 e
--    2022, as duas com "Pernanbuco").
-- 2. Escreva um INSERT ... ON CONFLICT (sigla, ano_referencia) DO UPDATE
--    que sobrescreva nome_estado para 'Pernambuco' em TODAS as linhas da
--    sigla 'PE'. Dica: o conflito é por (sigla, ano_referencia) -- ver
--    UNIQUE em sql/00_dw_populacao_schema.sql -- então um INSERT ...
--    SELECT * FROM dim_estado_scd2 WHERE sigla = 'PE' dispara o ON
--    CONFLICT uma vez para CADA linha existente (2010 e 2022 -- não filtre
--    por ano_referencia aqui, nome_estado não é um campo versionado).
-- 3. Escreva um SELECT "DEPOIS" confirmando que são as MESMAS 2 sk_estado,
--    só com o nome corrigido nas duas -- sem linha nova.
--
-- Rode com:
--   psql -h localhost -U postgres -d vitrine -f sql/01_scd_tipo1_correcao.sql
-- =============================================================================

-- TODO: SELECT "antes"
SELECT
    sk_estado,
    sigla,
    nome_estado,
    ano_referencia
FROM dw_populacao.dim_estado_scd2
WHERE sigla = 'PE'
ORDER BY ano_referencia;

-- TODO: INSERT ... ON CONFLICT (sigla, ano_referencia) DO UPDATE ...
INSERT INTO dw_populacao.dim_estado_scd2 (
    id_estado,
    sigla,
    nome_estado,
    regiao,
    populacao,
    ano_referencia,
    data_inicio,
    data_fim,
    registro_atual
)
SELECT
    id_estado,
    sigla,
    'Pernambuco',
    regiao,
    populacao,
    ano_referencia,
    data_inicio,
    data_fim,
    registro_atual
FROM dw_populacao.dim_estado_scd2
WHERE sigla = 'PE'

ON CONFLICT (sigla, ano_referencia)
DO UPDATE SET
    nome_estado = EXCLUDED.nome_estado;


-- TODO: SELECT "depois"
SELECT
    sk_estado,
    sigla,
    nome_estado,
    ano_referencia
FROM dw_populacao.dim_estado_scd2
WHERE sigla = 'PE'
ORDER BY ano_referencia;
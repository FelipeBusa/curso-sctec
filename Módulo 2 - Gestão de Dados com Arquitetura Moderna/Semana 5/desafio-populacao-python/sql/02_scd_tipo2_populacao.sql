-- =============================================================================
-- Desafio -- Etapa 6: SCD Tipo 2 -- fecha a versão 2022, abre a versão 2026
-- =============================================================================
-- A população mudou de verdade entre o Censo 2022 e a estimativa 2026 (ver
-- Etapa 5). Como queremos poder responder "qual era a população do estado
-- X em 2022?" DEPOIS de carregar o número novo, não dá para sobrescrever --
-- precisa de uma versão nova, preservando a antiga. Igual à Vitrine
-- reclassificando o Smartwatch Fit X (sql/04_scd_tipo2_produto.sql): UPDATE
-- fecha a versão antiga, INSERT cria a nova, tudo numa transação só.
--
-- Troque :sigla, :populacao_nova e :data_corte pelos valores de UM estado
-- que a Etapa 5 (scripts/04_carga_incremental.py) apontou como alterado,
-- repita para os demais. (Em produção isso seria um loop no Python --
-- aqui, uma vez na mão primeiro ajuda a entender o padrão.)
--
-- TODO:
-- 1. BEGIN;
-- 2. UPDATE dw_populacao.dim_estado_scd2 SET data_fim = ..., registro_atual
--    = false WHERE sigla = ... AND ano_referencia = 2022 AND registro_atual
--    = true;
-- 3. INSERT INTO dw_populacao.dim_estado_scd2 (id_estado, sigla,
--    nome_estado, regiao, populacao, ano_referencia, data_inicio, data_fim,
--    registro_atual) VALUES (..., 2026, ..., NULL, true); -- reaproveite
--    id_estado/nome_estado/regiao da versão 2022 que você acabou de fechar.
-- 4. COMMIT;
-- 5. Escreva um SELECT final mostrando as TRÊS versões lado a lado (sigla,
--    populacao, ano_referencia, data_inicio, data_fim, registro_atual),
--    ordenado por data_inicio, para o estado que você versionou.
--
-- Use DATE '2026-01-01' como data de corte (data_fim da versão 2022 e
-- data_inicio da versão 2026) -- é uma simplificação didática da data real
-- de publicação da estimativa do IBGE.
--
-- Rode só depois de confirmar com a Etapa 5 que o estado realmente mudou
-- (senão duplica uma versão igual à anterior).
-- Rode com:
--   psql -h localhost -U postgres -d vitrine -f sql/02_scd_tipo2_populacao.sql
-- =============================================================================

BEGIN;

-- ============================================================
-- 1. TABELA TEMPORÁRIA COM AS POPULAÇÕES DE 2026
-- ============================================================

CREATE TEMP TABLE tmp_populacao_2026 (
    sigla VARCHAR(2) PRIMARY KEY,
    populacao BIGINT NOT NULL
) ON COMMIT DROP;

INSERT INTO tmp_populacao_2026 (sigla, populacao)
VALUES
    ('RO', 1757338),
    ('AC', 887794),
    ('AM', 4360926),
    ('RR', 761012),
    ('PA', 8756324),
    ('AP', 809953),
    ('TO', 1595994),
    ('MA', 7024557),
    ('PI', 3392617),
    ('CE', 9302211),
    ('RN', 3463737),
    ('PB', 4182828),
    ('PE', 9583176),
    ('AL', 3221128),
    ('SE', 2307255),
    ('BA', 14889472),
    ('MG', 21460311),
    ('ES', 4150692),
    ('RJ', 17225410),
    ('SP', 46179008),
    ('PR', 11952456),
    ('SC', 8312759),
    ('RS', 11233317),
    ('MS', 2946317),
    ('MT', 3950330),
    ('GO', 7495033),
    ('DF', 3009996);


-- ============================================================
-- 2. FECHAR AS VERSÕES VIGENTES DE 2022
-- ============================================================

UPDATE dw_populacao.dim_estado_scd2 AS d
SET
    data_fim = DATE '2026-01-01',
    registro_atual = false
FROM tmp_populacao_2026 AS n
WHERE d.sigla = n.sigla
  AND d.ano_referencia = 2022
  AND d.registro_atual = true;


-- ============================================================
-- 3. INSERIR AS NOVAS VERSÕES DE 2026
-- ============================================================

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
    d.id_estado,
    d.sigla,
    d.nome_estado,
    d.regiao,
    n.populacao,
    2026,
    DATE '2026-01-01',
    NULL,
    true
FROM dw_populacao.dim_estado_scd2 AS d
INNER JOIN tmp_populacao_2026 AS n
    ON d.sigla = n.sigla
WHERE d.ano_referencia = 2022
  AND d.registro_atual = false
  AND d.data_fim = DATE '2026-01-01';


-- ============================================================
-- 4. CONFERIR OS RESULTADOS ANTES DO COMMIT
-- ============================================================

SELECT
    ano_referencia,
    COUNT(*) AS quantidade_registros,
    COUNT(DISTINCT sigla) AS estados_distintos
FROM dw_populacao.dim_estado_scd2
GROUP BY ano_referencia
ORDER BY ano_referencia;

SELECT
    COUNT(*) AS registros_vigentes,
    COUNT(DISTINCT sigla) AS estados_vigentes
FROM dw_populacao.dim_estado_scd2
WHERE registro_atual = true;

SELECT
    sigla,
    nome_estado,
    populacao,
    ano_referencia,
    data_inicio,
    data_fim,
    registro_atual
FROM dw_populacao.dim_estado_scd2
WHERE ano_referencia = 2026
ORDER BY sigla;

-- Se as conferências estiverem corretas:
COMMIT;

-- Se houver qualquer divergência, execute ROLLBACK
-- em vez de COMMIT.

SELECT
    ano_referencia,
    COUNT(*) AS total_registros,
    COUNT(*) FILTER (WHERE registro_atual = true) AS registros_vigentes,
    COUNT(*) FILTER (WHERE registro_atual = false) AS registros_encerrados
FROM dw_populacao.dim_estado_scd2
GROUP BY ano_referencia
ORDER BY ano_referencia;

----
-- Consulta dw_população.controle_etl
SELECT *
FROM dw_populacao.controle_etl;

-- Quebra do sql
ROLLBACK;

-- Consulta dim_estado_scd2
SELECT * FROM dw_populacao.dim_estado_scd2
ORDER BY sk_estado ASC; 
-- =============================================================================
-- Desafio -- Etapa 7: consultar a população vigente numa data
-- =============================================================================
-- Fecha o SCD: o Data Warehouse da população agora sabe responder no tempo
-- certo. Mesmo padrão da Vitrine (sql/05_consultas_scd.sql).
--
-- TODO:
-- 1. Escreva a consulta GENÉRICA: população vigente de UM estado (escolha
--    uma sigla) numa data escolhida por você -- filtre data_inicio/data_fim 
SELECT *
FROM dw_populacao.dim_estado_scd2
WHERE 
	sigla LIKE 'SC' AND ano_referencia = 2026;

-- 2. Responda: qual estado teve a MAIOR variação absoluta de população
--    entre a versão 2022 e a versão 2026, considerando só os estados
SELECT
    v2022.sigla,
    v2022.nome_estado,
    v2022.populacao AS populacao_2022,
    v2026.populacao AS populacao_2026,
    ABS(v2026.populacao - v2022.populacao) AS variacao_absoluta,
	ROUND(((v2026.populacao - v2022.populacao)::NUMERIC/ v2022.populacao) * 100,2) AS variacao_percentual
FROM dw_populacao.dim_estado_scd2 v2022
JOIN dw_populacao.dim_estado_scd2 v2026
    ON v2022.sigla = v2026.sigla
ORDER BY variacao_absoluta DESC
LIMIT 1;



SELECT * FROM dw_populacao.dim_estado_scd2
ORDER BY sk_estado ASC; 
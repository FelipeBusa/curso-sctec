-- =============================================================================
-- Desafio -- Etapa 7: consultar a população vigente numa data
-- =============================================================================
-- Fecha o SCD: o Data Warehouse da população agora sabe responder no tempo
-- certo. Mesmo padrão da Vitrine (sql/05_consultas_scd.sql).
--
-- TODO:
-- 1. Escreva a consulta GENÉRICA: população vigente de UM estado (escolha
--    uma sigla) numa data escolhida por você -- filtre
--    data_inicio/data_fim como no slide da Vitrine (slide "Consultando a
--    versão vigente em uma data"): a data cai dentro do intervalo quando
--    data >= data_inicio AND (data_fim IS NULL OR data < data_fim).
-- 2. Responda: qual estado teve a MAIOR variação absoluta de população
--    entre a versão 2022 e a versão 2026, considerando só os estados que a
--    Etapa 6 já versionou (dica: self-join de dim_estado_scd2 com ele
--    mesmo, uma vez por ano_referencia, e ORDER BY a diferença).
-- 3. Quantos estados ainda têm só 2 versões -- 2010 e 2022 -- (ou seja, a
--    Etapa 6 ainda não rodou pra eles, a versão 2026 falta)?
-- 4. O pipeline do desafio consegue rodar de novo sem duplicar nada?
--    (Pense: o que acontece se você rodar scripts/03_carga_inicial.py uma
--    segunda vez -- e o que acontece se rodar sql/02_scd_tipo2_populacao.sql
--    uma segunda vez para o MESMO estado.)
--
-- Rode com:
--   psql -h localhost -U postgres -d vitrine -f sql/03_consultas.sql
-- =============================================================================

-- TODO: 1) população vigente de um estado numa data

-- TODO: 2) maior variação 2022 -> 2026

-- TODO: 3) quantos estados só têm 2 versões

-- TODO: 4) é só uma pergunta para discutir, não precisa de SQL

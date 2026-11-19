-- =============================================================================
-- Schema dw_populacao: o Data Warehouse do Desafio (população brasileira)
-- =============================================================================
-- Mesmo banco "vitrine" do pacote vitrine-etl-python/, só um schema novo --
-- não precisa criar outro banco.
--
-- dim_estado_scd2 já nasce versionada (data_inicio/data_fim/registro_atual),
-- igual a dw_python.dim_produto_scd2 da Vitrine -- aqui não existe uma
-- "dim_estado simples" separada, porque toda a aula trabalha numa linha do
-- tempo só: a população de cada estado, por ano de referência.
--
-- UNIQUE (sigla, ano_referencia): é o que permite corrigir um erro de
-- digitação com INSERT ... ON CONFLICT (Etapa 3, SCD Tipo 1) sem quebrar
-- quando uma segunda versão do MESMO estado for inserida depois (Etapa 6,
-- SCD Tipo 2) -- o conflito é por sigla+ano, nunca só por sigla.
--
-- Rode a partir da raiz deste projeto (desafio-populacao-python/):
--   psql -h localhost -U postgres -d vitrine -f sql/00_dw_populacao_schema.sql
-- =============================================================================

CREATE SCHEMA IF NOT EXISTS dw_populacao;

CREATE TABLE dw_populacao.dim_estado_scd2 (
    sk_estado       serial PRIMARY KEY,
    id_estado       integer      NOT NULL,   -- id do IBGE (ex.: 35 = São Paulo)
    sigla           varchar(2)   NOT NULL,
    nome_estado     varchar(100) NOT NULL,
    regiao          varchar(50)  NOT NULL,
    populacao       bigint       NOT NULL,
    ano_referencia  smallint     NOT NULL,    -- 2010 ou 2022 (Censo) ou 2026 (estimativa IBGE)
    data_inicio     date         NOT NULL,
    data_fim        date,
    registro_atual  boolean      NOT NULL DEFAULT true,
    UNIQUE (sigla, ano_referencia)
);

-- Controle da carga incremental (Etapa 5): guarda a última vez que o
-- pipeline da população rodou com sucesso -- mesmo papel de
-- dw_python.controle_etl na Vitrine.
CREATE TABLE dw_populacao.controle_etl (
    nome_pipeline   varchar(100) PRIMARY KEY,
    ultima_carga    timestamp NOT NULL
);
INSERT INTO dw_populacao.controle_etl (nome_pipeline, ultima_carga)
VALUES ('etl_populacao_brasil', '1900-01-01');

SELECT 'dw_populacao.dim_estado_scd2' AS tabela, count(*) FROM dw_populacao.dim_estado_scd2
UNION ALL SELECT 'dw_populacao.controle_etl', count(*) FROM dw_populacao.controle_etl;

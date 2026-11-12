-- =============================================================================
-- Exportar o Star Schema para CSV (para carregar no BigQuery)
-- =============================================================================
-- Gera 1 CSV por tabela dentro de export_bigquery/, para subir no BigQuery e
-- recriar a MESMA modelagem lá -- mesmos dados, mesmas chaves, plataforma
-- diferente (não é uma conexão ao vivo entre os dois bancos, é uma cópia
-- pontual).
--
-- Pré-requisitos:
--   1) sql/02_dw_star_schema.sql já rodado (schema dw.* populado)
--   2) a pasta export_bigquery/ já criada na raiz do projeto (mkdir export_bigquery)
--
-- Rode com:  psql -h localhost -U postgres -d vitrine -f sql/05_exportar_para_bigquery.sql
-- =============================================================================

\copy dw.dim_tempo    TO 'export_bigquery/dim_tempo.csv'    WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');
\copy dw.dim_produto  TO 'export_bigquery/dim_produto.csv'  WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');
\copy dw.dim_cliente  TO 'export_bigquery/dim_cliente.csv'  WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');
\copy dw.dim_loja     TO 'export_bigquery/dim_loja.csv'     WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');
\copy dw.fato_vendas  TO 'export_bigquery/fato_vendas.csv'  WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- Confira: 5 arquivos CSV dentro de export_bigquery/, com o mesmo número de
-- linhas de dw.* (dim_tempo=365, dim_produto=17, dim_cliente=51, dim_loja=3,
-- fato_vendas=820).

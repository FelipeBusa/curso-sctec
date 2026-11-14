# Vitrine — ETL tradicional e avançado com Python e PostgreSQL

Continuação direta do pacote da Semana 4 (`../vitrine-dw/`): mesma loja
fictícia **Vitrine**, mesmo banco `vitrine` no PostgreSQL. A diferença é o
caminho até o Data Warehouse: em vez de carregar bruto e transformar em SQL
(ELT, Semana 4), aqui a transformação acontece em **Python, com Pandas**,
antes de qualquer coisa entrar no banco (ETL tradicional) -- e depois o
Data Warehouse aprende a **acompanhar o tempo** (carga incremental e
Slowly Changing Dimensions).

> **Pré-requisito**: rode `../vitrine-dw/` primeiro (pelo menos até
> `sql/01_staging_elt_load.sql`), porque a Parte 2 depende de
> `staging.vendas_raw` e `staging.clientes_raw` já existirem no banco
> `vitrine`.

## Estrutura

```
vitrine-etl-python/
├── raw/
│   ├── vendas.csv, clientes.csv, produtos.csv  # os mesmos da Semana 4
│   ├── api_produtos_mock.json        # simula a API de catálogo da Vitrine
│   └── concorrente_smartwatch.html   # simula a página do concorrente (scraping)
├── processed/      # saída de scripts/02_transformar.py (demonstração isolada)
├── scripts/        # Python -- ver "Como cada arquivo se encaixa"
│   ├── 01_extrair_fontes.py
│   ├── 02_transformar.py
│   ├── 03_construir_dimensional.py
│   ├── pipeline_etl.py
│   └── 05_carga_incremental.py
├── sql/             # SQL, um arquivo por etapa da Parte 2
│   ├── 00_dw_python_schema.sql
│   ├── 01_popular_scd2_inicial.sql
│   ├── 02_simular_mudancas.sql
│   ├── 03_scd_tipo1_cliente.sql
│   ├── 04_scd_tipo2_produto.sql
│   └── 05_consultas_scd.sql
└── docs/
    └── resultados_esperados.md
```

## Como cada arquivo se encaixa

| Arquivo(s) | O que demonstra |
|---|---|
| `scripts/01_extrair_fontes.py` | As 4 fontes do ETL em Python: CSV, PostgreSQL (staging), API e Web Scraping |
| `scripts/02_transformar.py` | Limpeza (produto duplicado, datas em 2 formatos, valor ausente) e enriquecimento com Pandas -- os MESMOS 3 problemas da Semana 4, resolvidos agora em Python |
| `scripts/03_construir_dimensional.py` | Star Schema construído com `merge()` do Pandas, em vez de `CREATE TABLE` + `INSERT` em SQL |
| `scripts/pipeline_etl.py` + `sql/00_dw_python_schema.sql` | O pipeline completo (`extrair` → `transformar` → `carregar`), full load com `to_sql()` em `dw_python.*` |
| `sql/01_popular_scd2_inicial.sql` + `sql/02_simular_mudancas.sql` | Prepara o cenário "seis meses depois": histórico inicial da `dim_produto_scd2` + a mudança de cidade da cliente e de categoria do produto + 1 venda nova |
| `sql/03_scd_tipo1_cliente.sql` | SCD Tipo 1: `UPSERT` sobrescreve a cidade da cliente, sem histórico |
| `sql/04_scd_tipo2_produto.sql` | SCD Tipo 2: fecha a versão antiga do produto e insere uma nova, com histórico |
| `sql/05_consultas_scd.sql` | A mesma pergunta (categoria do produto numa venda de março/2026) respondida errado (Tipo 1) e certo (Tipo 2) |
| `scripts/05_carga_incremental.py` | Carga incremental de verdade: lê `controle_etl`, filtra `updated_at`, carrega só a venda nova, avança o controle só depois do sucesso |

## Como rodar do zero

```bash
# 0) Pré-requisito: já ter rodado ../vitrine-dw/sql/01_staging_elt_load.sql
#    no banco "vitrine" (staging.vendas_raw e staging.clientes_raw precisam existir)

cd vitrine-etl-python

# ---- Parte 1: ETL tradicional ----
python3 scripts/01_extrair_fontes.py               # demonstração das 4 fontes (não carrega nada)
python3 scripts/02_transformar.py                  # grava processed/*.csv (não precisa de banco)
python3 scripts/03_construir_dimensional.py        # só imprime as dimensões (não precisa de banco)

psql -h localhost -U postgres -d vitrine -f sql/00_dw_python_schema.sql
python3 scripts/pipeline_etl.py                     # carga cheia: 17 produtos, 51 clientes, 820 vendas

# ---- Parte 2: ETL avançado (incremental + SCD) ----
psql -h localhost -U postgres -d vitrine -f sql/01_popular_scd2_inicial.sql
psql -h localhost -U postgres -d vitrine -f sql/02_simular_mudancas.sql
python3 scripts/05_carga_incremental.py             # adiciona só a venda nova (1 linha) a fato_vendas
psql -h localhost -U postgres -d vitrine -f sql/03_scd_tipo1_cliente.sql
psql -h localhost -U postgres -d vitrine -f sql/04_scd_tipo2_produto.sql
psql -h localhost -U postgres -d vitrine -f sql/05_consultas_scd.sql   # só faz sentido DEPOIS da carga incremental
```

Ajuste usuário/senha da conexão conforme seu ambiente -- a string de conexão
usada nos scripts Python é a mesma do slide (`postgresql+psycopg2://postgres:senha@localhost:5432/vitrine`),
só um exemplo didático.

> **A API e o concorrente da Vitrine não existem de verdade.**
> `scripts/01_extrair_fontes.py` usa dois arquivos fictícios que simulam
> essas respostas: `raw/api_produtos_mock.json` (catálogo de produtos) e
> `raw/concorrente_smartwatch.html` (preço do concorrente via scraping). A
> aula roda 100% offline -- sem depender de internet ou de APIs públicas de
> terceiros.

## O fio que conecta Parte 1 e Parte 2

1. `pipeline_etl.py` faz a carga cheia inicial (820 vendas, sempre com
   `if_exists="append"` -- rodar de novo duplicaria tudo).
2. `sql/02_simular_mudancas.sql` simula "seis meses depois": a cliente Laura
   Macedo (`id_cliente 37`) muda de Belo Horizonte para Florianópolis, o
   Smartwatch Fit X (`id_produto 114`) é reclassificado de Eletrônicos para
   Wearables, e 1 venda nova do Smartwatch entra em `staging.vendas_raw`
   com `data_venda = 2026-03-15` (antes da reclassificação) e
   `updated_at = now()`.
3. `scripts/05_carga_incremental.py` lê só essa 1 linha nova (não
   reprocessa as 820 antigas) e a soma a `fato_vendas`.
4. `sql/05_consultas_scd.sql` mostra por que isso importa: consultando a
   categoria dessa venda pela `dim_produto` comum (Tipo 1) dá **Wearables**
   (errado -- é a categoria de hoje); consultando pela `dim_produto_scd2`
   (Tipo 2) dá **Eletrônicos** (correto -- era essa a categoria vigente em
   15/03/2026).

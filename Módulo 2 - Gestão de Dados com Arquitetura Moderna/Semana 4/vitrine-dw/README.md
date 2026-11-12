# Vitrine — pacote didático de Data Warehouse (ETL/ELT, Modelagem Dimensional)

Pacote de dados e scripts que acompanha os conceitos de OLTP, OLAP, Data Lake
e Data Warehouse (ETL/ELT, Star Schema, Snowflake Schema). Uma única base
fictícia — a loja **Vitrine** — conecta todas as demonstrações.

Ambiente usado: **PostgreSQL local** (já testado neste pacote com PostgreSQL 16).
Tudo foi rodado de ponta a ponta para garantir que executa sem erro — os números
reais de cada consulta estão em `docs/resultados_esperados.md`.

## Estrutura

```
vitrine-dw/
├── raw/            # "entrada do Data Lake": arquivos brutos, com os 3 problemas propositais
│   ├── produtos.csv     (1 produto duplicado: id 101 e 118)
│   ├── clientes.csv
│   ├── lojas.csv
│   ├── vendas.csv       (datas em 2 formatos; 1 linha com valor ausente)
│   └── pagamentos.json  (semiestruturado, aninhado)
├── processed/      # saída do script Python de limpeza (demonstração de ETL)
│   ├── produtos_tratado.csv
│   ├── mapa_produtos_duplicados.csv
│   └── vendas_tratada.csv
├── scripts/        # Python
│   ├── 01_gerar_dados_brutos.py   # gera tudo que está em raw/ (seed fixa, reprodutível)
│   └── 02_tratar_dados.py         # ETL: lê raw/, corrige, grava em processed/
├── sql/            # SQL, um arquivo por etapa
│   ├── 00_oltp_olap_demo.sql
│   ├── 01_staging_elt_load.sql
│   ├── 01b_pagamentos_insert.sql  # gerado automaticamente, ver observação abaixo
│   ├── 02_dw_star_schema.sql
│   ├── 03_consultas_negocio.sql
│   ├── 04_snowflake_schema.sql
│   └── 05_exportar_para_bigquery.sql
├── export_bigquery/  # gerado pelo passo 05 acima (CSVs para subir no BigQuery)
├── diagrams/       # cole no dbdiagram.io para comparar Star x Snowflake visualmente
│   ├── star_schema.dbml
│   └── snowflake_schema.dbml
└── docs/
    └── resultados_esperados.md    # "gabarito": o que cada consulta deve devolver
```

## Como cada arquivo se encaixa

| Arquivo(s) | O que demonstra |
|---|---|
| `sql/00_oltp_olap_demo.sql` | OLTP x OLAP: `UPDATE` pontual x `SELECT ... GROUP BY` agregado, lado a lado |
| `scripts/02_tratar_dados.py` (ETL) + `sql/01_staging_elt_load.sql` (ELT) | Data Lake, ETL e ELT: os MESMOS 3 problemas de qualidade de dados resolvidos de dois jeitos diferentes |
| `sql/02_dw_star_schema.sql` + `sql/03_consultas_negocio.sql` | Construindo o DW: grão da fato, dimensões, consultas de negócio e o desafio final (faturamento x lucro) |
| `sql/04_snowflake_schema.sql` + `diagrams/*.dbml` | Star x Snowflake: mesma pergunta, 1 join x 2 joins |
| `sql/05_exportar_para_bigquery.sql` | Exporta o Star Schema para CSV, para recriar a mesma modelagem no BigQuery |

> **Redshift/BigQuery não têm script aqui de propósito**: é navegação pela
> interface real dessas plataformas, não algo para rodar localmente. Se
> quiser, o mesmo `sql/02_dw_star_schema.sql` roda quase sem alterações num
> desses ambientes (troque `serial` por `IDENTITY`/`GENERATE_UUID()` conforme
> a plataforma) — útil para mostrar "a mesma modelagem, plataforma diferente".

## Como rodar do zero

```bash
# 1) Suba um Postgres local (ajuste usuário/senha conforme seu ambiente)
createdb vitrine

# 2) Gere os dados brutos (ou use os que já estão em raw/)
cd vitrine-dw
python3 scripts/01_gerar_dados_brutos.py

# 3) (opcional, demonstração de ETL em Python) gere a versão tratada
python3 scripts/02_tratar_dados.py

# 4) Rode os arquivos SQL em ordem -- SEMPRE a partir da raiz do projeto,
#    porque os \copy usam caminhos relativos (raw/arquivo.csv)
psql -h localhost -U postgres -d vitrine -f sql/00_oltp_olap_demo.sql
psql -h localhost -U postgres -d vitrine -f sql/01_staging_elt_load.sql
psql -h localhost -U postgres -d vitrine -f sql/02_dw_star_schema.sql
psql -h localhost -U postgres -d vitrine -f sql/03_consultas_negocio.sql
psql -h localhost -U postgres -d vitrine -f sql/04_snowflake_schema.sql
```

Rode tudo uma vez e confira os números contra `docs/resultados_esperados.md`.
Depois, cada arquivo pode ser reexecutado individualmente (`\i sql/02_dw_star_schema.sql`
dentro do `psql`, por exemplo) para revisar uma etapa específica -- cada
arquivo já está comentado e dividido nos pontos certos.

> **Sobre `sql/01b_pagamentos_insert.sql`**: `raw/pagamentos.json` é um
> documento JSON grande, e carregar esse tipo de arquivo via `\set` + shell
> (`cat`/`type`) é frágil entre sistemas (principalmente no Windows). Por
> isso o conteúdo do JSON já vem pré-processado nesse arquivo como um único
> `INSERT`, e `sql/01_staging_elt_load.sql` o inclui automaticamente via
> `\i sql/01b_pagamentos_insert.sql`. Se o conteúdo de `pagamentos.json`
> mudar, regenere esse arquivo lendo o JSON e escapando aspas simples
> (`'` -> `''`) antes de montar o `INSERT`.

## Os 3 problemas propositais nos dados (e onde cada um é resolvido)

1. **Produto duplicado** — `id_produto` 101 e 118 são o mesmo tênis, só que
   118 foi digitado errado ("tenis runner pro ", sem acento, minúsculo, com
   espaço sobrando). Resolvido em `scripts/02_tratar_dados.py` (Python/ETL)
   e, separadamente, em `sql/02_dw_star_schema.sql` (SQL/ELT) — mesma
   correção, dois caminhos, para comparar as duas abordagens.
2. **Datas em dois formatos** — `vendas.csv` mistura `AAAA-MM-DD` (ISO) e
   `DD/MM/AAAA` (como um PDV mais antigo costuma exportar). Resolvido do
   mesmo jeito duplo acima.
3. **Valor ausente** — a venda `id_venda = 38` não tem `valor_unitario`. Em
   vez de inventar um número, o modelo preserva `NULL` e marca
   `status_qualidade = 'valor_ausente_revisar'` — bom gancho para falar de
   qualidade de dados sem transformar isso num bug escondido.

## Sobre o dinheiro: por que Eletrônicos puxa o desafio final

Os custos em `raw/produtos.csv` foram montados de propósito: a categoria
Eletrônicos vende muito (volume alto) mas tem margem apertada (~10%),
enquanto Calçados/Vestuário/Acessórios vendem menos mas com margem muito
melhor (53% a 65%). O resultado real (não forçado na consulta, só nos dados
de entrada) é que **Calçados lucra mais em reais do que Eletrônicos**, apesar
de faturar menos de um terço. Os números exatos estão em
`docs/resultados_esperados.md`.

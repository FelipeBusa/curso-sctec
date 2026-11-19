# Desafio -- Data Warehouse da população brasileira

A partir do slide 27 da aula, cada conceito que a professora demonstra na
Vitrine (`../vitrine-etl-python/`) tem uma etapa equivalente aqui, para a
turma fazer em paralelo -- em pequenos passos, não uma entrega única no
final. O tema é a população dos estados brasileiros, com as MESMAS 3 fontes
da Vitrine (CSV, API, Web Scraping):

- **CSV**: `raw/populacao_2010.csv` -- o Censo 2010, histórico e já pronto
  (não precisa buscar de novo, igual ao papel do CSV na Vitrine).
- **API**: [Localidades do IBGE](https://servicodados.ibge.gov.br/api/v1/localidades/estados)
  -- id, sigla, nome e região de cada estado + Distrito Federal.
- **Web Scraping**: a tabela ["Lista de unidades federativas do Brasil por
  população"](https://pt.wikipedia.org/wiki/Lista_de_unidades_federativas_do_Brasil_por_popula%C3%A7%C3%A3o)
  na Wikipédia -- população do Censo 2022 e da estimativa 2026 do IBGE.

A API e o scraping são reais e públicos, sem chave de acesso. Usa o mesmo
banco `vitrine` da Vitrine, só um schema novo (`dw_populacao`).

## Equivalência com a Vitrine

| Etapa do desafio | Script/SQL | Equivalente na Vitrine |
|---|---|---|
| 1. Extração | `scripts/01_extrair_fontes.py` | slides 10, 13 e 15 (CSV, API de produtos, scraping do concorrente) |
| 2. Transformação + carga inicial | `scripts/02_transformar.py`, `scripts/03_carga_inicial.py` | slides 16-26 (limpeza, dimensões, `to_sql`) |
| 3. SCD Tipo 1 | `sql/01_scd_tipo1_correcao.sql` | slides 39-40 (correção da cidade da Laura Macedo) |
| 4. Cenário: a estimativa 2026 chega | -- (só discussão) | slide 32 ("E quando os dados da Vitrine mudam?") |
| 5. Carga incremental | `scripts/04_carga_incremental.py` | slides 46-47 -- aqui usamos a Estratégia 3 do slide 36 (comparar valor armazenado x valor novo), não `updated_at`, porque a Wikipédia não tem essa coluna |
| 6. SCD Tipo 2 | `sql/02_scd_tipo2_populacao.sql` | slide 49 (reclassificação do Smartwatch Fit X) |
| 7. Consultas | `sql/03_consultas.sql` | slide 51 (versão vigente numa data) |

## Por que 2 versões já na carga inicial

Diferente da Vitrine (que começa com só 1 versão por produto), o CSV do
Censo 2010 já traz um pedaço do passado pronto. A carga inicial
(`scripts/03_carga_inicial.py`) carrega as DUAS primeiras versões de cada
estado -- 2010 (já fechada) e 2022 (vigente) -- antes mesmo de qualquer SCD
acontecer. A Etapa 6 (SCD Tipo 2) depois abre a 3ª versão, 2026.

## Erro de propósito

`scripts/03_carga_inicial.py` carrega o estado de Pernambuco com o nome
errado ("Pernanbuco") nas duas versões (2010 e 2022) -- de propósito, para a
Etapa 3 ter algo real para corrigir com SCD Tipo 1. Não corrija antes da
hora.

## Pré-requisito

```
psql -h localhost -U postgres -d vitrine -f sql/00_dw_populacao_schema.sql
```

## Como rodar, na ordem

```bash
cd desafio-populacao-python
cp .env.example .env   # e preencha DB_PASSWORD

python3 scripts/01_extrair_fontes.py       # Etapa 1 -- só demonstração das 3 fontes
python3 scripts/02_transformar.py          # Etapa 2 -- junta as fontes (não precisa de banco)
python3 scripts/03_carga_inicial.py        # Etapa 2 -- carga cheia, versões 2010 + 2022 (54 linhas)

psql -h localhost -U postgres -d vitrine -f sql/01_scd_tipo1_correcao.sql   # Etapa 3

# Etapa 4 é só a professora apresentar o cenário -- sem código.

python3 scripts/04_carga_incremental.py    # Etapa 5 -- aponta quais estados mudaram
psql -h localhost -U postgres -d vitrine -f sql/02_scd_tipo2_populacao.sql  # Etapa 6
psql -h localhost -U postgres -d vitrine -f sql/03_consultas.sql           # Etapa 7
```

## Arquivos

```
desafio-populacao-python/
├── raw/
│   └── populacao_2010.csv         # dado pronto: Censo 2010 por estado
├── scripts/
│   ├── 01_extrair_fontes.py       # TODO -- CSV 2010 + API IBGE + scraping Wikipédia
│   ├── 02_transformar.py          # TODO -- juntar as três fontes
│   ├── 03_carga_inicial.py        # TODO -- montar e carregar as versões 2010 + 2022
│   └── 04_carga_incremental.py    # TODO -- detectar o que mudou para 2026
├── sql/
│   ├── 00_dw_populacao_schema.sql # dado pronto: cria dw_populacao.*
│   ├── 01_scd_tipo1_correcao.sql  # TODO -- corrigir Pernambuco
│   ├── 02_scd_tipo2_populacao.sql # TODO -- fechar 2022, abrir 2026
│   └── 03_consultas.sql           # TODO -- população vigente numa data
└── .env.example
```

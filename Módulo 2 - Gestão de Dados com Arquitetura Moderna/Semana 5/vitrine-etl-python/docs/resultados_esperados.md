# Resultados esperados

Todo este pacote foi **rodado de verdade** contra um PostgreSQL 17 local
(banco `vitrine`, mesmo banco da Semana 4), na ordem descrita no README. Use
esta página como gabarito.

## Parte 1 -- scripts Python isolados (sem banco)

- `scripts/02_transformar.py`: 18 produtos brutos → **1 duplicata** remapeada
  (`118 → 101`); 820 vendas, datas padronizadas, **1 linha** com valor
  ausente marcada como `valor_ausente_revisar` (a venda `id_venda = 38`,
  igual à Semana 4).
- `scripts/03_construir_dimensional.py`: `dim_produto` com **17** produtos
  únicos, `dim_cliente` com **51** clientes, `fato_vendas` com **820**
  linhas -- nenhum `sk_produto`/`sk_cliente` nulo (os merges bateram 100%).

## sql/00_dw_python_schema.sql + scripts/pipeline_etl.py -- carga cheia

Depois de `executar_etl()`:

| tabela | linhas |
|---|---|
| `dw_python.dim_produto` | 17 |
| `dw_python.dim_cliente` | 51 |
| `dw_python.fato_vendas` | 820 (819 `ok` + 1 `valor_ausente_revisar`) |

## sql/01_popular_scd2_inicial.sql

`dw_python.dim_produto_scd2`: **17** linhas, 1 versão por produto, todas com
`data_inicio = 2025-01-01`, `data_fim IS NULL`, `registro_atual = true`.

## sql/02_simular_mudancas.sql -- "seis meses depois"

- 1 venda nova inserida em `staging.vendas_raw` (`id_venda 821`,
  `id_cliente 37`, `id_produto 114`, `data_venda = 2026-03-15`,
  `updated_at = now()`).
- `staging.clientes_raw`: cliente 37 (Laura Macedo) com `cidade` atualizada
  para **Florianópolis** (era Belo Horizonte).

## scripts/05_carga_incremental.py

Roda **antes** de `sql/05_consultas_scd.sql`, porque é ele que leva a venda
nova de `staging.vendas_raw` até `dw_python.fato_vendas`:

```
[Incremental] 1 linha(s) nova(s) ou alterada(s) desde 2026-01-02 00:00:00
Carga incremental concluída: 1 linha(s) adicionada(s) a fato_vendas.
```

Antes: `controle_etl.ultima_carga = 2026-01-02`. Depois: avançou para o
timestamp exato da execução (ex.: `2026-11-10 18:40:45`).

## sql/03_scd_tipo1_cliente.sql

| | antes | depois |
|---|---|---|
| `sk_cliente` | 36 | 36 (mesma linha) |
| `cidade` | Belo Horizonte | **Florianópolis** |

Mesma `sk_cliente`: sobrescreveu, não criou histórico.

## sql/04_scd_tipo2_produto.sql

`dw_python.dim_produto_scd2` para `id_produto = 114`, duas versões:

| sk_produto | categoria | data_inicio | data_fim | registro_atual |
|---|---|---|---|---|
| 15 | Eletrônicos | 2025-01-01 | 2026-06-15 | false |
| 18 | Wearables | 2026-06-15 | NULL | true |

## sql/05_consultas_scd.sql -- a mesma pergunta, duas respostas

Pergunta: qual categoria aparece na venda de 15/03/2026 do Smartwatch Fit X?

| fonte | resultado |
|---|---|
| `dw_python.dim_produto` (SCD Tipo 1, sem histórico) | **Wearables** -- errado, é a categoria de hoje |
| `dw_python.dim_produto_scd2` (SCD Tipo 2, com histórico) | **Eletrônicos** -- correto, era a categoria vigente em março/2026 |

## Estado final de `dw_python.*`

| tabela | linhas |
|---|---|
| `dim_produto` | 17 |
| `dim_cliente` | 51 |
| `fato_vendas` | **821** (820 da carga cheia + 1 da carga incremental) |
| `dim_produto_scd2` | 18 (17 iniciais + 1 nova versão do Smartwatch) |
| `controle_etl` | 1 |

`fato_vendas` por `status_qualidade`: **820** `ok`, **1**
`valor_ausente_revisar` (a venda nova entrou com valor preenchido; a única
sinalizada continua sendo a `id_venda = 38`, herdada da Semana 4).

## O ponto principal da aula, em números

Sem SCD Tipo 2, a pergunta "qual era a categoria do Smartwatch quando ele
foi vendido em março?" não tem resposta certa -- a dimensão comum já foi
sobrescrita para "Wearables" e não existe mais nenhum jeito de recuperar
"Eletrônicos" a partir dela. Só `dim_produto_scd2`, porque guarda
`data_inicio`/`data_fim` por versão, consegue responder corretamente.

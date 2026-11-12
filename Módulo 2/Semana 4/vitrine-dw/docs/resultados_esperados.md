# Resultados esperados

Todas as consultas abaixo foram **rodadas de verdade** neste pacote (PostgreSQL
16, dados gerados com seed fixa -- se você rodar os scripts na ordem, vai ver
exatamente estes números). Use esta página como gabarito ao executar os
scripts, para saber se uma consulta "deu certo" sem precisar decorar nada.

## sql/00_oltp_olap_demo.sql -- OLTP x OLAP

Depois do `UPDATE`, o estoque do produto 101 cai de 48 para **47**.

A consulta OLAP:

| produto | faturamento |
|---|---|
| Smartwatch Fit X | 3599.60 |
| Tênis Runner Pro | 1599.60 |
| Camiseta Dry Fit | 299.70 |

## sql/01_staging_elt_load.sql -- Staging / ELT

- `vendas_raw`: **686** linhas em formato ISO, **134** em formato BR (DD/MM/AAAA).
- 1 linha com `valor_unitario` vazio: `id_venda = 38`.
- Produto duplicado encontrado: `id_produto 101` ("Tênis Runner Pro") e
  `id_produto 118` ("tenis runner pro "), mesmo preço (399.90).
- `pagamentos_raw`: **1** documento jsonb, com 820 pagamentos dentro
  (`jsonb_array_length(payload) = 820`).

## sql/02_dw_star_schema.sql -- Star Schema

Contagem de linhas depois da carga:

| tabela | linhas |
|---|---|
| dim_tempo | 365 |
| dim_produto | **17** (18 brutos − 1 duplicata resolvida) |
| dim_cliente | 51 |
| dim_loja | 3 |
| fato_vendas | 820 |

## sql/03_consultas_negocio.sql -- Consultas de negócio + desafio final

Faturamento por mês (2025) -- o pico real fica em **março** (44.049,23);
novembro e dezembro também aparecem altos:

| mês | faturamento |
|---|---|
| Jan | 18.757,64 |
| Fev | 22.343,88 |
| Mar | 44.049,23 |
| Abr | 31.351,48 |
| Mai | 41.062,55 |
| Jun | 32.603,38 |
| Jul | 28.440,40 |
| Ago | 32.509,87 |
| Set | 26.374,15 |
| Out | 29.479,49 |
| Nov | 37.553,66 |
| Dez | 36.785,22 |

Top 5 produtos por faturamento (dominado por Eletrônicos):

| produto | unidades | faturamento |
|---|---|---|
| Smartwatch Fit X | 165 | 143.848,92 |
| Fone Bluetooth Sport | 126 | 42.705,20 |
| Tênis Runner Pro | 99 | 37.430,61 |
| Balança Inteligente | 130 | 32.864,41 |
| Faixa Cardíaca BT | 121 | 23.558,16 |

Top clientes: **Laura Macedo** (R$ 13.471,98) e **Natalia Farias** (R$ 13.294,31)
lideram; ambos são clientes "Recorrente".

Categoria com mais UNIDADES vendidas: Eletrônicos (542 unidades, bem à frente
de Calçados com 248) -- não é a mesma coisa que faturamento.

Desafio final -- faturamento x lucro, por categoria:

| categoria | faturamento | custo total | lucro bruto | margem |
|---|---|---|---|---|
| Eletrônicos | 242.976,69 | 218.591,00 | 24.385,69 | **10,0%** |
| Calçados | 83.869,18 | 39.395,00 | 44.474,18 | **53,0%** |
| Vestuário | 40.480,90 | 16.778,00 | 23.702,90 | **58,6%** |
| Acessórios | 13.984,18 | 4.932,00 | 9.052,18 | **64,7%** |

O ponto principal: Eletrônicos fatura quase 3x mais que Calçados, mas o
lucro bruto de Calçados (R$ 44.474) é MAIOR que o de Eletrônicos (R$ 24.386).
A resposta só existe porque `dim_produto` guardou `custo_unitario` desde o
início -- se essa coluna não estivesse no modelo, essa pergunta de negócio
não teria como ser respondida.

## sql/04_snowflake_schema.sql -- Star x Snowflake

As duas consultas (1 JOIN no star, 2 JOINs no snowflake) devem bater
**exatamente** nos mesmos valores:

| categoria | faturamento |
|---|---|
| Eletrônicos | 242.976,69 |
| Calçados | 83.869,18 |
| Vestuário | 40.480,90 |
| Acessórios | 13.984,18 |

/* 
Exercício 1 — Performance comercial
A área Comercial quer entender quais produtos estão sustentando o faturamento da empresa.
O gerente solicitou um relatório que mostre quanto cada produto gerou em vendas, 
considerando a quantidade vendida e o valor praticado em cada venda.
Além disso, ele quer identificar apenas os produtos que tiveram volume relevante de vendas, 
eliminando produtos com pouca movimentação.

O resultado deve apresentar:
* identificação do produto;
* nome do produto;
* quantidade total vendida;
* faturamento total gerado.

Os produtos devem aparecer do maior para o menor faturamento.

Pergunta de negócio:
Quais produtos são mais importantes para o faturamento da empresa e quais deles apresentam maior volume de vendas?

Desafio adicional:
Não basta simplesmente listar os produtos. Você precisa definir, a partir da solicitação, 
qual métrica deve ser usada para considerar um produto “relevante” e aplicar esse critério na consulta.
*/
-- Lista com os produtos com maiores faturamento (acima )
SELECT
    p.product_id AS id_produto,
    p.product_name AS nome_produto,
    SUM(od.quantity) AS quantidade_total_vendida,
    ROUND(SUM(od.unit_price * od.quantity)::numeric, 2) AS faturamento_total
FROM public.products p
INNER JOIN public.order_details od
    ON p.product_id = od.product_id
GROUP BY
    p.product_id,
    p.product_name
HAVING SUM(od.quantity) >= 100
ORDER BY faturamento_total DESC;


/*
Exercício 2 — Análise de frete e operação
A diretoria identificou que os custos de transporte estão aumentando e 
pediu uma análise para entender o comportamento dos fretes.
Você precisa produzir uma visão que permita comparar o custo médio de transporte entre 
diferentes regiões de destino.
A análise deve considerar somente pedidos realizados em 1997.

O gestor quer visualizar:
* a região de destino;
* quantidade de pedidos;
* custo total de frete;
* custo médio de frete.

Depois, ordene os resultados para destacar primeiro as regiões com maior custo médio de transporte.

Pergunta de negócio:
Quais regiões apresentam maior custo médio de transporte e podem merecer uma investigação da área de Logística?

Desafio adicional:
Considere que algumas regiões podem ter poucos pedidos. Pense se simplesmente ordenar pelo 
custo médio é suficiente para tomar uma decisão gerencial.
*/
SELECT 
    COALESCE(ship_region, 'Não informado') AS regiao_destino,
    COUNT(*) AS quantidade_pedidos,
    ROUND(SUM(freight)::numeric, 2) AS custo_total_frete,
    ROUND(AVG(freight)::numeric, 2) AS custo_medio_frete
FROM public.orders
WHERE order_date >= '1997-01-01'
  AND order_date < '1998-01-01'
GROUP BY ship_region
ORDER BY AVG(freight) DESC;

-- Pergunta de negócio:
-- Primeiro: analisar o custo médio para identificar possíveis regiões com frete elevado.
-- Depois: cruzar essa informação com: quantidade de pedidos E custo total de frete.
-- As regiões que devem ser avaliadas são ID (média de R$ 175,22), NM (média de R$ 142,88) e
-- Québec (média de R$ 120,52)

-- Desafio adicional:
-- Devem ser avaliados também as regiões com muitos pedidos e alto valor de frente.


/*
Exercício 3 — Análise de clientes e comportamento de compra
O time de Marketing quer identificar clientes que apresentam alto valor para a empresa.
A solicitação recebida foi:
“Quero saber quais clientes mais movimentaram nosso negócio e entender se eles 
realmente possuem um relacionamento recorrente com a empresa.”

Crie uma análise que identifique os clientes que:
* realizaram mais de uma compra;
* possuem um determinado volume mínimo de pedidos;
* apresentam um valor total de compras significativo.

Para cada cliente identificado, apresente informações que permitam avaliar seu 
relacionamento com a empresa, incluindo:
* identificação do cliente;
* nome;
* quantidade de pedidos realizados;
* valor total movimentado.

Ordene o resultado do cliente que mais movimentou financeiramente para o que menos movimentou.

Pergunta de negócio:
Quem são os clientes mais relevantes para a empresa considerando simultaneamente 
frequência de compra e valor movimentado?

Desafio adicional:
Imagine que o gerente peça:
“Não quero clientes que fizeram uma única compra. Quero clientes recorrentes.”
Você deverá decidir como traduzir essa regra de negócio para SQL.
*/
SELECT 
	o.customer_id,
	c.company_name,
	COUNT (DISTINCT o.order_id) AS total_pedidos,
	ROUND (SUM (od.unit_price * od.quantity):: numeric,2) AS valor_total_pedidos
FROM public.orders o
LEFT JOIN public.order_details od
	ON o.order_id = od.order_id
LEFT JOIN public.customers c
	ON o.customer_id = c.customer_id
GROUP BY o.customer_id, c.customer_id
HAVING 
	COUNT (DISTINCT o.order_id) > 10
	AND SUM(od.unit_price * od.quantity) >= 100000
ORDER BY SUM (od.unit_price * od.quantity) DESC
LIMIT 10;

/*Pergunta de negócio:
Selecionado os 10 primeiros cliente com mais de 10 pedidos
Apenas 2 clientes possuem mais de 30 pedidos, porém com valor_total menor que o cliente
QUICK com 28 pedidos.

Top 3 maiores clientes (valor total):
"QUICK"	117483.39
"SAVEA"	115673.39
"ERNSH"	113236.68

Desafio adicional:
Considero cliente recorrente aquele que realizou pelo menos 3 pedidos distribuídos em pelo menos 3 meses diferentes.
*/
SELECT 
    o.customer_id AS id_cliente,
    c.company_name AS nome_cliente,
    COUNT(DISTINCT o.order_id) AS total_pedidos,
    COUNT(DISTINCT DATE_TRUNC('month', o.order_date)) AS meses_com_compra,
    ROUND(SUM(od.unit_price * od.quantity)::numeric, 2) AS valor_total_pedidos
FROM public.orders o
INNER JOIN public.order_details od
    ON o.order_id = od.order_id
INNER JOIN public.customers c
    ON o.customer_id = c.customer_id
GROUP BY 
    o.customer_id,
    c.company_name
HAVING 
    COUNT(DISTINCT o.order_id) >= 3
    AND COUNT(DISTINCT DATE_TRUNC('month', o.order_date)) >= 3
ORDER BY 
    valor_total_pedidos DESC;


-- data minimas e maximas
SELECT
	MIN (order_date),
	MAX (order_date)
FROM public.orders
WHERE customer_id LIKE 'QUICK';




--calculando a média de pedidos pelo total de clientes
SELECT 
    ROUND(
        COUNT(order_id)::numeric /
        COUNT(DISTINCT customer_id)::numeric,
        2
    ) AS media_qtd_pedidos_por_cliente
FROM public.orders;



SELECT * FROM public.customers;
SELECT * FROM public.order_details;
SELECT * FROM public.orders;
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
	tor.order_id AS ordem_venda,
	tor.customer_id AS nome_produto,
	ROUND(SUM (tod.unit_price * tod.quantity)::numeric,2) AS valor_total,
	SUM (tod.quantity) AS quantidade_total
FROM public.orders tor
LEFT JOIN public.order_details tod
	ON tor.order_id = tod.order_id
GROUP BY tor.order_id, tor.customer_id
HAVING SUM (tod.unit_price * tod.quantity) >= '10000' AND SUM (tod.quantity) >= '100'
ORDER BY SUM (tod.unit_price * tod.quantity) DESC;

SELECT * FROM public.order_details;
SELECT * FROM public.orders;



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
	ship_region,
	COUNT (*) AS qtd_pedidos,
	ROUND (SUM (freight):: numeric, 2) AS total_frete,
	ROUND (AVG (freight):: numeric, 2) AS media_frete
FROM public.orders
WHERE required_date BETWEEN '1997-01-01' AND '1997-12-31'
GROUP BY ship_region
ORDER BY AVG (freight) DESC;

-- Pergunta de negócio:
-- Primeiro devemos avaliar a quantidade de pedidos sem região (null) com quase 329 pedidos.
-- As regiões que devem ser avaliadas são ID (média de R$ 175,22), NM (média de R$ 142,88) e
-- Québec (média de R$ 120,52)

-- Desafio adicional:
-- Devem ser avaliados também as regiões com muitos pedidos e alto valor de frente.

SELECT 
	ship_region,
	COUNT (*) AS quantidade
FROM public.orders
GROUP BY ship_region;

SELECT * FROM public.orders;
SELECT * FROM public.territories;





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
HAVING COUNT (DISTINCT o.order_id) > 10
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
Considerando que entre 08/1996 até 04/1998 são 20meses, podemos análisar de forma superficial clientes próximos
de 20 meses de compra.
*/
SELECT 
    o.customer_id,
    c.company_name,
    COUNT(DISTINCT o.order_id) AS total_pedidos,
    COUNT(DISTINCT DATE_TRUNC('month', o.order_date)) AS meses_com_compra,
    ROUND(SUM(od.unit_price * od.quantity)::numeric, 2) AS valor_total_pedidos
FROM public.orders o
LEFT JOIN public.order_details od
    ON o.order_id = od.order_id
LEFT JOIN public.customers c
    ON o.customer_id = c.customer_id
GROUP BY 
    o.customer_id,
    c.company_name
HAVING 
    COUNT(DISTINCT o.order_id) > 1
ORDER BY meses_com_compra DESC
LIMIT 10;


-- data minimas e maximas
SELECT
	MIN (order_date),
	MAX (order_date)
FROM public.orders
WHERE customer_id LIKE 'QUICK';




--calculando a média de pedidos pelo total de clientes
SELECT (
	ROUND((COUNT (order_id):: numeric /
	COUNT (DISTINCT customer_id):: numeric
))) AS media_qtd_pedidos
FROM public.orders;



SELECT * FROM public.customers;
SELECT * FROM public.order_details;
SELECT * FROM public.orders;




-- Atividade Extra
/*Exercício 1 - Clientes em risco
Contexto
O time de relacionamento com clientes percebeu que alguns clientes que costumavam 
comprar com frequência pararam de realizar pedidos.

O gerente quer saber:
"Quais clientes parecem estar perdendo relacionamento com a empresa e 
deveriam ser priorizados pelo time comercial?"

Sua missão
Faça uma análise que permita identificar os clientes que apresentam sinais de perda de relacionamento.
Você deverá decidir quais indicadores fazem sentido para responder à pergunta.

Como ponto de partida, pense em:
* frequência de compras;
* última compra;
* período de relacionamento;
* quantidade de pedidos;
* valor movimentado.

Mas não se limite a esses indicadores.

Pergunta de negócio:
No final, você precisa conseguir responder:
Quais clientes deveriam receber atenção do time comercial e por quê?

Storytelling
Imagine que você terminou a análise e precisa apresentar para o gerente.

Não diga apenas:
"O cliente X fez 5 pedidos."

Tente construir algo como:
"Identificamos um grupo de clientes que historicamente apresentava relacionamento recorrente, 
mas está há um período significativo sem realizar compras. Esses clientes representam X 
em receita histórica e, por isso, deveriam ser priorizados..."

Você deverá chegar aos números que sustentam essa história.


REGRA
Quero que você não abra o PostgreSQL imediatamente.
Antes, escreva no papel/Bloco de Notas:
* OBJETIVO: O que preciso descobrir?
* UNIDADE DE ANÁLISE: Cada linha do resultado representa o quê?
* MÉTRICAS: O que preciso medir?
* DIMENSÕES: Por quais perspectivas devo analisar?
* FILTROS: Existe algum período ou condição?
* RELACIONAMENTOS: Quais informações provavelmente estão em tabelas diferentes?
* COMPARAÇÕES: Com o que devo comparar o resultado?
* PERGUNTA FINAL: O que o gestor realmente quer saber?
Depois disso, aí sim você começa a pensar em SQL.


Primeiro, preciso entender a base de clientes para verificar o que é relacionamento, pode ser:
	* Frequencia de compra considerando meses de compras, ou
	* Frenquencia de compra considerando anos de compras, ou
	* Volume de compra (financeirou ou quantidade de pedidos e produtos)

Analisar a base de pedidos durante os meses/anos, agrupando por cliente.
*/






SELECT * FROM public.order_details;
SELECT * FROM public.orders;


/* Exercício 2 - Produtos que parecem bons, mas precisam de atenção

Contexto:
O gerente de produtos está satisfeito porque alguns produtos apresentam grande volume de vendas.

Porém, ele levantou uma dúvida:
"Será que os produtos que mais vendemos também são os que mais geram receita?"

Ele quer entender se existe alguma diferença entre volume vendido e geração de receita.

Sua missão:
Analise o desempenho dos produtos e identifique situações em que:
* o produto possui alto volume de vendas;
* mas sua participação na receita não acompanha necessariamente esse volume.

Você deverá decidir:
* como medir volume;
* como calcular receita;
* como comparar os produtos;
* como definir o que é "alto";
* como apresentar os resultados.

Pergunta de negócio:
No final, responda:
Quais produtos merecem atenção da área comercial e por qual motivo?

Mas existe uma segunda pergunta:
Existe algum produto que vende muito, mas possui baixo valor financeiro?

Essa segunda pergunta é importante porque pode revelar uma oportunidade de negócio.

Storytelling
Imagine que você está apresentando para o gerente comercial.
Você precisa transformar os dados em uma narrativa:
Situação → descoberta → impacto → recomendação

Por exemplo:
"Inicialmente observamos que determinados produtos possuem grande volume de vendas. 
Entretanto, ao analisar a receita gerada, percebemos que..."
E então você precisa provar a afirmação com os dados.

REGRA
Quero que você não abra o PostgreSQL imediatamente.
Antes, escreva no papel/Bloco de Notas:
* OBJETIVO: O que preciso descobrir?
* UNIDADE DE ANÁLISE: Cada linha do resultado representa o quê?
* MÉTRICAS: O que preciso medir?
* DIMENSÕES: Por quais perspectivas devo analisar?
* FILTROS: Existe algum período ou condição?
* RELACIONAMENTOS: Quais informações provavelmente estão em tabelas diferentes?
* COMPARAÇÕES: Com o que devo comparar o resultado?
* PERGUNTA FINAL: O que o gestor realmente quer saber?
Depois disso, aí sim você começa a pensar em SQL.
*/


/* Exercício 3 - Queda de desempenho comercial
Agora vamos para um caso mais próximo de uma situação real de trabalho.

Contexto:
O diretor comercial recebeu o seguinte relatório:
"A empresa apresentou redução no desempenho de vendas em determinado período."

Ele não quer simplesmente saber quanto vendeu.
Ele quer entender:
"O que está causando essa mudança?"

Sua missão:
Faça uma investigação exploratória para identificar possíveis causas.

Você deverá investigar diferentes perspectivas, como:
* 📅 Tempo: O desempenho mudou ao longo dos períodos?
* 🌎 Região: Existe alguma região apresentando comportamento diferente?
* 👤 Clientes: A quantidade de clientes compradores mudou?
* 📦 Produtos: Alguns produtos passaram a vender menos?
* 💰 Receita: A receita caiu porque:
	* foram vendidos menos produtos?
	* o valor médio das vendas mudou?
	* houve alteração no comportamento dos clientes?
* 🛒 Pedidos: A quantidade de pedidos mudou?


🎯 Entrega do Exercício 3
1️⃣ Análise SQL
Crie as consultas necessárias para investigar o problema.
Você pode fazer várias queries.
Não tente resolver tudo em uma única consulta.

2️⃣ Conclusão analítica
Depois de analisar os resultados, escreva:
"A principal evidência encontrada foi..."
E explique o que os dados mostram.

3️⃣ Storytelling executivo
Imagine que você tem 2 minutos para explicar o problema ao diretor.
Estruture assim:
📌 Contexto: O que estava acontecendo?
🔎 Descoberta: O que você encontrou?
📊 Evidência: Quais números sustentam sua conclusão?
💡 Interpretação: Por que isso é importante?
🎯 Recomendação: O que você sugere que a empresa faça?

REGRA
Quero que você não abra o PostgreSQL imediatamente.
Antes, escreva no papel/Bloco de Notas:
* OBJETIVO: O que preciso descobrir?
* UNIDADE DE ANÁLISE: Cada linha do resultado representa o quê?
* MÉTRICAS: O que preciso medir?
* DIMENSÕES: Por quais perspectivas devo analisar?
* FILTROS: Existe algum período ou condição?
* RELACIONAMENTOS: Quais informações provavelmente estão em tabelas diferentes?
* COMPARAÇÕES: Com o que devo comparar o resultado?
* PERGUNTA FINAL: O que o gestor realmente quer saber?
Depois disso, aí sim você começa a pensar em SQL.
*/

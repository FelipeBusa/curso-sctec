-- EXERCÍCIOS PostgreSQL - Semana 08

-- ===========================================
-- MÓDULO 2 - SELECT FROM - 1. ApostilaPostgreSQL.pdf
/*1) Os analistas de vendas desejam revisar as informações de todas as categorias de
produtos. Faça uma consulta que retorne essas informações. (Utilize a tabela categories)*/
SELECT * FROM public.categories;


/*2) A equipe de logística precisa dos nomes de todos os fornecedores cadastrados no
sistema. Faça uma consulta ao banco de dados que liste todos esses nomes. (Utilize a
tabela suppliers)*/
SELECT DISTINCT
	company_name
FROM public.suppliers;


/*3) A equipe de atendimento deseja analisar os dados de contato de clientes, mas apenas
os 15 primeiros. Faça uma consulta que retorne as colunas contact_name e contact_title
da tabela customers, com limite de 15 registros. (Utilize a tabela customers)*/
SELECT
	company_name,
	contact_title
FROM public.customers
LIMIT 15;


/*4) O time de vendas deseja saber onde os clientes estão localizados. Faça uma consulta
que retorne os nomes únicos de suas cidades. (Utilize a tabela customers)*/
SELECT DISTINCT
	city
FROM public.customers;


/*5) A diretoria quer analisar os diferentes países onde os fornecedores estão localizados.
Crie uma consulta que retorne os nomes distintos desses países. (Utilize a tabela
suppliers)*/
SELECT DISTINCT
	country
FROM public.suppliers;


/*6) A equipe de produtos quer acessar uma lista com os IDs e nomes das categorias, mas
renomeando as colunas para "ID_Categoria" e "Categoria". Construa essa consulta.
(Utilize a tabela categories)*/
SELECT
	category_id AS "ID_Categoria",
	category_name AS "Categoria"
FROM public.categories;


/*7) Os gerentes precisam verificar os nomes completos dos funcionários e seus títulos
(funções) no sistema, com as colunas renomeadas como nome_funcionario,
sobrenome_funcionario e funcao. Crie essa consulta. (Utilize a tabela employees)*/
SELECT
	last_name AS nome_funcionario,
	first_name AS sobrenome_funcionario,
	title AS funcao
FROM public.employees;


/*8) O departamento de recursos humanos precisa verificar os países onde os funcionários
estão registrados, renomeando a coluna para "País". Liste esses valores. (Utilize a tabela
employees)*/
SELECT DISTINCT
	country AS "País"
FROM public.employees;


/*9) A equipe de logística quer verificar os nomes e IDs dos transportadores cadastrados,
renomeando as colunas shipper_id e company_name para português
(ID_Transportadora e Nome_Transportadora, respectivamente). Construa essa consulta.
(Utilize a tabela shippers)*/
SELECT
	shipper_id AS "ID_Transportadora",
	company_name AS "Nome_Transportadora"
FROM public.shippers;


/*10) A equipe administrativa deseja obter os IDs e os nomes dos fornecedores, bem como
seus respectivos países, renomeando as colunas como "ID_Fornecedor", "Fornecedor"
e "País", mas limitando o resultado aos 8 primeiros registros. Crie a consulta que retorna
o resultado esperado. (Utilize a tabela suppliers)*/
SELECT
	supplier_id AS "ID_Fornecedor",
	company_name AS "Fornecedor",
	country AS "País"
FROM public.suppliers
LIMIT 8;


-- ===========================================
-- MÓDULO 3 - FILTROS (WHERE) - 2. ApostilaPostgreSQL.pdf

/* Questão 1. 
O setor de contabilidade está realizando uma revisão das despesas de frete para 
otimizar os custos de transporte. Eles precisam identificar quais pedidos possuem um custo de frete
superior a $100, para verificar se há alguma inconsistência ou oportunidades de redução de custos.
Liste esses pedidos. (Utilize a tabela orders)*/
SELECT *
FROM public.orders
WHERE freight > 100;


/* Questão 2. 
O time de vendas está preparando uma campanha específica para clientes
localizados em Londres. Eles precisam listar os clientes dessa cidade para personalizar ofertas e
promover um atendimento especializado. Crie a consulta que retorne esses clientes que moram em 'London'.
(Utilize a tabela customers)*/
SELECT * 
FROM public.customers
WHERE city = 'London';


/* Questão 3. 
A gerência está fazendo uma análise de desempenho de vendas e logística
de 1998 para entender tendências e padrões históricos. 
Eles precisam listar os pedidos enviados nesse ano para comparar com os
anos seguintes e identificar possíveis melhorias no processo de envio.
Liste os pedidos despachados nesse ano de 1998. (Utilize a tabela orders)*/
SELECT *
FROM public.orders
WHERE shipped_date >= '1998-01-01' AND shipped_date <= '1998-12-31';


/* Questão 4. 
O time de qualidade está revisando os tipos de embalagem dos produtos
para garantir que estão conformes com os padrões de armazenamento e
transporte. Eles precisam identificar os produtos vendidos em pacotes ('pkg') para
fazer essa análise. Liste esses produtos. (Utilize a tabela products)*/
SELECT * 
FROM public.products
WHERE quantity_per_unit LIKE '%pkg%';


/* Questão 5
O setor financeiro está revisando pedidos com frete alto (acima de $200)
ou feitos antes de 1997 para garantir que não haja discrepâncias ou pagamentos indevidos.
Eles precisam identificar essas transações específicas para uma auditoria financeira detalhada.
Liste esses pedidos. (Utilize a tabela orders) */
SELECT * 
FROM public.orders
WHERE freight > 200 OR order_date < '1997-01-01';


/* Questão 6
A equipe de inventário está realizando uma análise de estoque para
identificar produtos de alta demanda e baixo estoque.
Eles querem verificar produtos com preço superior a $40 e estoque
inferior a 50 unidades para planejar reposições e evitar falta de produtos.
Liste esses produtos. (Utilize a tabela products)
 */
SELECT *
FROM public.products
WHERE 
	unit_price > 40 AND
	units_in_stock < 50;


/* Questão 7
O time de suporte ao cliente está tentando filtrar rapidamente empresas
cujo nome começa com 'A' para facilitar um atendimento mais ágil a esses
clientes, que podem ter solicitações prioritárias ou serem parte de uma
campanha especial. Crie uma consulta que retorne esses clientes. (Utilize a tabela
customers) */
SELECT *
FROM public.customers
WHERE company_name LIKE 'A%';


/* Questão 8
A equipe de análise de dados foi informada sobre possíveis
inconsistências em alguns pedidos específicos.
Eles precisam revisar os pedidos com os IDs 10248, 10250 e 10252 para
realizar uma investigação detalhada e corrigir possíveis erros nos
registros.
Crie uma consulta que retorne esses pedidos. (Utilize a tabela orders) */
SELECT *
FROM public.orders
WHERE order_id IN (10248, 10250, 10252);


/* Questão 9
A gerência está fazendo uma análise de vendas e custos do ano de 1996
para entender como as despesas com frete impactaram as margens de
lucro.
Eles precisam identificar pedidos feitos no período de 1996 e com um
custo de frete dentro da faixa de $50 a $150 para realizar comparações e
ajustes nas estratégias.
Crie uma consulta que retorne esses pedidos. (Utilize a tabela orders) */
SELECT *
FROM public.orders
WHERE
	order_date BETWEEN '1996-01-01' AND '1996-12-31'
	AND freight BETWEEN 50 AND 150;


/* Questão 10
O time de marketing está preparando uma campanha direcionada a
clientes específicos do Brasil, Estados Unidos e Canadá, com foco nos
contatos responsáveis pela área de marketing.
Eles precisam listar esses clientes para personalizar a abordagem de
marketing e fortalecer o relacionamento com os gerentes de marketing
('Marketing Manager') e os assistentes de marketing ('Marketing
Assistant').
Crie uma consulta que retorne esses clientes. (Utilize a tabela customers) */
SELECT *
FROM public.customers
WHERE 
	country IN ('Brazil', 'Canada', 'USA')
	AND contact_title IN ('Marketing Manager', 'Marketing Assistant');



-- =================
-- MÓDULO 4 - FUNÇÕES DE AGREGAÇÃO E AGRUPAMENTOS - 3. ApostilaPostgreSQL.pdf

/* Questão 1
A gerência deseja saber quantos fornecedores estão cadastrados no
sistema para avaliar as possibilidades de novas parcerias.
Crie uma consulta que retorne a quantidade total de fornecedores.
(Utilize a tabela suppliers)
*/
SELECT COUNT (supplier_id) AS "TotalFornecerdor"
FROM public.suppliers;


/* Questão 2
O gerente financeiro precisa saber o preço médio dos produtos no
sistema para avaliar o custo médio dos itens vendidos.
Crie uma consulta para calcular a média de preço dos produtos. (Utilize a
tabela products)
*/
SELECT 
	ROUND(AVG (unit_price)::numeric,2) AS "Preco_Médio"
FROM public.products;


/* Questão 3
A equipe de vendas deseja saber qual é o menor e o maior valor de frete
já cobrado em pedidos para entender a variabilidade nos custos de
entrega.
Crie a consulta que retorna esses valores. (Utilize a tabela orders)
*/
SELECT 
	MIN (freight),
	MAX (freight)
FROM public.orders;


/* Questão 4
O setor de Recursos Humanos está realizando um levantamento regional
para identificar a quantidade de funcionários que residem na região
"WA". Essa informação é fundamental para a organização de um evento
corporativo local.
Desenvolva uma consulta que mostre a contagem total de funcionários
nessa região. (Utilize a tabela employees)
*/
SELECT COUNT (region)
FROM public.employees
WHERE region = 'WA';


/* Questão 5
O setor de logística está avaliando o volume de produtos encomendados
que são embalados em garrafas. Para isso, eles precisam saber o total de
unidades desses produtos que estão em pedidos pendentes.
Crie uma consulta que retorne a soma das unidades encomendadas
(units_on_order) de todos os produtos cuja descrição no campo
"quantity_per_unit" mencione "bottles". (Utilize a tabela products)
*/
SELECT SUM (units_on_order)
FROM public.products
WHERE quantity_per_unit LIKE '%bottles';


/* Questão 6
O setor de vendas deseja saber quantos produtos estão disponíveis em
cada categoria.
Crie uma consulta que retorne o ID da categoria e a quantidade de
produtos associados a ela. Ordene o resultado pela contagem da
quantidade de produtos em ordem decrescente. (Utilize a tabela
products)
*/
SELECT 
	category_id,
	COUNT (*)
FROM public.products
GROUP BY category_id 
ORDER BY COUNT (*) DESC;


/* Questão 7
O setor financeiro está analisando os custos logísticos relacionados ao
envio de pedidos para diferentes países. Para isso, eles precisam saber o
total acumulado de frete para cada país de destino, a fim de identificar
quais regiões geram os maiores custos de transporte.
Elabore uma consulta que exiba o nome do país de envio e a soma total
dos fretes, ordenando o resultado do maior para o menor valor. (Utilize a
tabela orders)
*/
SELECT 
	ship_country,
	ROUND(SUM (freight)::numeric,2) AS total_frete
FROM public.orders
GROUP BY ship_country
ORDER BY total_frete DESC;


/* Questão 8
A equipe de gestão de inventário está buscando uma forma de monitorar
o estoque de cada categoria de produtos. Eles precisam entender quantos
produtos existem em cada categoria e qual o total de unidades em
estoque. Esse controle é essencial para que possam planejar
reabastecimentos, identificar possíveis excessos ou faltas de estoque e
tomar decisões informadas sobre estratégias de vendas e promoções.
Crie uma consulta que retorne o ID da categoria, a contagem de produtos
e a soma do estoque por categoria. (Utilize a tabela products)
*/
SELECT 
	category_id,
	COUNT (*) AS total_categoria,
	SUM (units_in_stock) AS total_estoque
FROM public.products
GROUP BY category_id;


/* Questão 9
A equipe de análise de vendas da empresa recebeu uma solicitação para
avaliar o desempenho médio de preço dos produtos nas categorias de
bebidas (category_id = 1) e laticínios (category_id = 4). O objetivo é
entender a variação de preço dessas categorias para tomar decisões
estratégicas sobre promoções e ajustes de preços.
Sua tarefa é criar uma consulta SQL que calcule o preço médio por
unidade para as categorias de bebidas e laticínios, pois isso ajudará a
equipe a tomar futuras decisões comerciais. (Utilize a tabela products)
*/
SELECT 
	category_id AS categoria,
	ROUND(AVG (unit_price)::numeric,2) AS preco_medio
FROM public.products
WHERE category_id IN ('1','4')
GROUP BY categoria;


/* Questão 10
A equipe de vendas da empresa está analisando o desempenho dos
produtos para entender quais itens estão gerando maior volume de
vendas. Para ajudar na tomada de decisões sobre estoque e estratégias
de marketing, eles precisam obter um levantamento detalhado das
quantidades vendidas de cada produto.
Crie uma consulta SQL que retorne a soma total de unidades vendidas
(quantity) por produto, mas somente para os produtos que já alcançaram
no mínimo 1000 unidades vendidas. A consulta deve exibir os produtos
com o maior volume de vendas primeiro, para que a equipe de vendas
possa priorizar os itens mais vendidos. (Utilize a tabela order_details)
*/
SELECT 
	product_id AS prod_ID,
	SUM(quantity) AS quantidade
FROM public.order_details
GROUP BY product_id
HAVING SUM(quantity) >= '1000'
ORDER BY quantidade DESC;
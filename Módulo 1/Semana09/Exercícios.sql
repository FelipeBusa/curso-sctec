-- EXERCÍCIOS

-- SEMANA 09
-- MÓDULO 4 - FUNÇÕES DE AGREGAÇÃO E AGRUPAMENTOS - 4. ApostilaPostgreSQL.pdf
/* Questão 1
A gerência deseja saber quantos fornecedores estão cadastrados no
sistema para avaliar as possibilidades de novas parcerias.
Crie uma consulta que retorne a quantidade total de fornecedores.
(Utilize a tabela suppliers)*/
SELECT COUNT(*) AS total_fornecedores
FROM suppliers;


/* Questão 2
O gerente financeiro precisa saber o preço médio dos produtos no
sistema para avaliar o custo médio dos itens vendidos.
Crie uma consulta para calcular a média de preço dos produtos. (Utilize a
tabela products)
*/
SELECT AVG (unit_price) AS preco_medio_produtos
FROM products;


/* Questão 3
A equipe de vendas deseja saber qual é o menor e o maior valor de frete
já cobrado em pedidos para entender a variabilidade nos custos de
entrega.
Crie a consulta que retorna esses valores. (Utilize a tabela orders)
*/
SELECT
	MIN (freight) AS menor_frete,
	MAX (freight) AS maior_frete
FROM orders;


/* Questão 4
O setor de Recursos Humanos está realizando um levantamento regional
para identificar a quantidade de funcionários que residem na região
"WA". Essa informação é fundamental para a organização de um evento
corporativo local.
Desenvolva uma consulta que mostre a contagem total de funcionários
nessa região. (Utilize a tabela employees)
*/
SELECT COUNT(*) AS funcionarios_em_wa
FROM employees
WHERE region = 'WA';


/* Questão 5
O setor de logística está avaliando o volume de produtos encomendados
que são embalados em garrafas. Para isso, eles precisam saber o total de
unidades desses produtos que estão em pedidos pendentes.
Crie uma consulta que retorne a soma das unidades encomendadas
(units_on_order) de todos os produtos cuja descrição no campo
"quantity_per_unit" mencione "bottles". (Utilize a tabela products)
*/
SELECT SUM (units_on_order) AS total_encomendado
FROM products
WHERE quantity_per_unit LIKE '%bottles%';


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
	COUNT (*) AS quantidade_produtos
FROM products
GROUP BY category_id
ORDER BY quantidade_produtos DESC;


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
	SUM (freight) AS total_frete
FROM orders
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
	COUNT(*) AS qtd_produtos_categoria,
SUM (units_in_stock) AS estoque_total
FROM products
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
	category_id,
	AVG (unit_price)
FROM products
WHERE category_id IN (1, 4)
GROUP BY category_id;


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
	product_id AS id_produto,
	SUM (quantity) AS total_vendido
FROM order_details
GROUP BY product_id
HAVING SUM (quantity) >= 1000
ORDER BY total_vendido DESC;



-- MÓDULO 5- JOINS - 5. ApostilaPostgreSQL.pdf
/* Questão 1
A equipe de compras está analisando os fornecedores para otimizar a
logística de importação e transporte. Eles precisam saber em quais países
estão localizados os fornecedores dos produtos disponíveis no estoque.
Essa informação será usada para negociar melhores condições de frete
internacional e tempo de entrega.
Crie uma consulta usando um LEFT JOIN para mostrar o nome do
produto, o nome do fornecedor e o país do fornecedor. (Utilize as tabelas
products e suppliers) */
SELECT
	tp.product_name AS "Nome_Produto",
	ts.company_name AS "Nome_Fornecedor",
	ts.country AS "Pais_Fornecedor"
FROM public.products tp
LEFT JOIN public.suppliers ts
	ON tp.supplier_id = ts.supplier_id;


/*
Questão 2-a
O setor de análise está desenvolvendo um relatório de fidelidade para
identificar os clientes mais engajados com a empresa. Eles precisam saber
quantos pedidos cada cliente realizou para criar estratégias
personalizadas de retenção, como programas de benefícios e descontos
progressivos.
Crie uma consulta que mostre o ID do cliente, o nome do cliente e a
quantidade total de pedidos realizados por cliente. Ordene a consulta do
cliente que mais efetuou pedidos para o que menos comprou na empresa.
(Utilize as tabelas customers e orders)
*/
SELECT 
	tc.customer_id AS "ID_Cliente",
	tc.company_name AS "Nome_Cliente",
	COUNT (tor.order_id) AS "Total_Pedidos"
FROM public.customers tc
LEFT JOIN public.orders tor
	ON tc.customer_id = tor.customer_id
GROUP BY tc.customer_id, tc.company_name
ORDER BY "Total_Pedidos" DESC;


/*
Questão 2-b
Existem clientes que ainda não efetuaram nenhum pedido e o setor de
análise também deseja identificá-los, com o objetivo de direcionar
campanhas de marketing específicas para motivá-los a realizar suas
primeiras compras.
Altere o código do item A para retornar apenas esses clientes. (Utilize as
tabelas customers e orders)
*/
SELECT 
	tc.customer_id AS "ID_Cliente",
	tc.company_name AS "Nome_Cliente",
	COUNT (tor.order_id) AS "Total_Pedidos"
FROM public.customers tc
LEFT JOIN public.orders tor
	ON tc.customer_id = tor.customer_id
GROUP BY tc.customer_id, tc.company_name
HAVING COUNT (tor.order_id) = '0';


/*
Questão 2-c
A equipe de análise também quer avaliar o mercado nacional e entender o
comportamento de compra dos clientes brasileiros. Eles precisam de um
relatório que mostre a quantidade de pedidos efetuados apenas por
clientes localizados no Brasil, ajudando a ajustar estratégias de vendas
locais.
Altere a consulta do item A para que retorne o resultado esperado.
(Utilize as tabelas customers e orders)
*/
SELECT 
	tc.customer_id AS "ID_Cliente",
	tc.company_name AS "Nome_Cliente",
	tc.country AS "Pais_Cliente",
	COUNT (tor.order_id) AS "Total_Pedidos"
FROM public.customers tc
LEFT JOIN public.orders tor
	ON tc.customer_id = tor.customer_id
WHERE tc.country = 'Brazil'
GROUP BY tc.customer_id, tc.company_name
ORDER BY COUNT (tor.order_id) DESC;


/*
Questão 3
O setor financeiro está criando um relatório para monitorar a
rentabilidade por cliente. Eles precisam calcular a receita total gerada por
cada cliente com base nos pedidos realizados. Essa informação será
utilizada para identificar os clientes mais lucrativos e propor ações de
fidelização específicas.
Crie uma consulta que liste o ID do cliente, o nome do cliente e a receita
de seus pedidos (unit_price * quantity). Dica: você precisará fazer dois
INNER JOINs nesta consulta. (Utilize as tabelas customers, orders e
order_details)
*/
SELECT 
	tc.customer_id,
	tc.company_name,
	SUM (tod.unit_price * tod.quantity) AS total_receita
FROM public.customers tc
INNER JOIN public.orders tor
	ON tc.customer_id = tor.customer_id
	INNER JOIN public.order_details tod
		ON tor.order_id = tod.order_id
GROUP BY tc.customer_id, tc.company_name;

	
/*
Questão 4
O setor de atendimento ao cliente está analisando o comportamento de
clientes que realizam mais de uma compra no mesmo dia. Eles querem
identificar esses padrões para propor soluções que melhorem a
experiência do cliente, como combos de produtos ou programas de
assinatura.
Crie uma consulta que retorne o nome do cliente e a data do pedido
quando o cliente tiver realizado mais de um pedido na mesma data.
(Utilize as tabelas orders e customers)
*/
SELECT 
	tc.company_name,
	tor.order_date,
	COUNT (tor.order_id) AS total_pedidos
FROM orders tor
INNER JOIN customers tc
	ON tor.customer_id = tc.customer_id
GROUP BY tc.company_name, tor.order_date
HAVING COUNT (tor.order_id) >1;


/*
Questão 5
A equipe financeira quer priorizar negociações com fornecedores que
oferecem produtos com preços médios acima de R$30. Esses
fornecedores serão tratados como parceiros estratégicos para produtos
de maior valor agregado, visando maximizar a margem de lucro da
empresa.
Crie uma consulta que retorne o nome do fornecedor e a média de preço
dos produtos fornecidos, considerando apenas os fornecedores cuja
média de preço seja superior a R$30. (Utilize as tabelas products e
suppliers)
*/
SELECT
	s.company_name,
	AVG (p.unit_price) AS preco_medio
FROM products p
INNER JOIN suppliers s
	ON p.supplier_id = s.supplier_id
GROUP BY s.company_name
HAVING AVG (p.unit_price) > 30;


/*
Questão 6
A gerência deseja premiar os funcionários que gerenciaram mais de 10
pedidos ao longo do ano de 1997 como forma de motivação e
reconhecimento. Para isso, eles precisam de um relatório detalhado com
os nomes dos colaboradores e o número total de pedidos gerenciados por
cada um.
Crie uma consulta que liste os nomes completos dos funcionários e a
quantidade total de pedidos que cada um gerenciou em 1997, ordenados
do maior para o menor número de pedidos. Considere apenas os
funcionários com mais de 10 pedidos. (Utilize as tabelas orders e
employees)
*/
SELECT
	e.first_name,
	e.last_name,
	COUNT (o.order_id) AS total_pedidos
FROM orders o
INNER JOIN employees e
	ON o.employee_id = e.employee_id
WHERE o.order_date BETWEEN '1997-01-01' AND '1997-12-31'
GROUP BY e.first_name, e.last_name
HAVING COUNT (o.order_id) > 10
ORDER BY total_pedidos DESC;


/*
Questão 7
A equipe de logística está avaliando o desempenho das transportadoras
para otimizar as operações de entrega. Eles precisam identificar quais
transportadoras realizaram mais entregas nos últimos meses para
manter ou renegociar contratos baseados em volume e eficiência.
Liste os nomes das transportadoras e a quantidade de pedidos entregues
por cada uma. Ordene o resultado pela quantidade de pedidos em ordem
decrescente. (Utilize as tabelas orders e shippers)
*/
SELECT
	s.company_name,
	COUNT (o.order_id) AS total_pedidos
FROM orders o
	RIGHT JOIN shippers s ON o.ship_via = s.shipper_id
GROUP BY s.company_name
ORDER BY total_pedidos DESC;


/*
Questão 8
A diretoria quer identificar quais categorias de produtos geraram o maior
valor médio de vendas por produto. Esse relatório será usado para decidir
em quais categorias investir mais em marketing, promoções e estoque,
maximizando o retorno financeiro.
Liste os nomes das categorias e o valor médio das vendas por categoria
(média de unit_price * quantity). Ordene os resultados pelo valor médio
em ordem decrescente. Dica: você precisará fazer dois INNER JOINS
nesta consulta. (Utilize as tabelas order_details, products e categories)
*/
SELECT
	c.category_name,
AVG (od.unit_price * od.quantity) AS media_vendas
FROM order_details od
INNER JOIN products p 
	ON od.product_id = p.product_id
	INNER JOIN categories c
		ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY media_vendas DESC;



-- ========================
-- MODULO 6 - VIEWS - 6. ApostilaPostgreSQL.pdf
/*
Questão 1
A equipe de vendas frequentemente precisa entrar em contato com os
clientes para discutir propostas ou resolver problemas relacionados a
pedidos. Para facilitar esse processo, é necessário ter acesso rápido às
informações de contato de cada cliente.
Crie uma view chamada vw_clientes_contato que retorne o ID, o nome da
empresa, o nome do contato, a função do contato e o telefone de todos os
clientes. (Utilize a tabela customers)
*/
CREATE OR REPLACE VIEW vw_clientes_contato AS
SELECT
	customer_id AS "ID_Cliente",
	company_name AS "Nome_Empresa",
	contact_name AS "Nome_Contato",
	contact_title AS "Função_Contato",
	phone AS "Telefone"
FROM public.customers;

SELECT * FROM vw_clientes_contato;

/*
Questão 2
O setor de logística tem enfrentado desafios para equilibrar os níveis de
estoque das diferentes categorias de produtos. Para otimizar a reposição
e evitar excessos ou faltas, eles precisam de uma visão consolidada que
relacione cada categoria à quantidade total de itens em estoque.
Crie uma view chamada vw_estoque_por_categoria para atender a essa
necessidade. (Utilize as tabelas categories e products)
*/
CREATE OR REPLACE VIEW vw_estoque_por_categoria AS
SELECT
	pd.category_id AS "ID_Categoria",
	ct.category_name AS "Nome_Categoria",
	SUM (pd.units_in_stock) AS "Unidade_Estoque"
FROM public.products pd
LEFT JOIN public.categories ct
	ON pd.category_id = ct.category_id
GROUP BY pd.category_id,ct.category_name
ORDER BY pd.category_id;

SELECT * FROM public.vw_estoque_por_categoria;


/*Questão 3
O gerente comercial está focado em entender o desempenho do mercado
na América do Norte (México, EUA e Canadá). Isso inclui monitorar os
pedidos realizados por clientes dessa região, identificando padrões de
consumo e áreas de potencial crescimento.
Crie uma view chamada vw_pedidos_america_norte para retornar o ID e a
data do pedido, o nome e o país do cliente, considerando-se somente os
países da América do Norte. (Utilize as tabelas orders e customers)
*/
CREATE OR REPLACE VIEW vw_pedidos_america_norte AS
SELECT
	ord.order_id AS "ID_PEDIDO",
	ord.order_date AS "DATA_PEDIDO",
	ct.company_name AS "NOME_CLIENTE",
	ct.country AS "PAÍS_CLIENTE"
FROM public.orders ord
LEFT JOIN public.customers ct
	ON ord.customer_id = ct.customer_id
WHERE ct.country  IN ('USA', 'Mexico', 'Canada');

SELECT * FROM public.vw_pedidos_america_norte;
DROP VIEW public.vw_pedidos_america_norte;


/*Questão 4
O gerente deseja ter acesso rápido aos pedidos mais recentes para
acompanhar o fluxo de vendas e identificar tendências ou possíveis
gargalos no processo de pedidos.
Crie uma view chamada vw_ultimos_pedidos para atender a esse pedido.
(Utilize a tabela orders)
*/
CREATE OR REPLACE VIEW vw_ultimos_pedidos AS
SELECT 
	*
FROM public.orders
ORDER BY order_date DESC
LIMIT 5;

SELECT * FROM public.vw_ultimos_pedidos;


/*Questão 5
A equipe de vendas está priorizando clientes que geram alto volume de
receita. Por isso, é essencial identificar aqueles cujos pedidos somam uma
receita total acima de R$30.000, para oferecer um atendimento mais
dedicado e estratégico.
Crie uma view chamada vw_clientes_receita_total para exibir esses
clientes e suas respectivas receitas totais (soma de unit_price * quantity).
(Utilize as tabelas customers, orders e orders_details)
*/
CREATE OR REPLACE VIEW vw_clientes_receita_total AS
SELECT
	c.customer_id,
	c.company_name,
	SUM (od.unit_price * od.quantity) AS receita_total
FROM public.customers c
INNER JOIN public.orders o
	ON c.customer_id = o.customer_id
INNER JOIN public.order_details od
	ON o.order_id = od.order_id
GROUP BY c.customer_id, c.company_name
HAVING SUM (od.unit_price * od.quantity) > 30000;

SELECT * FROM vw_clientes_receita_total;


/*Questão 6
O setor de análise está conduzindo uma pesquisa para entender quais
categorias de produtos têm maior representatividade no portfólio. Essa
informação ajudará a direcionar esforços de marketing e otimizar o mix
de produtos oferecidos.
Crie uma view chamada vw_top5_categorias para exibir as cinco
categorias com maior quantidade de produtos. (Utilize as tabelas
categories e products)
*/
CREATE OR REPLACE VIEW vw_top5_categorias AS
SELECT
	c.category_name,
	COUNT (p.product_id) AS total_produtos
FROM public.categories c
INNER JOIN public.products p
	ON c.category_id = p.category_id
GROUP BY c.category_name
ORDER BY total_produtos DESC
LIMIT 5;

SELECT* FROM vw_top5_categorias;


/*Questão 7-a
A gerência quer identificar os mercados mais lucrativos ao redor do
mundo. Para isso, é necessário calcular a média de vendas por país,
permitindo que os recursos sejam direcionados para os mercados com
maior retorno financeiro.
Crie uma view chamada vw_media_vendas_dos_paises que mostre os
nomes dos países e suas respectivas medias de vendas (média de quantity
* unit_price). (Utilize as tabelas orders e order_details)
*/
CREATE OR REPLACE VIEW vw_media_vendas_dos_paises AS
SELECT
	o.ship_country,
	AVG (od.quantity * od.unit_price) AS media_vendas
FROM public.orders o
INNER JOIN public.order_details od
	ON o.order_id = od.order_id
GROUP BY o.ship_country
ORDER BY media_vendas DESC;

SELECT * FROM vw_media_vendas_dos_paises;


/*Questão 7-b
Para facilitar a comunicação entre os setores, o nome da view criada no
item A dever ser ajustado para um padrão que reflete melhor seu
propósito: vw_media_vendas_por_pais.
Faça essa alteração no banco de dados. (Não é necessário utilizar
tabelas)
*/
ALTER VIEW vw_media_vendas_dos_paises
RENAME TO vw_media_vendas_por_pais;

SELECT * FROM vw_media_vendas_por_pais;


/*Questão 8
A diretoria quer analisar os pedidos realizados no ano de 1998 para
identificar tendências históricas e avaliar o desempenho da empresa em
períodos passados, o que pode ajudar na projeção de vendas futuras.
Crie uma view chamada vw_pedidos_1998 para listar esses pedidos.
(Utilize a tabela orders)
*/
CREATE OR REPLACE VIEW vw_pedidos_1998 AS
SELECT
	order_id,
	customer_id,
	order_date
FROM public.orders
WHERE order_date BETWEEN '1998-01-01' AND '1998-12-31';

SELECT * FROM vw_pedidos_1998;


/*Questão 9
Exclua todas as views criadas nesta lista de exercícios:
vw_clientes_contato
vw_estoque_por_categoria
vw_pedidos_america_norte
vw_ultimos_pedidos
vw_clientes_receita_total
vw_top5_categorias
vw_media_vendas_por_pais
vw_pedidos_1998
(Não é necessário utilizar tabelas)
*/

DROP VIEW IF EXISTS vw_clientes_contato;
DROP VIEW IF EXISTS vw_estoque_por_categoria;
DROP VIEW IF EXISTS vw_pedidos_america_norte;
DROP VIEW IF EXISTS vw_ultimos_pedidos;
DROP VIEW IF EXISTS vw_clientes_receita_total;
DROP VIEW IF EXISTS vw_top5_categorias;
DROP VIEW IF EXISTS vw_media_vendas_por_pais;
DROP VIEW IF EXISTS vw_pedidos_1998;
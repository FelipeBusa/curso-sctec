-- EXERCÍCIOS

-- MÓDULO 7 - CRUD - 7. ApostilaPostgreSQL.pdf
/* Questão 1
Você foi contratado para realizar testes iniciais em um ambiente de
desenvolvimento do Hotel XXXX Para garantir que o sistema está
configurado corretamente, siga os passos abaixo:
Crie um banco de dados chamado dbTeste;
Após, exclua-o completamente.
*/
CREATE DATABASE dbTeste;
DROP DATABASE dbTeste;


/* Questão 2
O Hotel XXXX está modernizando seu sistema de gestão e decidiu
implementar um banco de dados para gerenciar as informações de seus
clientes, quartos e estadias.
Para isso, crie um banco de dados chamado dbHote XXXX que será
utilizado para centralizar e organizar todas as informações necessárias
para a operação eficiente do hotel.
*/
CREATE DATABASE dbHote;

/* Questão 3a
Com o banco de dados dbHote XXXX em uso, crie as seguintes tabelas:
a) Tabela clientes
*/
CREATE TABLE clientes (
	id_cliente INT,
	nome VARCHAR (100) NOT NULL,
	email VARCHAR (50) NOT NULL,
	data_nascimento DATE,
	PRIMARY KEY (id_cliente)
);


/* Questão 3b
Com o banco de dados dbHote XXXX em uso, crie as seguintes tabelas:
b) Tabela quartos
*/
CREATE TABLE quartos (
	id_quarto INT,
	tipo VARCHAR (30) NOT NULL,
	qtd_pessoas INT NOT NULL,
	preco_diaria NUMERIC(10, 2) NOT NULL,
	PRIMARY KEY (id_quarto)
);


/* Questão 3c
Com o banco de dados dbHote XXXX em uso, crie as seguintes tabelas:
a) Tabela estadias
*/
CREATE TABLE estadias (
	id_estadia INT,
	id_cliente INT NOT NULL,
	id_quarto INT NOT NULL,
	data_entrada TIMESTAMP NOT NULL,
	data_saida TIMESTAMP,
	PRIMARY KEY (id_estadia),
	FOREIGN KEY (id_cliente) REFERENCES clientes (id_cliente),
	FOREIGN KEY (id_quarto) REFERENCES quartos (id_quarto)
);


/* Questão 4a
Agora que as tabelas foram criadas, insira os dados dos clientes, quartos e
estadias:
a) Insira 10 clientes na tabela clientes e faça uma consulta para verificar
se os dados foram inseridos corretamente:
*/
INSERT INTO clientes (id_cliente, nome, email, data_nascimento) VALUES
(1, 'Ana Silva', 'ana.silva@email.com', '1990-03-15'),
(2, 'Carlos Souza', 'carlos.souza@email.com', '1985-07-20'),
(3, 'Maria Oliveira', 'maria.oliveira@email.com', '1993-11-05'),
(4, 'João Santos', 'joao.santos@email.com', '1978-02-25'),
(5, 'Beatriz Lima', 'beatriz.lima@email.com', '2000-01-12'),
(6, 'Lucas Alves', 'lucas.alves@email.com', NULL),
(7, 'Fernanda Rocha', 'fernanda.rocha@email.com', '1995-06-10'),
(8, 'Gabriel Mendes', 'gabriel.mendes@email.com', '1989-08-08'),
(9, 'Sofia Costa', 'sofia.costa@email.com', '1991-12-24'),
(10, 'Rafael Silva', 'rafael.silva@email.com', '1997-04-18');

SELECT * FROM clientes;

/* Questão 4b
Agora que as tabelas foram criadas, insira os dados dos clientes, quartos e
estadias:
b) Insira 10 quartos na tabela quartos e faça uma consulta para verificar
se os dados foram inseridos corretamente:
*/
INSERT INTO quartos (id_quarto, tipo, qtd_pessoas, preco_diaria) VALUES
(1, 'Single', 1, 150.00),
(2, 'Double', 2, 250.00),
(3, 'Suite', 4, 500.00),
(4, 'Single', 1, 140.00),
(5, 'Double', 2, 230.00),
(6, 'Suite', 4, 550.00),
(7, 'Single', 1, 160.00),
(8, 'Double', 2, 240.00),
(9, 'Suite', 4, 600.00),
(10, 'Single', 1, 170.00);

SELECT * FROM quartos;


/* Questão 4c
Agora que as tabelas foram criadas, insira os dados dos clientes, quartos e
estadias:
c) Insira 15 estadias na tabela estadias e faça uma consulta para verificar
se os dados foram inseridos corretamente:
*/
INSERT INTO estadias (id_estadia, id_cliente, id_quarto, data_entrada, data_saida) VALUES
(1, 1, 2, '2024-01-15 14:00:00', '2024-01-16 12:00:00'),
(2, 3, 5, '2024-02-16 16:00:00', '2024-02-18 11:00:00'),
(3, 4, 1, '2024-03-17 13:00:00', '2024-03-19 11:00:00'),
(4, 2, 3, '2024-04-18 15:00:00', '2024-05-10 10:00:00'),
(5, 5, 7, '2024-05-19 12:30:00', '2024-05-23 12:00:00'),
(6, 6, 9, '2024-06-20 18:00:00', '2024-06-22 14:00:00'),
(7, 8, 4, '2024-07-21 11:00:00', '2024-07-23 09:00:00'),
(8, 9, 10, '2024-08-22 14:00:00', '2024-08-24 12:00:00'),
(9, 7, 6, '2024-09-23 10:00:00', '2024-09-26 10:00:00'),
(10, 10, 8, '2024-10-24 16:00:00', '2024-11-06 11:00:00'),
(11, 1, 5, '2024-11-25 13:00:00', '2024-11-27 10:00:00'),
(12, 3, 2, '2024-12-26 17:00:00', '2024-12-28 13:00:00'),
(13, 4, 1, '2024-12-27 12:00:00', NULL),
(14, 8, 7, '2024-12-28 15:00:00', NULL),
(15, 9, 3, '2024-12-29 14:00:00', NULL);

SELECT * FROM estadias;


/* Questão 5
O cliente da estadia de id_estadia = 13 desocupou o quarto em
04/01/2025 ao meio-dia.
Atualize a tabela para fazer constar essa informação.
*/
UPDATE estadias
SET data_saida = '2025-01-04 12:00:00'
WHERE id_estadia = 13;

SELECT * FROM estadias;


/* Questão 6
A cliente Beatriz Lima (id_cliente = 5) solicitou a exclusão de seus dados
de nosso banco de dados. Como esta cliente se hospedou no hotel
anteriormente, ela está referenciada na tabela estadias. Portanto, é
necessário seguir os seguintes passos para realizar a exclusão de seus
dados:
a) Excluir a(s) estadia(s) que faz(em) referência a esta cliente na
tabela estadias.
b) Após a exclusão das estadias, excluir a cliente Beatriz Lima
(id_cliente = 5) da tabela clientes.
*/
DELETE FROM estadias
WHERE id_cliente = 5;

SELECT * FROM estadias;

DELETE FROM clientes
WHERE id_cliente = 5;

SELECT FROM clientes;


/* Questão 7
A gerência do Hotel XXXX decidiu iniciar um novo ano fiscal
reorganizando o sistema e limpando os registros antigos de estadias. Isso
permitirá começar o ano com dados atualizados e espaço no banco de
dados para novos registros. O backup dos registros do ano anterior já foi
efetuado para que os dados não sejam perdidos.
Agora, você já pode esvaziar todos os registros da tabela estadias,
garantindo que a estrutura da tabela seja mantida.
*/
TRUNCATE TABLE estadias;


/* Questão 8
Após uma reestruturação no sistema de TI, o Hotel XXXX contratou um
novo software que substituirá o atual banco de dados. Todos os dados do
dbHote XXXX já foram migrados para esse novo software.
Agora, como parte da transição, as tabelas clientes, quartos e estadias
precisam ser excluídas completamente, removendo qualquer
dependência existente. Realize essa exclusão.
*/
DROP TABLE clientes CASCADE;
DROP TABLE quartos CASCADE;
DROP TABLE estadias CASCADE;



-- MÓDULO 8 - FUNÇÖES DE NÚMERO, TEXTO E DATA - 8. ApostilaPostgreSQL.pdf
/* Questão 1
O setor financeiro está revisando os custos logísticos da empresa para
identificar oportunidades de redução de despesas. Como parte dessa
análise, é necessário calcular o valor médio dos fretes para compor um
relatório de auditoria que será enviado à diretoria.
Calcule o valor médio de frete e arredonde para duas casas decimais.
(Utilize a tabela orders)
*/
SELECT
	ROUND (CAST (AVG (freight) AS NUMERIC), 2) AS media_frete
FROM orders;


/* Questão 2
A equipe de vendas está preparando a integração com uma nova
plataforma de e-commerce que exige que todas as descrições de
categorias estejam padronizadas, com apenas a primeira letra de cada
palavra em maiúscula. Além disso, há um limite de caracteres por
descrição, que precisa ser respeitado para evitar problemas de
visualização no site.
Mostre as categorias de produtos, suas descrições com a formatação
padronizada (primeira letra de cada palavra em maiúscula) e o número
total de caracteres de cada descrição. (Utilize a tabela categories)
*/
SELECT
	category_name,
	INITCAP (description) AS descricao_formatada,
LENGTH (description) AS qtd_caracteres_descricao
FROM categories;


/* Questão 3
O departamento de Recursos Humanos está atualizando os registros
para tornar os cargos dos funcionários mais inclusivos e alinhados com as
diretrizes globais da empresa. Um dos ajustes inclui substituir o termo
"Sales Representative" por "Salesperson" nos registros dos
colaboradores.
Liste os IDs, os nomes e sobrenomes, bem como os cargos dos
funcionários, efetuando a substituição solicitada. (Utilize a tabela
employees)
*/
SELECT
	employee_id,
	first_name,
	last_name,
	title,
	REPLACE (title, 'Sales Representative', 'Salesperson') AS titulo_alterado
FROM employees;


/* Questão 4
A equipe de marketing está planejando uma campanha personalizada de
e-mails, onde será necessário utilizar os nomes dos contatos dos clientes
em diferentes formatos. Isso permitirá criar mensagens com maior
impacto e personalização, aumentando as chances de engajamento.
Liste os contatos dos clientes, uma vez em letras maiúsculas e outra em
letras minúsculas. (Utilize a tabela customers)
*/
SELECT
	contact_name,
	UPPER (contact_name) AS nome_maiusculo,
	LOWER (contact_name) AS nome_minusculo
FROM customers;


/* Questão 5
A equipe de TI foi acionada para implementar um sistema que identifique
rapidamente as regiões de entrega dos clientes, baseando-se nos dois
primeiros caracteres do código postal. Essa informação ajudará a logística
a planejar rotas de forma mais eficiente.
Extraia os dois primeiros caracteres do campo postal_code dos clientes.
(Utilize a tabela customers)
*/
SELECT
	customer_id,
	postal_code,
	SUBSTRING (postal_code, 1, 2) AS regiao
FROM customers;


/* Questão 6
O setor financeiro precisa calcular os valores totais das ordens para fins
de faturamento. Como parte dessa tarefa, é necessário que os valores
sejam sempre arredondados para cima, garantindo que nenhuma fração
de centavo seja perdida no processo de cobrança.
Exiba o valor total de cada ordem, calculado pela soma de unit_price*
quantity, arredondado para cima. (Utilize a tabela order_details)
*/
SELECT
	order_id,
	SUM (unit_price * quantity) AS total,
	CEILING (SUM (unit_price * quantity)) AS total_arredondado
FROM order_details
GROUP BY order_id;

/* Questão 7
O time de marketing está organizando uma campanha especial para
promover produtos orgânicos. Para isso, é necessário localizar os
produtos que possuem o termo "Organic" no nome, permitindo que a
equipe foque seus esforços exclusivamente nesses itens.
Localize a posição do termo "Organic" nos nomes dos produtos,
retornando somente os produtos cujo termo seja encontrado. (Utilize a
tabela products)
*/
SELECT
	product_id,
	product_name,
	STRPOS (product_name, 'Organic') AS posicao_organic
FROM products
WHERE STRPOS (product_name, 'Organic') > 0;


/* Questão 8
Para criar um ambiente de trabalho mais acolhedor, o setor de Recursos
Humanos está organizando uma campanha para celebrar os
aniversariantes do mês. A identificação dos aniversariantes permitirá a
criação de mensagens personalizadas e a inclusão desses dados no mural
de aniversários da empresa.
Crie uma consulta que exiba os IDs, nomes, sobrenomes, datas de
nascimento e a idade dos funcionários que fazem aniversário no mês
corrente. Além disso, inclua a data atual na consulta para referência.
(Utilize a tabela employees)
*/
SELECT
	employee_id,
	first_name,
	last_name,
	birth_date,
	CURRENT_DATE AS data_atual,
	AGE (birth_date)
FROM employees
WHERE DATE_PART ('month', birth_date) = DATE_PART('month', CURRENT_DATE);


/* Questão 9
O setor de estoque precisa calcular o número máximo de pacotes
completos que podem ser formados com os produtos disponíveis. Cada
pacote deve conter exatamente 10 unidades de um mesmo produto, e é
necessário considerar que não é possível formar pacotes incompletos
com as unidades restantes.
Liste os nomes dos produtos, suas quantidades em estoque e o número
máximo de pacotes completos que podem ser formados, levando em
consideração a quantidade disponível de cada produto. (Utilize a tabela
products)
*/
SELECT
	product_name,
	units_in_stock,
	FLOOR (units_in_stock / 10) AS pacotes_completos
FROM products;


/* Questão 10
O setor financeiro está preparando um relatório detalhado sobre os
descontos aplicados aos pedidos, que será utilizado em uma reunião
estratégica com a diretoria. Para maior precisão, é necessário apresentar
a média dos descontos truncada para três casas decimais, sem
arredondamentos, garantindo a exatidão dos dados analisados.
Crie uma consulta que exiba a média dos valores de desconto em todos os
pedidos, mostrando o valor original e o valor com três casas decimais sem
arredondamentos. (Utilize a tabela order_details)
*/
SELECT
	AVG (discount) AS media_desconto,
	TRUNC (CAST (AVG (discount) AS NUMERIC), 3) AS media_desconto_truncada
FROM order_details;



-- MÓDULO 9 - SUBQUERIES - 9. ApostilaPostgreSQL.pdf
/* Questão 1
A equipe de marketing deseja identificar clientes fiéis, ou seja, aqueles
que realizaram mais de uma compra. Esses clientes podem ser alvo de
programas de fidelidade ou ofertas exclusivas, aumentando o
engajamento e as vendas.
Crie uma consulta que liste os IDs, nomes das empresas, nomes e cargos
dos contatos e telefones desses clientes. (Utilize as tabelas customers e
orders)
*/
SELECT
	customer_id,
	company_name,
	contact_name,
	contact_title,
	phone
FROM public.customers
WHERE customer_id IN (
		SELECT customer_id
		FROM public.orders
		GROUP BY customer_id
		HAVING COUNT (*) > 1);


/* Questão 2
A gerência quer analisar o perfil médio de compras dos clientes para
ajustar suas estratégias de vendas. Saber quantos pedidos, em média,
cada cliente faz ajuda a determinar se é necessário investir em retenção,
campanhas promocionais ou incentivos para compras recorrentes.
Crie uma consulta que retorne a média de pedidos feitos por cliente.
(Utilize a tabela orders)
*/
-- Select da subquerie
SELECT
	customer_id,
	COUNT (order_id) AS total_pedidos
FROM orders
GROUP BY customer_id;


-- Select completo
SELECT
AVG (total_pedidos)
FROM (
	SELECT
		customer_id,
		COUNT (order_id) AS total_pedidos
	FROM orders
	GROUP BY customer_id
) t;


/* Questão 3
O setor de Recursos Humanos deseja homenagear o funcionário mais
antigo da empresa em um evento corporativo. Além disso, essa
informação pode ser útil para análises sobre retenção de talentos e
políticas de valorização profissional.
Crie uma consulta que retorne o ID, nome e sobrenome, bem como a data
da contratação desse(a) funcionário(a) que está há mais tempo na
empresa. (Utilize a tabela employees)
*/
-- Select da Subquerie
SELECT
	MIN (hire_date)
FROM employees;

-- Select Completo
SELECT
	employee_id,
	first_name,
	last_name,
	hire_date
FROM employees
WHERE hire_date = (
		SELECT
			MIN (hire_date)
		FROM employees
		);


/* Questão 4
A equipe financeira quer entender quais pedidos tiveram um valor total
acima do valor total médio de todos os pedidos, pois isso pode indicar
compras em grande volume ou de produtos de maior valor agregado.
Essas informações podem ser úteis para negociações futuras e para
identificar padrões de clientes premium.
Crie uma consulta para obter essa informação, ordenando-a pelo valor
total do pedido. Entenda por valor total a soma de unit_price * quantity.
(Utilize a tabela order_details)
*/
-- Select Subquerie 1
SELECT
	order_id,
	SUM (unit_price * quantity) AS total
FROM order_details
GROUP BY order_id;

-- Select Subquerie 2
SELECT
	AVG (total)
FROM (
	SELECT
		order_id,
		SUM (unit_price * quantity) AS total
FROM order_details
GROUP BY order_id
) t;

-- Select Completa
SELECT
	order_id,
	SUM (unit_price * quantity) AS total_pedido
FROM order_details
GROUP BY order_id
HAVING SUM (unit_price * quantity) >(
							SELECT
								AVG (total)
							FROM (
								SELECT
									order_id,
									SUM (unit_price * quantity) AS total
							FROM order_details
							GROUP BY order_id
							) t
						)
ORDER BY total_pedido;


/* Questão 5
O setor de vendas deseja segmentar clientes que já compraram produtos
da categoria Bebidas (Beverages). Essa informação será usada para
direcionar campanhas promocionais específicas, oferecendo novos
produtos ou descontos para incentivar compras recorrentes.
Crie uma consulta que liste os IDs, nomes das empresas, nomes e cargos
dos contatos e telefones desses clientes. (Utilize as tabelas customers,
orders,order_details, products e categories)
*/
-- Select subquerie 1
SELECT DISTINCT
	o.customer_id
FROM orders o
INNER JOIN order_details od
	ON o.order_id = od.order_id
	INNER JOIN products p
		ON od.product_id = p.product_id
		INNER JOIN categories cat
			ON p.category_id = cat.category_id
WHERE cat.category_name = 'Beverages'

-- Select completo
SELECT
	c.customer_id,
	c.company_name,
	c.contact_name,
	c.contact_title,
	c.phone
FROM customers c
WHERE c.customer_id IN(
					SELECT DISTINCT
						o.customer_id
					FROM orders o
					INNER JOIN order_details od
						ON o.order_id = od.order_id
						INNER JOIN products p
							ON od.product_id = p.product_id
							INNER JOIN categories cat
								ON p.category_id = cat.category_id
					WHERE cat.category_name = 'Beverages'
				);


/* Questão 6
A gerência quer identificar produtos premium no catálogo, comparando
os preços de itens vendidos com o produto mais caro da categoria
Condimentos (Condiments). Essa análise pode ajudar na definição de
estratégias de precificação e posicionamento de mercado.
Crie uma consulta que retorne os nomes e os preços desses produtos.
(Utilize as tabelas products e categories)
*/
-- Select Subquerie 1
SELECT
	MAX (unit_price)
FROM products p
INNER JOIN categories c
	ON p.category_id = c.category_id
WHERE c.category_name = 'Condiments';

-- Select
SELECT
	product_name,
	unit_price
FROM products
WHERE unit_price > (
					SELECT
						MAX (unit_price)
					FROM products p
					INNER JOIN categories c
						ON p.category_id = c.category_id
					WHERE c.category_name = 'Condiments');



/* Questão 7
O setor de vendas deseja reconhecer o(a) melhor vendedor(a) da
empresa, ou seja, o(a) funcionário(a) que gerou o maior valor total de
vendas (considerando como total de vendas de cada funcionário a soma
de unit_price * quantity agrupada por employee_id). Essa informação
pode ser usada para premiações, bonificações e
incentivando um desempenho ainda melhor da equipe comercial.
Crie uma consulta que retorne o ID, o nome e o sobrenome desse(a)
funcionário(a). (Utilize as tabelas employees, orders e order_details)
*/
-- Select Subquerie 1
SELECT employee_id
FROM orders o
INNER JOIN order_details od
	ON o.order_id = od.order_id
GROUP BY employee_id
ORDER BY SUM (unit_price * quantity) DESC
LIMIT 1;

-- Select Completo
SELECT
	employee_id,
	first_name,
	last_name
FROM employees
WHERE employee_id = (
			SELECT employee_id
			FROM orders o
			INNER JOIN order_details od
				ON o.order_id = od.order_id
			GROUP BY employee_id
			ORDER BY SUM (unit_price * quantity) DESC
			LIMIT 1
		);

/* Questão 8
O setor comercial deseja identificar clientes que nunca realizaram um
pedido, mesmo estando cadastrados no banco de dados. Essas
informações são fundamentais para entrar em contato com esses clientes,
entender seus motivos e tentar convertê-los em compradores ativos.
Crie uma consulta que retorne os IDs, nomes das empresas, nomes e
cargos dos contatos e telefones desses clientes. (Utilize as tabelas
customers e orders)
*/
-- Select Subquerie 1
SELECT DISTINCT
	customer_id
FROM orders;

-- Select Completa
SELECT
	customer_id,
	company_name,
	contact_name,
	contact_title,
	phone
FROM customers
WHERE customer_id NOT IN (
					SELECT DISTINCT
						customer_id
					FROM orders
				);


/* Questão 9
A equipe de compras quer analisar quais fornecedores oferecem
produtos premium, ou seja, itens com preços acima da média geral do
catálogo. Essas informações podem ser usadas para negociações de
contratos e ajustes no portfólio de produtos.
Crie uma consulta que liste os IDs e os nomes dos fornecedores que
oferecem produtos com preço acima da média geral de preços
cadastrados. (Utilize as tabelas suppliers e products)
*/
-- Select Subquerie 1
SELECT
	AVG (unit_price)
FROM products;

-- Select Completo
SELECT DISTINCT
	s.supplier_id,
	s.company_name
FROM suppliers s
INNER JOIN products p
	ON s.supplier_id = p.supplier_id
WHERE p.unit_price > (
					SELECT
						AVG (unit_price)
					FROM products
				);


/* Questão 10
O setor de estoque precisa verificar se existem produtos que nunca
foram vendidos, pois esses itens podem representar estoque parado e
custos desnecessários. Com essa análise, a empresa pode tomar decisões
sobre liquidações, promoções ou até mesmo a retirada desses produtos
do catálogo.
Crie uma consulta que retorne os IDs e os nomes desses produtos, caso
existam. (Utilize as tabelas products e order_details)
*/
-- Select Subquerie 1
SELECT DISTINCT
	product_id
FROM order_details;

-- Select Completa
SELECT
	product_id,
	product_name
FROM products
WHERE product_id NOT IN (
				SELECT DISTINCT
					product_id
				FROM order_details
			);



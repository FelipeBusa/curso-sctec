-- COMENTÁRIO DE 1 LINHA
/* COMENTÁRIO COM 
MAIS DE 1 LINHA*/


-- =================
-- MÓDULO 2 - SELECT FROM
-- SELECT EXEMPLO INICIAL
SELECT * 
FROM public.categories
ORDER BY category_id ASC; -- `;` SERVE PARA FINALIZAR A QUERRY


-- SELECT DE DUAS COLUNAS DA MESMA TABELA
SELECT 
	first_name,
	last_name
FROM employees;


-- RENOMEANDO COLUNAS = SELECT COM 'AS'
SELECT
	product_id AS Id_Produto, -- sem aspas não deixa maiusculo
	product_name AS "Nome_Produto", -- com aspas para deixar MAIUSCULO
	unit_price AS Preco_unitario -- nome composto não pode ter espaço entre elas
FROM public.products;


-- BOAS PRÁTICAS COLOCAR APELIDO A TABELA
SELECT
	product_id AS "Id_Produto"
FROM public.products p -- p é o apelido da tabela
LIMIT 5; -- LIMITA O RETORNO DO FROM


-- SELECIONAR VALORES DISTINTOS = SELECT DISTINCT
SELECT DISTINCT
	contact_title
FROM public.customers;



-- =================
-- MÓDULO 3 - FILTROS (WHERE)

-- WHERE de texto
SELECT *
FROM public.customers
WHERE country = 'France' -- France precisa estar escrito exatamente igual que está na tabela
LIMIT 2;


-- WHERE com números
SELECT *
FROM public.products
WHERE units_in_stock = 0; -- Número não precisa de aspas


SELECT *
FROM public.products
WHERE unit_price = '31.23'; -- Número com '. ou ,' precisa de aspas simples


SELECT *
FROM public.products
WHERE 
	units_in_stock = 0 AND
	unit_price = '21.35';


SELECT *
FROM public.products
WHERE unit_price >= 53; -- Tudo maior e igual
-- Diferente <> 


-- WHERE com Datas
SELECT *
FROM public.orders
WHERE order_date >= '1998-01-01'; -- DATA precisa de aspas


-- WHERE com AND e OR
-- AND os dois precisam ser verdades
-- OR apenas 1 precisa ser verdade
SELECT *
FROM public.customers
WHERE contact_title = 'Owner' AND country = 'France';


-- WHERE com LIKE 
-- Quando queremos pesquisar texto no meio do texto
SELECT * 
FROM public.products
WHERE quantity_per_unit LIKE '%box%';


-- WHERE com LIKE e _
-- SERVE PARA PESQUISAR EXATAMENTE A QUANTIDADE DE TEXTO QUE TEM
SELECT * 
FROM public.products
WHERE quantity_per_unit LIKE '___box%';


-- WHERE com IN
SELECT *
FROM public.customers
WHERE country = 'Mexico' OR country = 'UK' OR country = 'Canada';


-- IN serve para simplificar o código de cima (com diversos OR)
SELECT *
FROM public.customers
WHERE country IN ('Mexico','UK','Canada');


-- WHERE com BETWEEN
SELECT * FROM public.products
WHERE unit_price >= 50 AND unit_price <= 100;


-- BETWEEN serve para simplificar código com vários AND
SELECT * FROM public.products
WHERE unit_price BETWEEN 50 AND 100;


SELECT * FROM public.orders
WHERE order_date BETWEEN '1997-01-01' AND '1997-12-31';



-- =================
-- MÓDULO 4 - FUNÇÕES DE AGREGAÇÃO E AGRUPAMENTOS

-- COUNT - SUM - AVG (média) - MIN - MAX - GROUP BY
SELECT contact_name
FROM public.customers;


-- Utilizando COUNT para contar a quantidade de linhas
SELECT COUNT (contact_name)
FROM public.customers;


-- Sem count contabiliza todas as linhas (91)
SELECT region
FROM public.customers;


-- COUNT não conta valores nulos [null] (31)
SELECT COUNT (region)
FROM public.customers;


-- SUM soma total de UMA COLUNA
SELECT
SUM (units_in_stock) AS "TotalEstoque"
FROM public.products;


-- AVG, MIM, MAX
SELECT
	AVG (unit_price) AS preco_medio ,
	MAX (unit_price) AS maior_preco,
	MIN (unit_price) AS menor_preco
FROM public.products;


-- GROUP BY
SELECT supplier_id,
	SUM (units_in_stock)
FROM public.products
GROUP BY supplier_id;


-- ORDER BY com GROUP BY
SELECT country,
	COUNT (*)
FROM public.customers
GROUP BY country
ORDER BY COUNT(*);


-- GROUP BY, WHERE e HAVING
SELECT country,
	COUNT (*)
FROM public.customers
WHERE contact_title = 'Owner'
GROUP BY country;


-- Com HAVING
SELECT country,
	COUNT (*)
FROM public.customers
GROUP BY country
HAVING COUNT (*) > '10';


/*
WHERE - antes do GROUP BY
HAVING - utilize depois do GROUP

Não faz sentido usar juntos
*/

SELECT country,
	COUNT (*)
FROM public.customers
WHERE contact_title = 'Owner'
GROUP BY country
HAVING COUNT (*) > '2';
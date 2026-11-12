-- SEMANA 10

/*
FUNÇÕES Nº
* CEILING = arredonda para cima
* FLOOR = arredonda para baixo
* ROUND = arredonda para a qtd. de casas decimais informadas
* TRUNC
*/
SELECT 
	AVG (unit_price) AS media_normal,
	CEILING (AVG (unit_price)) AS media_ceiling,
	FLOOR (AVG(unit_price)) AS media_floor,
	ROUND(CAST (AVG(unit_price) AS NUMERIC), 3),
	TRUNC(CAST (AVG(unit_price) AS NUMERIC), 3)
FROM public.products;


/*
FUNÇÕES TEXTO
* UPPER = todas as letras maiúscula
* LOWER = todas as letras minúscula
* LENGTH = mostra a quantidade de caracteres
* INITCAP = inicias maiúscula e demais minúscula
*/
SELECT 
	first_name,
	UPPER(first_name),
	LOWER(first_name),
	LENGTH(first_name),
	INITCAP ('SQL')
FROM public.employees;


-- REPLACE = substitui um texto por outro
SELECT
	contact_name,
	contact_title,
	REPLACE(contact_title, 'Owner', 'CEO')
FROM public.customers
WHERE contact_title LIKE 'Owner';


/*
SUBSTRING = retorna parte de um texto em string
STRPOS = retorna a posição do caracter
*/
SELECT 
	'ABC-9999',
	SUBSTRING('ABC-9999', 1,3),
	SUBSTRING('ABC-9999', 5,4),
	STRPOS ('ABC-9999', '-');



/*
FUNÇÕES DATAS
* CURRENT_DATE = Retorna a data atual
* AGE = retorna o tempo decorrido
* DATE_PART = retorna o paramentro informado (day, month e year)
*/
SELECT
	first_name,
	birth_date,
	CURRENT_DATE,
	AGE(birth_date),
	DATE_PART('DAY', birth_date) AS dia,
	DATE_PART('MONTH', birth_date) AS mes,
	DATE_PART('YEAR', birth_date) AS ano
FROM public.employees;



-- SUBQUERY:
-- WHERE = como parâmetro para filtrar uma tabela
SELECT * FROM products
WHERE unit_price >= (SELECT AVG(unit_price) FROM products)
ORDER BY unit_price;




SELECT * FROM order_details
WHERE quantity <= (SELECT AVG(quantity) FROM public.order_details)
ORDER BY quantity DESC;


-- FROM = como uma tabela;
SELECT
	AVG(total_clientes)
FROM (
	SELECT
		contact_title,
		COUNT(*) AS total_clientes
	FROM public.customers
	GROUP BY contact_title);
)


-- SELEСТ = para retornar uma nova coluna no resultado
SELECT 
	*,
	(SELECT AVG (unit_price) FROM public.products ) media_preco
FROM public.products;


-- página 359
SELECT
	order_id,
	SUM(quantity)
FROM public.order_details
GROUP BY order_id
HAVING SUM (quantity) >= (
	SELECT
		AVG(total_vendido)
		FROM (
			SELECT
				order_id,
				SUM(quantity) total_vendido
			FROM order_details
			GROUP BY order_id) T);




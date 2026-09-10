-- DESAFIOS EXTRAS

/* Desafio 01 - EXTRA
A equipe comercial deseja identificar quais clientes realizaram os
pedidos de maior valor ao longo do período analisado. Para isso, a
empresa precisa de um relatório que apresente o valor total gasto por
cada cliente.

Crie uma consulta SQL que retorne o valor total dos pedidos realizados
por cada cliente, considerando apenas os clientes cujo valor total
comprado seja igual ou superior a 5000. O resultado deve apresentar
primeiro os clientes que tiveram o maior valor total de compras.

(Utilize as tabelas orders e order_details)
*/
SELECT
    customer_id AS cliente,
    SUM(freight) AS frete_total
FROM public.orders
GROUP BY customer_id
HAVING SUM(freight) >= 500
ORDER BY frete_total DESC;


/* Desafio 02 - EXTRA
A equipe de gestão está analisando o desempenho das categorias de
produtos para identificar quais delas apresentam maior quantidade de
itens vendidos. Esse levantamento será utilizado para apoiar decisões
sobre estoque e estratégias comerciais.

Crie uma consulta SQL que retorne a quantidade total de unidades
vendidas por categoria de produto, considerando somente as categorias
que tenham alcançado pelo menos 2000 unidades vendidas. O resultado
deve apresentar as categorias com maior quantidade de unidades
vendidas primeiro.

(Utilize as tabelas products, categories e order_details)
*/
SELECT
    customer_id AS cliente,
    COUNT(*) AS quantidade_pedidos
FROM public.orders
GROUP BY customer_id
HAVING COUNT(*) >= 10
ORDER BY quantidade_pedidos DESC;
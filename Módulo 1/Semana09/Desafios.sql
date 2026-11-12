-- Desafio 1 - Análise de desempenho dos clientes
/* Contexto:
A equipe comercial quer identificar os clientes que apresentam 
maior volume de compras. Para isso, você precisa criar um relatório 
consolidado contendo a quantidade de pedidos e a receita total gerada por cada cliente.

Tarefa:
Crie uma consulta SQL que retorne:
* ID do cliente;
* Nome da empresa;
* Quantidade total de pedidos realizados;
* Receita total gerada pelos pedidos (unit_price * quantity).

Considere apenas clientes que tenham realizado pelo menos 3 pedidos.
Ordene o resultado pela receita total, do maior para o menor.
Tabelas: customers, orders e order_details */
SELECT
    c.customer_id AS id_cliente,
    c.company_name AS nome_empresa,
    COUNT(DISTINCT o.order_id) AS quantidade_pedidos,
    ROUND(SUM(od.unit_price * od.quantity)::numeric,2) AS receita_total
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN order_details od
    ON o.order_id = od.order_id
GROUP BY
    c.customer_id,
    c.company_name
HAVING COUNT(DISTINCT o.order_id) >= 3
ORDER BY receita_total DESC;

-- Desafio 2 - View de desempenho por categoria
/* Contexto:
A diretoria comercial quer acompanhar o desempenho das categorias de 
produtos para apoiar decisões relacionadas a estoque, vendas e campanhas comerciais.

Tarefa:
Crie uma VIEW chamada vw_desempenho_categorias que apresente, para cada categoria:
* Nome da categoria;
* Quantidade de produtos cadastrados;
* Quantidade total de unidades vendidas;
* Receita total gerada pela categoria (unit_price * quantity);
* Preço médio dos produtos da categoria.

A view deve apresentar somente categorias cuja receita total seja superior a 10.000.
Ordene o resultado pela receita total, da maior para a menor.
Tabelas: categories, products e order_details*/

CREATE VIEW vw_desempenho_categorias AS
SELECT
    c.category_name AS nome_categoria,
    COUNT(DISTINCT p.product_id) AS quantidade_produtos,
    SUM(od.quantity) AS unidades_vendidas,
    ROUND(SUM(od.unit_price * od.quantity)::numeric,2) AS receita_total,
    ROUND(AVG(p.unit_price)::numeric,2) AS preco_medio_produtos
FROM categories c
INNER JOIN products p
    ON c.category_id = p.category_id
INNER JOIN order_details od
    ON p.product_id = od.product_id
GROUP BY
    c.category_id,
    c.category_name
HAVING SUM(od.unit_price * od.quantity) > 10000
ORDER BY receita_total DESC;

SELECT * FROM vw_desempenho_categorias;
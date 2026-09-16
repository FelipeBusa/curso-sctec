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
Tabelas: categories, products e order_details

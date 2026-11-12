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
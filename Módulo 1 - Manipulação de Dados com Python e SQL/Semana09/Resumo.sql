-- SEMANA 09
-- MÓDULO 5 - JOINS

-- TABELA A
SELECT 
	product_id,
	product_name,
	category_id
FROM public.products;


-- TABELA B
SELECT
	category_id,
	category_name
FROM public.categories;


-- TABELA_A COM JOIN NA TABELA B
-- INNER JOIN É IGUAL JOIN
SELECT
	tA.product_id,
	tA.product_name,
	tA.category_id,
	tB.category_name
FROM public.products tA
INNER JOIN public.categories  tB
ON tA.category_id = tB.category_id;


-- LEFT JOIN
SELECT
	tA.product_id,
	tA.product_name,
	tA.category_id,
	tB.category_name
FROM public.products tA
LEFT JOIN public.categories  tB
ON tA.category_id = tB.category_id;


-- RIGHT JOIN
SELECT
	tA.product_id,
	tA.product_name,
	tA.category_id,
	tB.category_name
FROM public.products tA
RIGHT JOIN public.categories  tB
ON tA.category_id = tB.category_id;


-- FULL JOIN
SELECT
	tA.product_id,
	tA.product_name,
	tA.category_id,
	tB.category_name
FROM public.products tA
FULL JOIN public.categories  tB
ON tA.category_id = tB.category_id;


-- ========================
-- MODULO 6 - VIEWS
-- CREATE or REPLACE View
-- criação (CREATE) e atualização/substituição (REPLACE)
CREATE OR REPLACE VIEW vwprodutos AS
SELECT 
	product_id AS "Produto ID",
	product_name AS "Nome Produto",
	unit_price AS "Preço Unidade"
FROM public.products;

-- visualização
SELECT * FROM public.vwprodutos;


-- ALTER VIEW (alterar o nome da VIEW)
-- DROP (IF EXISTS) View (deletar o arquivo)



-- ========================
-- MÓDULO 7 
-- CREATE DATABASE e TABELAS
CREATE DATABASE aula;


-- necessário mudar a query para a database (aula)
-- criando tabelas
CREATE TABLE alunos(
	ID_Aluno INT,
	Nome_Aluno VARCHAR (50) NOT NULL,
	Email VARCHAR (50) NOT NULL,
	PRIMARY KEY (ID_Aluno)
);

CREATE TABLE cursos(
	ID_Curso INT,
	Nome_Curso VARCHAR (50) NOT NULL,
	Preco_Curso NUMERIC (10,2) NOT NULL,
	PRIMARY KEY (ID_Curso)
);

CREATE TABLE matriculas(
	ID_Matricula INT,
	ID_Curso INT NOT NULL,
	ID_Aluno INT NOT NULL,
	Data_Cadastro DATE NOT NULL,
	PRIMARY KEY (ID_Matricula), /*criando chave primaria da tabela*/
	FOREIGN KEY (ID_Aluno) REFERENCES alunos(ID_Aluno), /*criando a ligaação entre as tabelas*/
	FOREIGN KEY (ID_Curso) REFERENCES cursos(ID_Curso)
);


-- Excluir tabelas
DROP TABLE alunos, cursos, matriculas


-- Inserir informações
INSERT INTO alunos (ID_Aluno, Nome_Aluno, Email)
VALUES
	(1, 'Ana', 'ana@gmail.com'),
	(2, 'Bianca', 'bianca@gmail.com'),
	(3, 'Carla', 'carla@gmail.com'),
	(4, 'Diego', 'diego@gmail.com');

INSERT INTO cursos(ID_Curso, Nome_Curso, Preco_Curso)
VALUES
	(1, 'Excel', 100),
	(2, 'VBA', 200),
	(3, 'SQL', 250);

INSERT INTO matriculas (ID_Matricula, ID_Aluno, ID_Curso, Data_Cadastro)
VALUES
	(1, 1, 1, '2021/03/11'),
	(2, 1, 2, '2021/06/21'),
	(3, 2, 3, '2021/01/08'),
	(4, 3, 1, '2021/04/03'),
	(5, 4, 1, '2021/05/10'),
	(6, 4, 3, '2021/05/10');
	

-- visualizações
SELECT * FROM public.alunos;
SELECT * FROM public.cursos;
SELECT * FROM public.matriculas;


-- Atualização valores/informações
UPDATE cursos
SET Preco_curso = 300
WHERE ID_Curso = 1;
# Mini Projeto - Análise de Dados com Python | Módulo 1
Felipe Busarello
Curso: Análise de Dados com Python
Turma: 05 - 2026
Professor: Cláudio Neves


## 📌 Sobre o Projeto
Este repositório apresenta o **Mini Projeto do Módulo 1** do curso **Análise de Dados com Python - Turma 05**.

O projeto tem como objetivo aplicar, de forma prática, os conhecimentos adquiridos durante o módulo no processo de **Extração, Transformação e Análise de dados**, utilizando Python para preparar, explorar e visualizar uma base de dados de varejo.

A atividade utiliza o arquivo BaseVarejo.csv, composta por informações relacionadas a compras realizadas por clientes de uma rede de supermercados.

O projeto contempla as principais etapas de um processo de análise exploratória:

**Carregamento → Tratamento → Exploração → Análise → Visualização → Interpretação**


## 🎯 Objetivos

O principal objetivo deste projeto é realizar uma Análise Exploratória de Dados (AED) utilizando Python, identificando características, padrões, possíveis inconsistências e relações existentes nos dados.

Durante o desenvolvimento serão realizadas atividades de:
* Extração e carregamento dos dados;
* Inspeção inicial da base;
* Identificação e tratamento de inconsistências;
* Verificação de valores ausentes;
* Adequação dos tipos de dados;
* Remoção de colunas desnecessárias;
* Análise estatística e descritiva;
* Agrupamentos e comparações entre categorias;
* Análise de correlação entre variáveis;
* Avaliação da necessidade de transformação de variáveis;
* Construção de gráficos;
* Identificação de padrões e possíveis relações nos dados;
* Preparação dos resultados para apresentação utilizando Python.


## 📊 Base de Dados
A base utilizada no projeto é a **Base Varejo**, disponbilizada no Kaggle.

Fonte: Kaggle
Dataset: [Base Varejo](https://www.kaggle.com/datasets/namespaiva/base-varejo/data) 

De acordo com a documentação fornecida para a atividade, a base representa informações de compras realizadas por clientes de uma rede de supermercados no período de 2010 a 2022.

A documentação descreve os seguintes campos principais: `DATA`, `CO_ID`, `CL_ID`, `CL_GENERO`, `CL_EC`, `CL_FHL`, `CL_SEG`, `PR_ID`, `PR_CAT` e `PR_NOME`.

**🗂️ Dicionário de Dados**
Campo   Descrição
* `DATA`	Data da compra
* `CO_ID`	Identificação da compra / número da nota fiscal
* `CL_ID`	Identificação do cliente
* `CL_GENERO`	Sexo biológico informado pelo cliente
* `CL_EC`	Estado civil do cliente
* `CL_FHL`	Número de filhos do cliente
* `CL_SEG`	Segmentação econômica do cliente
* `PR_ID`	Código do produto (SKU)
* `PR_CAT`	Categoria do produto
* `PR_NOME`	Nome do produto


**Estado Civil**

A variável CL_EC utiliza códigos numéricos para representar o estado civil:

Código  Descrição
1	Casado ou união estável
2	Divorciado
3	Separado
4	Solteiro
5	Viúvo


## 🔎 Processo de ETL e Preparação dos Dados
Antes da realização da análise exploratória, os dados passam por uma etapa de inspeção e preparação.

### 1. Extração
O arquivo `BaseVarejo;csv` é carregado utilizando Pytho e as bibliotecas necessárias para manipulação dos dados.

### 2. Transformação
Durante a etapa de transformação são verificadas possíveis inconsistências, incluindo:
* Valores ausentes;
* Valores nulos mascarados;
* Colunas sem informações;
* Tipos de dados;
* Formatação da variável de data;
* Registros duplicados;
* Estrutura e consistência das variáveis categóricas e numéricas.
*Complementar*

### 3. Carga
Após a preparação, os dados tratados são utilizados como base para a **Análise Exploratória de Dados (AED)** e para a construção das visualizações.


## 📈 Análise Exploratória de Dados
*Complementar*


## 📊 Visualizações
*Complementar*



## 🛠️ Tecnologias e Bibliotecas
O projeto foi totalmente desenvolvido em Python 3.13.14, utilizando as seguintes bibliotecas para manipulação e visualização:
* **CSV** - Para carregamento e leitura de arquivos com formato .csv.
* **Pandas** - Para leitura, indexação e tratamento dos dados.
* **NumPy** - Utilizado como suporte às operações numéricas e manipulação de dados.
* **Matplotlib & Seaborn** - Para a geração dos gráficos estatísticos e estilização visual das distribuições.


## 📁 Estrutura do Projeto
```text
Mini_Projeto_Felipe_Busarello/
│ 
├── 📂 dataset/
│   └── Base Varejo.csv
│
├── 📂 graficos/
│   └── *Complementar*
│
├── 📓 Mini_Projeto_Felipe_Busarello.ipynb
│
└── README.md
```
*Complementar*


## 📊 Resultados
*Complementar*


## 💡 Principais aprendizados
*Complementar*


## 🚧 Desafios encontrados
*Complementar*


## 🚀 Como Executar o Projeto Localmente
### 1. Clonar o Repositório
No terminal, execute:
```
git clone [https://github.com/FelipeBusa/curso-sctec.git](https://github.com/FelipeBusa/curso-sctec.git)
```

Depois, acesse a pasta do projeto:
```
cd curso-sctec/ProjetoAvaliativoM1/Mini_Projeto_Felipe_Busarello
```

### 2. Instalar as Bibliotecas
Caso necessário, instale as bibliotecas utilizadas:
```
pip install pandas numpy matplotlib seaborn
```

### 3. Executar o Projeto
Abra o notebook:

Mini_Projeto_Felipe_Busarello.ipynb

O projeto pode ser executado utilizando VS Code.

## 🎯 Próximos Passos

## 👨‍💻 Autor

Felipe Busarello

Curso: Análise de Dados com Python
Turma: 05 — 2026
Professor: Cláudio Neves
Projeto: Mini Projeto — Módulo 1
Data: 17/08/2026
"""
Desafio -- Etapa 1: extração. Mesma lógica que a professora acabou de
mostrar na Vitrine (scripts/01_extrair_fontes.py), com as MESMAS 3 fontes
(CSV, API, Scraping) -- só que aqui CSV e API vêm da Vitrine em miniatura,
e API/Scraping são fontes públicas DE VERDADE, não mocks.

Fonte 1 -- CSV (análoga ao vendas.csv/produtos.csv da Vitrine, slide 10):
    raw/populacao_2010.csv -- o Censo 2010, já pronto num arquivo. Não
    precisamos buscar isso de novo: é histórico, não muda. Igual à Vitrine
    com os CSVs dela, é só ler.

Fonte 2 -- API (análoga à API de produtos da Vitrine, slide 13):
    GET https://servicodados.ibge.gov.br/api/v1/localidades/estados
    Devolve uma lista de 27 objetos, um por estado + DF, no formato:
        {"id": 35, "sigla": "SP", "nome": "São Paulo",
         "regiao": {"id": 3, "sigla": "SE", "nome": "Sudeste"}}

Fonte 3 -- Web Scraping (análoga ao preço do concorrente, slide 15):
    A página da Wikipédia "Lista de unidades federativas do Brasil por
    população" tem uma tabela (classe "wikitable") com uma linha por estado:
    nome do estado e colunas de população de 2026 (estimativa) e 2022
    (Censo), com um espaço especial (NBSP, "\xa0") como separador de milhar
    em boa parte dos números (ex.: "44\xa0411\xa0238").

    Atenção, pegadinha real: a Wikipédia devolve HTTP 403 (bloqueado) para
    requisições sem um User-Agent próprio -- o requests padrão é tratado
    como robô. Por isso USER_AGENT_WIKIPEDIA abaixo já vem definido; use-o
    em headers=USER_AGENT_WIKIPEDIA no requests.get().

Rode com:  python3 scripts/01_extrair_fontes.py
"""
from pathlib import Path #para montar o caminho dos arquivos

import pandas as pd
import requests #faz chamadas do HTTP
from bs4 import BeautifulSoup

ROOT = Path(__file__).resolve().parent.parent #é o caminho do script
RAW = ROOT / "raw" #caminho do csv

URL_API_ESTADOS = "https://servicodados.ibge.gov.br/api/v1/localidades/estados"
URL_WIKIPEDIA_POPULACAO = "https://pt.wikipedia.org/wiki/Lista_de_unidades_federativas_do_Brasil_por_popula%C3%A7%C3%A3o"
USER_AGENT_WIKIPEDIA = {"User-Agent": "aula-etl-python-fiesc/1.0 (uso educacional)"} #identifição user agente para fazer as requisições


def extrair_populacao_2010_csv() -> pd.DataFrame:
   df = pd.read_csv(RAW / "populacao_2010.csv") #ler o csv inteiro e salva numa variavel dataframe
   print(f"[CSV] {len(df)} estados") #printando a quantidade de estados/linhas
   print(df.head(5)) #printar os 5 primeiros dados
   return df


def extrair_estados_api() -> pd.DataFrame:
   resposta = requests.get(URL_API_ESTADOS, timeout=30) #evitar que o script fique travado se a api não responder
   resposta.raise_for_status() #trazer o erro se o status do http não for 2XX
   df = pd.DataFrame(resposta.json()) #o json traz a lista de dados e o data frase transforma em tabela
   df["regiao"] = df["regiao"].apply(lambda x: x["nome"]) #consolidar cada região
   df = df[["id", "sigla", "nome", "regiao"]] #mantém só as colunas que interressam
   print(f"[API] {len(df)} estados")
   print(df.head(5))
   return df


def extrair_populacao_wikipedia() -> pd.DataFrame:
   resposta = requests.get(URL_WIKIPEDIA_POPULACAO, headers=USER_AGENT_WIKIPEDIA, timeout=30)
   resposta.encoding = "utf-8"
   html = BeautifulSoup (resposta.text, "html.parser") #transformar o HTML bruto em uma estrutura navegável
   tabela = html.find("table", {"class": "wikitable"}) #achar a tabela
   linhas = tabela.select("tr")[2:] #iniciar as linhas pulando as 2 primeiras do cabeçalho
   dados = [] 
   for tr in linhas:
      celulas = tr.find_all(["th", "td"]) #lendo cada celula
      estado = celulas[0].get_text(strip=True)  #trazer o nome do estado sem espaços nas pontas
      if estado == "Total": #então a gente pula linha
         continue
      pop_2026 = int(celulas[1].get_text(strip=True).replace("\xa0","").replace(" ", "")) #\xa0 espaço não separavel que o wikipedia utiliza para separar milhares
      pop_2022 = int(celulas[2].get_text(strip=True).replace("\xa0","").replace(" ", ""))
      dados.append({"estado": estado, "populacao_2022": pop_2022, "populacao_2026": pop_2026}) 
   df = pd.DataFrame(dados) #adiciono no data frame
   print(f"[Wikipedia] {len(df)} estados")
   print(df.head(5))
   return df


if __name__ == "__main__":
    populacao_2010 = extrair_populacao_2010_csv()
    print()
    estados = extrair_estados_api()
    print()
    populacao = extrair_populacao_wikipedia()

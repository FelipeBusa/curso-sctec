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
from pathlib import Path

import pandas as pd
import requests
from bs4 import BeautifulSoup

ROOT = Path(__file__).resolve().parent.parent
RAW = ROOT / "raw"

URL_API_ESTADOS = "https://servicodados.ibge.gov.br/api/v1/localidades/estados"
URL_WIKIPEDIA_POPULACAO = "https://pt.wikipedia.org/wiki/Lista_de_unidades_federativas_do_Brasil_por_popula%C3%A7%C3%A3o"
USER_AGENT_WIKIPEDIA = {"User-Agent": "aula-etl-python-fiesc/1.0 (uso educacional)"}


def extrair_populacao_2010_csv() -> pd.DataFrame:
    """Fonte 1: CSV -- o Censo 2010 (sigla, nome_estado, populacao_2010),
    já pronto em raw/populacao_2010.csv. Igual à Vitrine (slide 10):
    pd.read_csv(caminho).

    TODO:
    1. pd.read_csv(RAW / "populacao_2010.csv").
    2. Imprima len(df) e df.head(3), e retorne o DataFrame.
    """
    raise NotImplementedError("TODO: Etapa 1 -- extrair_populacao_2010_csv()")


def extrair_estados_api() -> pd.DataFrame:
    """Fonte 2: API do IBGE -- devolve id, sigla, nome e região de cada
    estado. Igual à Vitrine (slide 13): requests.get(url) -> .json() ->
    pd.DataFrame(...).

    TODO:
    1. Faça requests.get(URL_API_ESTADOS, timeout=30) e chame
       resposta.raise_for_status().
    2. Transforme resposta.json() (uma lista de dicts) num DataFrame com
       pd.DataFrame(...).
    3. O campo "regiao" vem como um dict aninhado ({"id":.., "nome":..}).
       Extraia só o nome da região para uma coluna "regiao" simples, por
       exemplo com: df["regiao"].apply(lambda r: r["nome"]).
    4. Deixe as colunas finais como: id, sigla, nome, regiao.
    5. Imprima len(df) e df.head(3), e retorne o DataFrame.
    """
    raise NotImplementedError("TODO: Etapa 1 -- extrair_estados_api()")


def extrair_populacao_wikipedia() -> pd.DataFrame:
    """Fonte 3: Web Scraping -- devolve o nome do estado e a população de
    2022 (Censo) e 2026 (estimativa) a partir da tabela da Wikipédia. Igual
    à Vitrine (slide 15): requests.get(url).text -> BeautifulSoup -> extrair
    só o que interessa.

    TODO:
    1. Faça requests.get(URL_WIKIPEDIA_POPULACAO, timeout=30,
       headers=USER_AGENT_WIKIPEDIA); ajuste resposta.encoding = "utf-8"
       antes de ler resposta.text.
    2. html = BeautifulSoup(resposta.text, "html.parser")
    3. Ache a PRIMEIRA tabela com classe "wikitable" (ex.:
       html.select_one("table.wikitable")) -- é a tabela "Lista", não a de
       "Por região" que vem depois na mesma página.
    4. tabela.select("tr") devolve TODAS as linhas, inclusive 2 linhas de
       cabeçalho (a 1ª agrupa "População" em 2 colunas; a 2ª tem "2026
       (est.)" e "2022" separados) -- pule as 2 primeiras com [2:]. A
       ÚLTIMA linha é "Total" (soma do Brasil, não é um estado) -- descarte.
    5. Para cada <tr> de dado restante: célula.get_text(strip=True) já
       resolve o nome do estado (1ª célula). A população vem nas células 2
       (2026) e 3 (2022) -- remova "\xa0" e espaços normais antes de
       int(...).
    6. Monte um DataFrame com as colunas: estado, populacao_2022,
       populacao_2026.
    7. Imprima len(df) e df.head(3), e retorne o DataFrame.
    """
    raise NotImplementedError("TODO: Etapa 1 -- extrair_populacao_wikipedia()")


if __name__ == "__main__":
    populacao_2010 = extrair_populacao_2010_csv()
    print()
    estados = extrair_estados_api()
    print()
    populacao = extrair_populacao_wikipedia()

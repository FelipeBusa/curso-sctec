"""
ETL tradicional (Parte 1) -- as 4 fontes de onde a Vitrine passa a extrair
dados em Python: CSV, PostgreSQL (staging), API e Web Scraping.

Este arquivo é só demonstração de CADA fonte isoladamente (um "print" por
fonte). O pipeline de verdade, que junta tudo e carrega no banco, está em
pipeline_etl.py -- lá, extrair() simplifica para CSV e as chamadas de API/
scraping entrariam do mesmo jeito, como funções extras dentro dela.

Pré-requisito do extrair_staging_postgres(): já ter rodado o pipeline SQL da
Semana 4 (vitrine-dw/sql/01_staging_elt_load.sql) no banco "vitrine", para
staging.vendas_raw existir.

A API e o concorrente da Vitrine não existem de verdade -- para rodar com
dados reais em aula, este script usa duas fontes públicas reais no lugar
delas: a FakeStoreAPI (o JSON de volta tem o mesmo formato que a API do
sistema da loja da Vitrine devolveria) e o books.toscrape.com, site público
feito pelo time do Scrapy especialmente para prática de scraping (mesma
lógica de um concorrente real, trocando só a URL e o seletor). Use
usar_mock=True em extrair_api_produtos()/extrair_preco_concorrente() para
voltar aos mocks locais (raw/api_produtos_mock.json e
raw/concorrente_smartwatch.html) e rodar sem depender de rede.

Rode com:  python3 scripts/01_extrair_fontes.py
"""
import os
import re
from pathlib import Path

import pandas as pd
import requests
from bs4 import BeautifulSoup
from dotenv import load_dotenv

ROOT = Path(__file__).resolve().parent.parent
RAW = ROOT / "raw"

load_dotenv(ROOT / ".env")
DB_PASSWORD = os.environ["DB_PASSWORD"]
CONEXAO_POSTGRES = f"postgresql+psycopg2://postgres:{DB_PASSWORD}@localhost:5432/vitrine"
URL_API_PRODUTOS = "https://fakestoreapi.com/products"
URL_CONCORRENTE = "https://books.toscrape.com/catalogue/a-light-in-the-attic_1000/index.html"


def extrair_csv() -> pd.DataFrame:
    """Fonte 1: arquivos CSV -- vendas, clientes, produtos e lojas da Vitrine."""
    vendas = pd.read_csv(RAW / "vendas.csv", sep=",", encoding="utf-8")
    print(f"[CSV] vendas.csv: {len(vendas)} linhas")
    print(vendas.head(3))
    return vendas


def extrair_staging_postgres() -> pd.DataFrame:
    """Fonte 2: banco relacional -- a mesma staging.vendas_raw que o SQL da
    Semana 4 carregou (ELT). Em Python, isso entra como leitura (ETL)."""
    from sqlalchemy import create_engine

    engine = create_engine(CONEXAO_POSTGRES)
    vendas_staging = pd.read_sql("SELECT * FROM staging.vendas_raw", engine)
    print(f"[Postgres] staging.vendas_raw: {len(vendas_staging)} linhas")
    print(vendas_staging.head(3))
    return vendas_staging


def extrair_api_produtos(usar_mock: bool = False) -> pd.DataFrame:
    """Fonte 3: API -- catálogo de produtos atualizado, direto do sistema da
    loja (sempre mais atual que o produtos.csv). Para rodar de verdade em
    aula, usamos a FakeStoreAPI, uma API pública real: o JSON de volta (id,
    title, price, category) é o mesmo formato que a API do sistema da loja
    da Vitrine devolveria."""
    if usar_mock:
        produtos_api = pd.read_json(RAW / "api_produtos_mock.json")
        print(f"[API] catálogo de produtos (mock): {len(produtos_api)} produtos")
        print(produtos_api.head(3))
    else:
        resposta = requests.get(URL_API_PRODUTOS, timeout=30)
        resposta.raise_for_status()
        produtos_api = pd.DataFrame(resposta.json())
        print(f"[API] catálogo de produtos: {len(produtos_api)} produtos")
        print(produtos_api[["id", "title", "price", "category"]].head(3))
    return produtos_api


def extrair_preco_concorrente(usar_mock: bool = False) -> float:
    """Fonte 4: Web Scraping -- preço de um produto no site de um
    concorrente, para comparar com o preço da Vitrine. Para rodar de verdade
    em aula, usamos o books.toscrape.com, site público feito pelo time do
    Scrapy especialmente para prática de scraping: a mesma lógica serve para
    o preço de um concorrente real, trocando só a URL e o seletor."""
    if usar_mock:
        html = (RAW / "concorrente_smartwatch.html").read_text(encoding="utf-8")
        texto_preco = BeautifulSoup(html, "html.parser").select_one(".preco-produto").get_text(strip=True)
        preco = float(texto_preco.replace("R$", "").replace(".", "").replace(",", ".").strip())
        print(f"[Scraping] preço do concorrente (mock): R$ {preco:.2f}")
    else:
        resposta = requests.get(URL_CONCORRENTE, timeout=30)
        resposta.encoding = "utf-8"
        texto_preco = BeautifulSoup(resposta.text, "html.parser").select_one(".price_color").get_text(strip=True)
        preco = float(re.search(r"[\d.]+", texto_preco).group())
        print(f"[Scraping] preço do concorrente: £{preco:.2f}")
    return preco


if __name__ == "__main__":
    extrair_csv()
    print()
    try:
        extrair_staging_postgres()
    except Exception as exc:
        print(f"[Postgres] pulado (precisa do banco 'vitrine' rodando): {exc}")
    print()
    try:
        extrair_api_produtos()
    except Exception as exc:
        print(f"[API] pulado (precisa de internet): {exc}")
    print()
    try:
        extrair_preco_concorrente()
    except Exception as exc:
        print(f"[Scraping] pulado (precisa de internet): {exc}")

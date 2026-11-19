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

A API e o concorrente da Vitrine não existem de verdade -- este script usa
dois arquivos fictícios que simulam essas respostas: raw/api_produtos_mock.json
(catálogo de produtos, como se fosse o retorno de uma API) e
raw/concorrente_smartwatch.html (a página do concorrente, para o scraping
com BeautifulSoup). A lógica de leitura é a mesma que seria usada contra uma
API ou um site reais, só a origem dos bytes (arquivo local, não rede) muda.

Rode com:  python3 scripts/01_extrair_fontes.py
"""
import os
from pathlib import Path

import pandas as pd
from bs4 import BeautifulSoup
from dotenv import load_dotenv

ROOT = Path(__file__).resolve().parent.parent
RAW = ROOT / "raw"

load_dotenv(ROOT / ".env")
DB_PASSWORD = os.environ["DB_PASSWORD"]
CONEXAO_POSTGRES = f"postgresql+psycopg2://postgres:{DB_PASSWORD}@localhost:5432/vitrine"


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


def extrair_api_produtos() -> pd.DataFrame:
    """Fonte 3: API -- catálogo de produtos atualizado, direto do sistema da
    loja (sempre mais atual que o produtos.csv). A Vitrine e sua API não
    existem de verdade, então raw/api_produtos_mock.json simula o JSON que
    esse endpoint devolveria: pd.read_json lê o arquivo exatamente como
    pd.DataFrame(resposta.json()) leria a resposta de uma API de verdade."""
    produtos_api = pd.read_json(RAW / "api_produtos_mock.json")
    print(f"[API] catálogo de produtos: {len(produtos_api)} produtos")
    print(produtos_api.head(3))
    return produtos_api


def extrair_preco_concorrente() -> float:
    """Fonte 4: Web Scraping -- preço de um produto no site de um
    concorrente, para comparar com o preço da Vitrine. O concorrente também
    é fictício: raw/concorrente_smartwatch.html simula a página dele, e o
    BeautifulSoup extrai o preço do mesmo jeito que extrairia de uma página
    real, só trocando a URL por um arquivo local."""
    html = (RAW / "concorrente_smartwatch.html").read_text(encoding="utf-8")
    texto_preco = BeautifulSoup(html, "html.parser").select_one(".preco-produto").get_text(strip=True)
    preco = float(texto_preco.replace("R$", "").replace(".", "").replace(",", ".").strip())
    print(f"[Scraping] preço do concorrente: R$ {preco:.2f}")
    return preco


if __name__ == "__main__":
    extrair_csv()
    print()
    try:
        extrair_staging_postgres()
    except Exception as exc:
        print(f"[Postgres] pulado (precisa do banco 'vitrine' rodando): {exc}")
    print()
    extrair_api_produtos()
    print()
    extrair_preco_concorrente()

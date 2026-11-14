"""
ETL tradicional (Parte 1) -- o pipeline completo da Vitrine em Python:
extrair() -> transformar() -> carregar(), igual aos slides da aula.

extrair() aqui simplifica para CSV (os mesmos vendas/clientes/produtos da
Semana 4); a API e o scraping (ver scripts/01_extrair_fontes.py) entrariam
do mesmo jeito, como chamadas extras dentro dela.

carregar() usa to_sql com if_exists="append" -- por isso ele DUPLICA tudo se
for rodado 2x. Isso é de propósito: é exatamente o problema que a Parte 2
(scripts/05_carga_incremental.py) resolve.

Pré-requisito: rodar sql/00_dw_python_schema.sql uma vez (cria o schema
dw_python com as tabelas já com as chaves certas) antes da primeira
execução deste script.

Rode com:  python3 scripts/pipeline_etl.py
"""
import os
import unicodedata
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine

ROOT = Path(__file__).resolve().parent.parent
RAW = ROOT / "raw"
load_dotenv(ROOT / ".env")
DB_PASSWORD = os.environ["DB_PASSWORD"]
CONEXAO_POSTGRES = f"postgresql+psycopg2://postgres:{DB_PASSWORD}@localhost:5432/vitrine"


def _sem_acento(texto: str) -> str:
    nfkd = unicodedata.normalize("NFKD", texto)
    return "".join(c for c in nfkd if not unicodedata.combining(c))


def extrair():
    vendas = pd.read_csv(RAW / "vendas.csv")
    clientes = pd.read_csv(RAW / "clientes.csv")
    produtos = pd.read_csv(RAW / "produtos.csv")
    return vendas, clientes, produtos


def transformar(vendas, clientes, produtos):
    # --- limpeza: produto duplicado (101/118) ---
    # nome_normalizado: só para AGRUPAR (sem acento, minúsculo, sem espaço
    # nas pontas), nunca para exibir -- é onde 101 ("Tênis Runner Pro") e
    # 118 ("tenis runner pro ") se encontram.
    produtos["nome_normalizado"] = produtos["nome_produto"].str.strip().str.lower().apply(_sem_acento)
    mapa_duplicados = produtos.groupby("nome_normalizado")["id_produto"].min()
    produtos["id_produto_canonico"] = produtos["nome_normalizado"].map(mapa_duplicados)

    # mapa_produto: TODO id bruto (inclusive o duplicado) -> id canônico
    mapa_produto = produtos.set_index("id_produto")["id_produto_canonico"]
    produtos = produtos[produtos["id_produto"] == produtos["id_produto_canonico"]]

    # --- limpeza: datas em 2 formatos + valor ausente (venda 38) ---
    vendas["id_produto"] = vendas["id_produto"].map(mapa_produto)
    iso = pd.to_datetime(vendas["data_venda"], format="%Y-%m-%d", errors="coerce")
    br = pd.to_datetime(vendas["data_venda"], format="%d/%m/%Y", errors="coerce")
    vendas["data_venda"] = iso.fillna(br)
    vendas["valor_unitario"] = pd.to_numeric(vendas["valor_unitario"], errors="coerce")
    vendas["status_qualidade"] = vendas["valor_unitario"].apply(
        lambda v: "valor_ausente_revisar" if pd.isna(v) else "ok"
    )

    # --- enriquecimento ---
    vendas["receita"] = vendas["quantidade"] * vendas["valor_unitario"]

    # --- modelagem dimensional ---
    dim_produto = produtos[["id_produto", "nome_produto", "categoria"]].drop_duplicates()
    dim_produto.index.name = "sk_produto"
    dim_produto = dim_produto.reset_index(drop=True)
    dim_produto.index.name = "sk_produto"

    dim_cliente = clientes[["id_cliente", "nome_cliente", "cidade", "segmento"]].drop_duplicates()
    dim_cliente.index.name = "sk_cliente"
    dim_cliente = dim_cliente.reset_index(drop=True)
    dim_cliente.index.name = "sk_cliente"

    fato_vendas = vendas.merge(dim_produto.reset_index(), on="id_produto", how="left")
    fato_vendas = fato_vendas.merge(dim_cliente.reset_index(), on="id_cliente", how="left")
    colunas = ["sk_produto", "sk_cliente", "data_venda", "quantidade",
               "valor_unitario", "receita", "status_qualidade"]
    fato_vendas = fato_vendas[colunas]

    return dim_produto, dim_cliente, fato_vendas


def carregar(dim_produto, dim_cliente, fato_vendas, engine):
    dim_produto.to_sql(
        "dim_produto", engine, schema="dw_python",
        if_exists="append", index=True, index_label="sk_produto",
    )
    dim_cliente.to_sql(
        "dim_cliente", engine, schema="dw_python",
        if_exists="append", index=True, index_label="sk_cliente",
    )
    fato_vendas.to_sql(
        "fato_vendas", engine, schema="dw_python",
        if_exists="append", index=False,
    )


def executar_etl():
    print("Iniciando ETL da Vitrine...")
    engine = create_engine(CONEXAO_POSTGRES)
    vendas, clientes, produtos = extrair()
    dim_produto, dim_cliente, fato_vendas = transformar(vendas, clientes, produtos)
    carregar(dim_produto, dim_cliente, fato_vendas, engine)
    print(f"ETL finalizado! {len(dim_produto)} produtos, {len(dim_cliente)} clientes, "
          f"{len(fato_vendas)} vendas carregados em dw_python.*")


if __name__ == "__main__":
    executar_etl()

"""
ETL tradicional (Parte 1) -- o pipeline completo da Vitrine em Python:
extrair() -> transformar() -> carregar(), igual aos slides da aula.

extrair() aqui simplifica para CSV (os mesmos vendas/clientes/produtos da
Semana 4); a API e o scraping (ver scripts/01_extrair_fontes.py) entrariam
do mesmo jeito, como chamadas extras dentro dela.

transformar() reaproveita as mesmas funções de 02_transformar.py (limpeza +
enriquecimento) e 03_construir_dimensional.py (dimensões + fato) -- mesmo
padrão de import que 03_construir_dimensional.py já usa para reaproveitar
02_transformar.py, para não reescrever a mesma lógica pela terceira vez.

carregar() usa to_sql com if_exists="append" -- por isso ele DUPLICA tudo se
for rodado 2x. Isso é de propósito: é exatamente o problema que a Parte 2
(scripts/05_carga_incremental.py) resolve.

Pré-requisito: rodar sql/00_dw_python_schema.sql uma vez (cria o schema
dw_python com as tabelas já com as chaves certas) antes da primeira
execução deste script.

Rode com:  python3 scripts/pipeline_etl.py
"""
import importlib.util
import os
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine

ROOT = Path(__file__).resolve().parent.parent
RAW = ROOT / "raw"
load_dotenv(ROOT / ".env")
DB_PASSWORD = os.environ["DB_PASSWORD"]
CONEXAO_POSTGRES = f"postgresql+psycopg2://postgres:{DB_PASSWORD}@localhost:5432/vitrine"


def _importar(nome_modulo: str, nome_arquivo: str):
    """Importa um script pelo nome do arquivo -- começam com dígito, não dá
    para fazer "import 02_transformar" direto."""
    spec = importlib.util.spec_from_file_location(nome_modulo, ROOT / "scripts" / nome_arquivo)
    modulo = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(modulo)
    return modulo


transformar_mod = _importar("transformar", "02_transformar.py")
dimensional_mod = _importar("dimensional", "03_construir_dimensional.py")


def extrair():
    vendas = pd.read_csv(RAW / "vendas.csv")
    clientes = pd.read_csv(RAW / "clientes.csv")
    produtos = pd.read_csv(RAW / "produtos.csv")
    return vendas, clientes, produtos


def transformar(vendas, clientes, produtos):
    produtos = transformar_mod.tratar_produtos(produtos)
    mapa_produto = produtos.set_index("id_produto")["id_produto_canonico"]
    vendas = transformar_mod.tratar_vendas(vendas, mapa_produto)
    vendas = transformar_mod.enriquecer(vendas)

    dim_produto, dim_cliente = dimensional_mod.construir_dimensoes(produtos, clientes)
    fato_vendas = dimensional_mod.construir_fato(vendas, dim_produto, dim_cliente)
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

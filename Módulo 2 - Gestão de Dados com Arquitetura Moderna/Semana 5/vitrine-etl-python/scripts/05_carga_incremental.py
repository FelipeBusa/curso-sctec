"""
ETL avançado (Parte 2) -- carga incremental: processa só o que é novo ou
mudou desde a última execução, em vez de reprocessar staging.vendas_raw
inteira (o que o pipeline_etl.py, Parte 1, sempre faz).

Pré-requisitos, na ordem:
  1) sql/00_dw_python_schema.sql  (cria dw_python.controle_etl)
  2) scripts/pipeline_etl.py      (carga cheia inicial, 820 vendas)
  3) sql/02_simular_mudancas.sql  (insere a venda "nova" com updated_at = now())

Rode com:  python3 scripts/05_carga_incremental.py
"""
import os
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

ROOT = Path(__file__).resolve().parent.parent
load_dotenv(ROOT / ".env")
DB_PASSWORD = os.environ["DB_PASSWORD"]
CONEXAO_POSTGRES = f"postgresql+psycopg2://postgres:{DB_PASSWORD}@localhost:5432/vitrine"
NOME_PIPELINE = "etl_vendas_vitrine"


def ler_ultima_carga(engine) -> pd.Timestamp:
    controle = pd.read_sql(
        "SELECT ultima_carga FROM dw_python.controle_etl WHERE nome_pipeline = %(nome)s",
        engine,
        params={"nome": NOME_PIPELINE},
    )
    return controle.iloc[0, 0]


def extrair_incremental(engine, ultima_carga: pd.Timestamp) -> pd.DataFrame:
    novos_dados = pd.read_sql(
        "SELECT * FROM staging.vendas_raw WHERE updated_at > %(data)s",
        engine,
        params={"data": ultima_carga},
    )
    print(f"[Incremental] {len(novos_dados)} linha(s) nova(s) ou alterada(s) desde {ultima_carga}")
    return novos_dados


def transformar_incremental(novos_dados: pd.DataFrame, engine) -> pd.DataFrame:
    """Mesma limpeza da Parte 1, mas resolvendo sk_produto/sk_cliente contra
    as dimensões que JÁ estão no banco (não recria dimensão nenhuma aqui)."""
    dim_produto = pd.read_sql("SELECT sk_produto, id_produto FROM dw_python.dim_produto", engine)
    dim_cliente = pd.read_sql("SELECT sk_cliente, id_cliente FROM dw_python.dim_cliente", engine)

    novos_dados["id_produto"] = novos_dados["id_produto"].astype(int)
    novos_dados["id_cliente"] = novos_dados["id_cliente"].astype(int)
    # mesma regra da Parte 1: aceita data ISO ou BR na mesma coluna
    iso = pd.to_datetime(novos_dados["data_venda"], format="%Y-%m-%d", errors="coerce")
    br = pd.to_datetime(novos_dados["data_venda"], format="%d/%m/%Y", errors="coerce")
    novos_dados["data_venda"] = iso.fillna(br)
    novos_dados["quantidade"] = novos_dados["quantidade"].astype(int)
    novos_dados["valor_unitario"] = pd.to_numeric(novos_dados["valor_unitario"], errors="coerce")
    novos_dados["status_qualidade"] = novos_dados["valor_unitario"].apply(
        lambda v: "valor_ausente_revisar" if pd.isna(v) else "ok"
    )
    novos_dados["receita"] = novos_dados["quantidade"] * novos_dados["valor_unitario"]

    fato_novo = novos_dados.merge(dim_produto, on="id_produto", how="left")
    fato_novo = fato_novo.merge(dim_cliente, on="id_cliente", how="left")
    colunas = ["sk_produto", "sk_cliente", "data_venda", "quantidade",
               "valor_unitario", "receita", "status_qualidade"]
    return fato_novo[colunas]


def carregar_incremental(fato_novo: pd.DataFrame, engine):
    fato_novo.to_sql("fato_vendas", engine, schema="dw_python", if_exists="append", index=False)


def avancar_controle(engine):
    # Atenção: a data de controle_etl só avança DEPOIS que a carga é
    # confirmada com sucesso, nunca antes.
    with engine.begin() as conn:
        conn.execute(
            text("UPDATE dw_python.controle_etl SET ultima_carga = now() WHERE nome_pipeline = :nome"),
            {"nome": NOME_PIPELINE},
        )


def executar_carga_incremental():
    engine = create_engine(CONEXAO_POSTGRES)
    ultima_carga = ler_ultima_carga(engine)
    novos_dados = extrair_incremental(engine, ultima_carga)

    if novos_dados.empty:
        print("Nada novo desde a última carga. Nada a fazer.")
        return

    fato_novo = transformar_incremental(novos_dados, engine)
    carregar_incremental(fato_novo, engine)
    avancar_controle(engine)
    print(f"Carga incremental concluída: {len(fato_novo)} linha(s) adicionada(s) a fato_vendas.")


if __name__ == "__main__":
    executar_carga_incremental()

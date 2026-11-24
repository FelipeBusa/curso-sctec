import importlib.util
import os
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

ROOT = Path(__file__).resolve().parent.parent
load_dotenv(ROOT / ".env")
DB_PASSWORD = os.environ["DB_PASSWORD"]
CONEXAO_POSTGRES = f"postgresql+psycopg2://postgres:{DB_PASSWORD}@localhost:5432/vitrine"
NOME_PIPELINE = "etl_populacao_brasil"
ANO_ESTIMATIVA = 2026
DATA_CORTE = "2026-01-01"

_spec = importlib.util.spec_from_file_location("transformar", ROOT / "scripts" / "02_transformar.py")
transformar = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(transformar)

_spec = importlib.util.spec_from_file_location("carga_incremental", ROOT / "scripts" / "04_carga_incremental.py")
carga_incremental = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(carga_incremental)

def fechar_base (alterados, engine):
    with engine.begin() as conn:
       for _, estado in alterados.iterrows():
           conn.execute(
                text(
                    """
                    UPDATE dw_populacao.dim_estado_scd2
                    SET data_fim = :data_corte, registro_atual = false
                    WHERE sigla = :sigla AND ano_referencia = 2022 AND registro_atual = true
                    """
                ),
               {"data_corte" : DATA_CORTE, "sigla": estado["sigla"]},
           )
           conn.execute(
                    text(
                    """
                    INSERT INTO dw_populacao.dim_estado_scd2(
                     id_estado, sigla, nome_estado, regiao, populacao, ano_referencia, data_inicio, data_fim, registro_atual
                    )
                    values(
                     :id_estado, :sigla, :nome_estado, :regiao, :populacao, :ano_referencia, :data_inicio, :data_fim, :registro_atual
                    )
                    """
                ),
                {
                    "id_estado": int(estado["id"]),
                    "sigla": estado["sigla"],
                    "nome_estado": estado["nome"],
                    "regiao": estado["regiao"],
                    "populacao": estado["populacao_2026"],
                    "ano_referencia": ANO_ESTIMATIVA,
                    "data_inicio": DATA_CORTE,
                    "data_fim": None,
                    "registro_atual": True,
                }
           ) 

if __name__ == "__main__":
    engine = create_engine(CONEXAO_POSTGRES)
    populacao_2010 = transformar.extrair_fontes.extrair_populacao_2010_csv()
    estados = transformar.extrair_fontes.extrair_estados_api()
    populacao = transformar.extrair_fontes.extrair_populacao_wikipedia()
    df_unificado = transformar.juntar_fontes(estados, populacao, populacao_2010)

    alterados = carga_incremental.estados_com_populacao_alterada(df_unificado, engine)
    fechar_base(alterados, engine)
    carga_incremental.avancar_controle(engine)


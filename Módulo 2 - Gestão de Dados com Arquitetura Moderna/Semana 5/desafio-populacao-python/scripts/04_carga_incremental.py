"""
Desafio -- Etapa 5: carga incremental. A estimativa 2026 do IBGE chegou
(Etapa 4, o cenário) -- agora é hora de descobrir quais estados realmente
tiveram a população alterada, sem reprocessar os 27 de novo.

A Vitrine usa a Estratégia 1 do slide 36 (updated_at) porque a origem dela
(staging.vendas_raw) tem essa coluna. Aqui não existe um "updated_at" na
Wikipédia -- então usamos a Estratégia 3 do mesmo slide: comparar o valor
ATUAL (que já está em dw_populacao.dim_estado_scd2) com o valor NOVO (que
acabamos de raspar de novo). Só processamos o que realmente mudou.

Pré-requisitos, na ordem:
  1) sql/00_dw_populacao_schema.sql + scripts/03_carga_inicial.py (versões 2010 e 2022)
  2) sql/01_scd_tipo1_correcao.sql (nome do PE corrigido)

Rode com:  python3 scripts/04_carga_incremental.py
"""
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

_spec = importlib.util.spec_from_file_location("transformar", ROOT / "scripts" / "02_transformar.py")
transformar = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(transformar)


def estados_com_populacao_alterada(df_unificado: pd.DataFrame, engine) -> pd.DataFrame:
   """
   Compara a população 2026 com a versão vigente no PostgreSQL.
   Retorna somente os estados cuja população foi alterada.
   """

   # 1. Consultar a população vigente no banco
   query = text("""
      SELECT
         sigla,
         populacao
      FROM dw_populacao.dim_estado_scd2
      WHERE registro_atual = true
   """)

   df_vigente = pd.read_sql(query, engine)

   # 2. Comparar a população nova com a vigente
   df_comparacao = df_unificado.merge(
      df_vigente,
      on="sigla",
      how="inner"
   )

   # 3. Filtrar somente os estados com população diferente
   df_alterados = df_comparacao[
      df_comparacao["populacao_2026"] != df_comparacao["populacao"]
   ].copy()

   # 4. Selecionar as colunas necessárias
   df_alterados = df_alterados[
      ["id", "sigla", "nome", "regiao", "populacao_2026"]
   ]

   print(f"Estados com população alterada: {len(df_alterados)}")
   return df_alterados
    

def avancar_controle(engine):
   """
   Atualiza o controle da ETL somente após o sucesso
   da carga incremental no Data Warehouse.
   """

   query = text("""
      UPDATE dw_populacao.controle_etl
      SET ultima_carga = now()
      WHERE nome_pipeline = :nome_pipeline
   """)

   with engine.begin() as conexao:
      resultado = conexao.execute(
         query,
         {"nome_pipeline": NOME_PIPELINE}
      )
   print(f"Controle ETL atualizado: {resultado.rowcount} registro(s).")

if __name__ == "__main__":
   engine = create_engine(CONEXAO_POSTGRES)

   populacao_2010 = transformar.extrair_fontes.extrair_populacao_2010_csv()
   estados = transformar.extrair_fontes.extrair_estados_api()
   populacao = transformar.extrair_fontes.extrair_populacao_wikipedia()

   df_unificado = transformar.juntar_fontes(
      estados, populacao, populacao_2010
   )

   alterados = estados_com_populacao_alterada(df_unificado, engine)

   print(f"\n{len(alterados)} estado(s) com população alterada para {ANO_ESTIMATIVA}:")
   print(alterados[["sigla", "nome", "populacao_2026"]])

   avancar_controle(engine)
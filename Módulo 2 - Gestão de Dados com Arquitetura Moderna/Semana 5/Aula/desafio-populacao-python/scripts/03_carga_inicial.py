"""
Desafio -- Etapa 2 (parte 2): carga inicial (Full Load). Carrega as DUAS
PRIMEIRAS versões de cada estado em dw_populacao.dim_estado_scd2:

  - Censo 2010 (do CSV): data_inicio = 2010-08-01, data_fim = 2022-08-01,
    registro_atual = false -- já nasce FECHADA, porque o Censo 2022 (que
    também já temos) a sucede. Diferente da Vitrine (que só tinha UMA
    versão inicial): aqui o CSV já trazia o passado pronto, então a carga
    inicial já nasce com histórico.
  - Censo 2022 (da junção API + Wikipédia): data_inicio = 2022-08-01,
    data_fim = NULL, registro_atual = true -- a versão vigente, até a
    Etapa 6 (SCD Tipo 2) abrir a versão 2026.

Pré-requisito: sql/00_dw_populacao_schema.sql já rodado.

ATENÇÃO -- erro de propósito: a linha ERRO_DIGITACAO abaixo simula um erro
real, de alguém que digitou errado no cadastro ANTES de você chegar nesta
carga ("Pernambuco" virou "Pernanbuco") -- nas DUAS versões, 2010 e 2022,
porque é o mesmo nome errado se repetindo. É de propósito: vamos corrigi-lo
na Etapa 3 (SCD Tipo 1). Não corrija aqui -- carregue como está.

Rode com:  python3 scripts/03_carga_inicial.py
"""
import importlib.util
import os
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine

ROOT = Path(__file__).resolve().parent.parent
load_dotenv(ROOT / ".env")
DB_PASSWORD = os.environ["DB_PASSWORD"]
CONEXAO_POSTGRES = f"postgresql+psycopg2://postgres:{DB_PASSWORD}@localhost:5432/vitrine"

ANO_CENSO_2010 = 2010
ANO_CENSO_2022 = 2022
DATA_INICIO_2010 = "2010-08-01"
DATA_INICIO_2022 = "2022-08-01"

# Erro de digitação proposital (ver Etapa 3) -- sigla -> nome errado.
ERRO_DIGITACAO = {"PE": "Pernanbuco"}

_spec = importlib.util.spec_from_file_location("transformar", ROOT / "scripts" / "02_transformar.py")
transformar = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(transformar)


def montar_dim_estado_inicial(df_unificado: pd.DataFrame) -> pd.DataFrame:
    """Recebe o DataFrame já unificado da Etapa 2 (id, sigla, nome, regiao,
    populacao_2010, populacao_2022, populacao_2026) e devolve DUAS linhas
    por estado -- a versão 2010 (fechada) e a versão 2022 (vigente) -- no
    formato de dw_populacao.dim_estado_scd2.

    TODO:
    1. Monte a versão 2010: colunas id_estado (vem de "id"), sigla,
       nome_estado (vem de "nome"), regiao, populacao (vem de
       "populacao_2010"), ano_referencia = ANO_CENSO_2010,
       data_inicio = DATA_INICIO_2010, data_fim = DATA_INICIO_2022 (ela
       termina quando a 2022 começa), registro_atual = False.
    2. Monte a versão 2022: mesmas colunas, populacao (vem de
       "populacao_2022"), ano_referencia = ANO_CENSO_2022,
       data_inicio = DATA_INICIO_2022, data_fim = None, registro_atual =
       True.
    3. Junte as duas com pd.concat([versao_2010, versao_2022],
       ignore_index=True).
    4. Aplique ERRO_DIGITACAO: para a sigla "PE", troque nome_estado pelo
       valor errado do dicionário, nas duas versões (é de propósito, não
       pule este passo).
    5. Devolva o DataFrame pronto para o to_sql() (deve ter 2x o número de
       estados, uma linha 2010 + uma linha 2022 para cada).
    """
    raise NotImplementedError("TODO: Etapa 2 -- montar_dim_estado_inicial()")


def carregar_dim_estado(dim_estado: pd.DataFrame, engine):
    """TODO: grave dim_estado em dw_populacao.dim_estado_scd2 com to_sql(),
    if_exists="append", index=False (sk_estado é serial, o banco gera)."""
    raise NotImplementedError("TODO: Etapa 2 -- carregar_dim_estado()")


if __name__ == "__main__":
    populacao_2010 = transformar.extrair_fontes.extrair_populacao_2010_csv()
    estados = transformar.extrair_fontes.extrair_estados_api()
    populacao = transformar.extrair_fontes.extrair_populacao_wikipedia()
    df_unificado = transformar.juntar_fontes(estados, populacao, populacao_2010)

    dim_estado_inicial = montar_dim_estado_inicial(df_unificado)
    engine = create_engine(CONEXAO_POSTGRES)
    carregar_dim_estado(dim_estado_inicial, engine)
    print(f"Carga inicial concluída: {len(dim_estado_inicial)} linhas (2 versões x "
          f"{len(df_unificado)} estados) em dw_populacao.dim_estado_scd2.")

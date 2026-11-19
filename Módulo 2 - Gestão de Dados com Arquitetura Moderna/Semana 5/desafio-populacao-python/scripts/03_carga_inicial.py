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
import importlib.util #para importar 02_transformar.py
import os #para ler as variaveis de ambiente (a senha do banco -> postgresql)
from pathlib import Path #para montar o caminho do arquivo

import pandas as pd
from dotenv import load_dotenv #ler o arquivo.env
from sqlalchemy import create_engine #criar a conexao com o Postgres

ROOT = Path(__file__).resolve().parent.parent #raiz do projeto
load_dotenv(ROOT / ".env") #pasta scripts/
DB_PASSWORD = os.environ["DB_PASSWORD"] #carregar o DB_PASSWORD do .env
CONEXAO_POSTGRES = f"postgresql+psycopg2://postgres:{DB_PASSWORD}@localhost:5432/ibge"  

ANO_CENSO_2010 = 2010
ANO_CENSO_2022 = 2022
DATA_INICIO_2010 = "2010-01-01"
DATA_INICIO_2022 = "2022-01-01"

# Erro de digitação proposital (ver Etapa 3) -- sigla -> nome errado.
ERRO_DIGITACAO = {"PE": "Pernanbuco"}

#importar o código
_spec = importlib.util.spec_from_file_location("transformar", ROOT / "scripts" / "02_transformar.py")
transformar = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(transformar)


def montar_dim_estado_inicial(df_unificado: pd.DataFrame) -> pd.DataFrame:
    
   v2010 = df_unificado.rename(columns={
      "id": "id_estado", "nome": "nome_estado", "populacao_2010": "populacao",
    })[["id_estado", "sigla", "nome_estado", "regiao", "populacao"]].copy()
   v2010["ano_referencia"] = ANO_CENSO_2010
   v2010["data_inicio"] = DATA_INICIO_2010
   v2010["data_fim"] = DATA_INICIO_2022       # a versão 2010 vale até a versão 2022 começar
   v2010["registro_atual"] = False             # não é mais a versão vigente

   v2022 = df_unificado.rename(columns={
        "id": "id_estado", "nome": "nome_estado", "populacao_2022": "populacao",
    })[["id_estado", "sigla", "nome_estado", "regiao", "populacao"]].copy()
   v2022["ano_referencia"] = ANO_CENSO_2022
   v2022["data_inicio"] = DATA_INICIO_2022
   v2022["data_fim"] = None                     # None vira NULL no banco: ainda não tem "fim"
   v2022["registro_atual"] = True               # esta é a versão vigente, por enquanto

   dim = pd.concat([v2010, v2022], ignore_index=True)   # empilha as 2 versões: 27 estados x 2 = 54 linhas

   # aplica o erro de digitação proposital (ver ATENÇÃO no topo do arquivo) --
   # nas DUAS versões da sigla, porque é o mesmo cadastro errado se repetindo
   for sigla, nome_errado in ERRO_DIGITACAO.items():
      dim.loc[dim["sigla"] == sigla, "nome_estado"] = nome_errado

   return dim

def carregar_dim_estado(dim_estado: pd.DataFrame, engine):
    dim_estado.to_sql(
        "dim_estado_scd2", engine, schema="dw_populacao",
        if_exists="append", index=False,   # append: só insere; se rodar 2x, duplica (não é idempotente)
    )


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

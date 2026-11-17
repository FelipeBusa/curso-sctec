"""
Desafio -- Etapa 2 (parte 1): Transformação de dados.

Objetivo:
Juntar as três fontes da Etapa 1 em um único DataFrame,
com uma linha por unidade federativa.
Estratégias de relacionamento:
1. API + Wikipédia: nome do estado normalizado.
2. API + CSV: sigla do estado.
Execução: python scripts/02_transformar.py
Fontes: scripts/01_extrair_fontes.py
"""

# ============================================================
# 1. IMPORTAÇÃO DAS BIBLIOTECAS
# ============================================================
import importlib.util #para importar o arquivo '01_extrair.ipynb'
import unicodedata #remove acentos
from pathlib import Path
import pandas as pd


# ============================================================
# 2. CONFIGURAÇÕES E MAPEAMENTO DOS DIRETÓRIOS
# ============================================================
ROOT = Path(__file__).resolve().parent.parent

#localiza o arquivo '01_extrair_fontes.ipynb' e dá apelido de 'extrair_fontes'
_spec = importlib.util.spec_from_file_location("extrair_fontes", ROOT / "scripts" / "01_extrair_fontes.py") 

# traz as funções do outro código/arquivo '01_extrair_fontes.py'
extrair_fontes = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(extrair_fontes)


# ============================================================
# 3. LIMPEZA E TRATAMENTO DOS DADOS
# ============================================================
def _sem_acento(texto: str) -> str:
   nfkd = unicodedata.normalize("NFKD", texto)
   return "".join(caractere for caractere in nfkd if not unicodedata.combining(caractere)) #remonta o string descartando acentos


# ============================================================
# 4. INTEGRAÇÃO DAS FONTES DE DADOS
# ============================================================
def juntar_fontes(estados: pd.DataFrame, populacao: pd.DataFrame, populacao_2010: pd.DataFrame) -> pd.DataFrame:
   """Junta estados (API) + populacao (Wikipédia, por nome normalizado) + populacao_2010 (CSV, por sigla)."""
   
   estados = estados.copy()
   populacao = populacao.copy()
   populacao_2010 = populacao_2010.copy()
   
   # Normaliza o nome dos estados na API
   estados["nome_normalizado"] = estados["nome"].apply(lambda nome: _sem_acento(nome.strip().lower()))

   # Normaliza o nome dos estados na Wikipédia
   populacao["nome_normalizado"] = populacao["estado"].apply(lambda nome: _sem_acento(nome.strip().lower()))
   
    TODO:
    1. Crie "nome_normalizado" em estados e em populacao: strip() +
       lower() + _sem_acento() em cima do nome do estado (confira o nome da
       coluna em cada DataFrame -- a Etapa 1 pode ter nomes diferentes).
    2. df = estados.merge(populacao, on="nome_normalizado", how="left").
    3. Confira se ALGUMA linha ficou sem população (populacao_2022 ou
       populacao_2026 nulos) -- indica um nome que não bateu. Se acontecer,
       imprima as linhas problemáticas.
    4. df = df.merge(populacao_2010, on="sigla", how="left") -- essa chave
       é "sigla" (código), não precisa normalizar nada.
    5. Devolva só as colunas finais: id, sigla, nome, regiao,
       populacao_2010, populacao_2022, populacao_2026.
    """
    raise NotImplementedError("TODO: Etapa 2 -- juntar_fontes()")


if __name__ == "__main__":
    populacao_2010 = extrair_fontes.extrair_populacao_2010_csv()
    estados = extrair_fontes.extrair_estados_api()
    populacao = extrair_fontes.extrair_populacao_wikipedia()
    df = juntar_fontes(estados, populacao, populacao_2010)
    print(f"\n{len(df)} estados com população (2010, 2022 e 2026) prontos para carregar.")
    print(df.head())

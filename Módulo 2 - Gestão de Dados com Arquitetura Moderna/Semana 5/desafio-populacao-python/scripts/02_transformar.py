"""
Desafio -- Etapa 2 (parte 1): transformação. Junta as TRÊS fontes da Etapa 1
-- o CSV (sigla, nome_estado, populacao_2010), a API (id/sigla/nome/regiao)
e a Wikipédia (nome/população 2022/2026) -- numa linha por estado.

Duas estratégias de chave aqui:
  - CSV com a API: por "sigla" -- é um código, já vem limpo nas duas fontes,
    não precisa normalizar nada.
  - API com a Wikipédia: por NOME do estado, normalizado (nome_normalizado,
    igual à Vitrine, slide 18) -- strip() + lower() + sem acento. Normalize
    sempre que a chave do merge for texto livre, não um código, mesmo
    quando, como aqui, as duas fontes já estão bem escritas.

Rode com:  python3 scripts/02_transformar.py
Lê de:  as três funções de scripts/01_extrair_fontes.py
"""
import importlib.util #para importar o 01_extrair_fontes.py
import unicodedata #para remover acentos na hora de comparar nomes de estados
from pathlib import Path

import pandas as pd

ROOT = Path(__file__).resolve().parent.parent

#importa o código pelo nome do arquivo
_spec = importlib.util.spec_from_file_location("extrair_fontes", ROOT / "scripts" / "01_extrair_fontes.py")
extrair_fontes = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(extrair_fontes)


def _sem_acento(texto: str) -> str:
    nfkd = unicodedata.normalize("NFKD", texto)
    return "".join(c for c in nfkd if not unicodedata.combining(c)) #remontasse a string descartando os acentos


def juntar_fontes(estados: pd.DataFrame, populacao: pd.DataFrame, populacao_2010: pd.DataFrame) -> pd.DataFrame:
    
    estados = estados.copy()
    populacao = populacao.copy()

    estados["nome_normalizado"] = estados["nome"].str.strip().str.lower().apply(_sem_acento)
    populacao["nome_normalizado"] = populacao["estado"].str.strip().str.lower().apply(_sem_acento)

    df = estados.merge(populacao, on="nome_normalizado", how="left")   # how="left": mantém todos os 27 estados, mesmo sem match
    
    faltando = df[df["populacao_2022"].isna()]                          # linhas onde o merge não achou população = nome não bateu
    if len(faltando):
        print("Estados sem match:")
        print(faltando[["nome"]])

    df = df.merge(populacao_2010, on="sigla", how="left")   # 2ª junção
    return df [["id", "sigla", "nome", "regiao", "populacao_2010", "populacao_2022", "populacao_2026"]]


if __name__ == "__main__":
    populacao_2010 = extrair_fontes.extrair_populacao_2010_csv()
    estados = extrair_fontes.extrair_estados_api()
    populacao = extrair_fontes.extrair_populacao_wikipedia()
    df = juntar_fontes(estados, populacao, populacao_2010)
    print(f"\n{len(df)} estados com população (2010, 2022 e 2026) prontos para carregar.")
    print(df.head())

"""
Dinâmica "Detetives de dados" (aula, Parte 1) -- antes de sair limpando tudo
com Pandas, treine olhar pra uma tabela pequena e apontar os problemas.

A tabela abaixo (a mesma do slide) tem 4 problemas de qualidade de dados,
de propósito:
  - duplicidade        (Ana aparece 2x, só muda a grafia da cidade)
  - inconsistência      ("bh" x "BH": mesma cidade, grafias diferentes)
  - valor ausente        (Maria: cidade nula; Pedro: quantidade nula)
  - valor inconsistente  (João: valor = -50, uma venda não pode ser negativa)

Rode com:  python3 scripts/00_dinamica_detetives_dados.py
"""
import pandas as pd

dados = pd.DataFrame([
    {"cliente": "Ana",   "cidade": "bh",   "quantidade": 2,    "valor": 100},
    {"cliente": "Ana",   "cidade": "BH",   "quantidade": 2,    "valor": 100},
    {"cliente": "João",  "cidade": "SP",   "quantidade": 1,    "valor": -50},
    {"cliente": "Maria", "cidade": None,   "quantidade": 3,    "valor": 200},
    {"cliente": "Pedro", "cidade": "Rio",  "quantidade": None, "valor": 150},
])

print("Tabela bruta:")
print(dados, end="\n\n")

print("1) Duplicidade (mesmo cliente, mesma cidade normalizada, mesmo valor):")
normalizado = dados.assign(cidade_normalizada=dados["cidade"].str.strip().str.lower())
duplicadas = normalizado[normalizado.duplicated(subset=["cliente", "cidade_normalizada", "valor"], keep=False)]
print(duplicadas, end="\n\n")

print("2) Inconsistência de nomenclatura na coluna 'cidade' (mesma cidade, grafias diferentes):")
print(dados["cidade"].dropna().unique(), end="\n\n")

print("3) Valores ausentes:")
print(dados.isna().sum(), end="\n\n")

print("4) Valores fora do domínio esperado (valor negativo):")
print(dados[dados["valor"] < 0], end="\n\n")

print("Resolver com Pandas: drop_duplicates(), str.strip()/str.lower(), fillna()/dropna(), "
      "e uma regra de negócio para o valor negativo (corrigir ou descartar).")

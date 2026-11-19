"""
ETL tradicional (Parte 1) -- limpeza e enriquecimento com Pandas.

Os MESMOS 3 problemas propositais da Semana 4 (produto duplicado, datas em
2 formatos, valor ausente), agora resolvidos em Python/Pandas em vez de SQL
-- para comparar as duas abordagens (ETL x ELT).

Rode com:  python3 scripts/02_transformar.py
Lê de:  raw/produtos.csv, raw/vendas.csv
Grava em:  processed/produtos_tratado.csv, processed/vendas_tratada.csv
"""
import unicodedata
from pathlib import Path

import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
RAW = ROOT / "raw"
PROCESSED = ROOT / "processed"
PROCESSED.mkdir(parents=True, exist_ok=True)


def _sem_acento(texto: str) -> str:
    nfkd = unicodedata.normalize("NFKD", texto)
    return "".join(c for c in nfkd if not unicodedata.combining(c))


def tratar_produtos(produtos: pd.DataFrame) -> pd.DataFrame:
    """Resolve a duplicata (101 / 118, mesmo produto, nome digitado
    diferente -- "Tênis Runner Pro" x "tenis runner pro ") -- igual ao
    slide: normaliza, agrupa, pega o menor id como canônico e mapeia cada
    linha de volta para ele. Aqui a normalização também remove acento,
    porque é exatamente onde 101 e 118 diferem."""
    # nome_normalizado: só para AGRUPAR, não pra exibir
    produtos["nome_normalizado"] = produtos["nome_produto"].str.strip().str.lower().apply(_sem_acento)

    mapa_duplicados = produtos.groupby("nome_normalizado")["id_produto"].min()
    produtos["id_produto_canonico"] = produtos["nome_normalizado"].map(mapa_duplicados)

    duplicatas = produtos[produtos["id_produto"] != produtos["id_produto_canonico"]]
    print(f"produtos: {len(produtos)} linhas brutas, "
          f"{len(duplicatas)} duplicata(s) remapeada(s) para o canônico: "
          f"{dict(zip(duplicatas['id_produto'], duplicatas['id_produto_canonico']))}")

    return produtos


def tratar_vendas(vendas: pd.DataFrame, mapa_produto: pd.Series) -> pd.DataFrame:
    """to_numeric(): nunca inventa um valor. status_qualidade: marca, não
    decide. Datas em 2 formatos (ISO e DD/MM/AAAA) virando 1 só."""
    # produto: reaponta o id duplicado (118) para o canônico (101)
    vendas["id_produto"] = vendas["id_produto"].map(mapa_produto).fillna(vendas["id_produto"])

    # data: aceita ISO (AAAA-MM-DD) OU BR (DD/MM/AAAA) na mesma coluna
    iso = pd.to_datetime(vendas["data_venda"], format="%Y-%m-%d", errors="coerce")
    br = pd.to_datetime(vendas["data_venda"], format="%d/%m/%Y", errors="coerce")
    vendas["data_venda"] = iso.fillna(br)

    # valor ausente: NUNCA inventa um número, só marca para revisão
    vendas["valor_unitario"] = pd.to_numeric(vendas["valor_unitario"], errors="coerce")
    vendas["status_qualidade"] = vendas["valor_unitario"].apply(
        lambda v: "valor_ausente_revisar" if pd.isna(v) else "ok"
    )

    n_ausentes = (vendas["status_qualidade"] == "valor_ausente_revisar").sum()
    print(f"vendas: {len(vendas)} linhas, datas padronizadas, "
          f"{n_ausentes} linha(s) com valor ausente marcada(s) para revisão.")

    return vendas


def enriquecer(vendas: pd.DataFrame) -> pd.DataFrame:
    """Cria o que não existia: receita, ano e mês da venda."""
    vendas["receita"] = vendas["quantidade"] * vendas["valor_unitario"]
    vendas["ano"] = vendas["data_venda"].dt.year
    vendas["mes"] = vendas["data_venda"].dt.month
    print(vendas[["id_venda", "receita", "ano", "mes"]].head())
    return vendas


if __name__ == "__main__":
    produtos = pd.read_csv(RAW / "produtos.csv")
    vendas = pd.read_csv(RAW / "vendas.csv")

    produtos = tratar_produtos(produtos)
    mapa_produto = produtos.set_index("id_produto")["id_produto_canonico"]

    vendas = tratar_vendas(vendas, mapa_produto)
    vendas = enriquecer(vendas)

    produtos.drop(columns=["nome_normalizado"]).to_csv(PROCESSED / "produtos_tratado.csv", index=False)
    vendas.to_csv(PROCESSED / "vendas_tratada.csv", index=False)
    print("\nGravado em processed/produtos_tratado.csv e processed/vendas_tratada.csv")

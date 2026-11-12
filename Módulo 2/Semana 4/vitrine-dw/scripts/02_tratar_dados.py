"""
Demonstração de ETL (Extract -> Transform -> Load) em Python: lê os arquivos
brutos de raw/, corrige os 3 problemas propositais e grava uma versão tratada
em processed/. Isso representa a transformação ANTES de carregar no banco --
o oposto da abordagem ELT, que carrega raw/ direto no Postgres via staging e
só transforma depois, em SQL (ver sql/01_staging_elt_load.sql).

Depois de rodar, compare:
  - raw/produtos.csv  x  processed/produtos_tratado.csv      (duplicata resolvida)
  - raw/vendas.csv    x  processed/vendas_tratada.csv        (datas padronizadas,
                                                                valor ausente sinalizado)
  - processed/mapa_produtos_duplicados.csv  (id duplicado -> id canônico)

Rode com:  python3 scripts/02_tratar_dados.py
"""
import csv
import unicodedata
from datetime import datetime
from pathlib import Path


def normalizar(texto: str) -> str:
    """minúsculo, sem espaços nas pontas, sem acento -- para COMPARAR nomes,
    nunca para exibir (a duplicata do produto 118 difere do 101 só por
    acentuação/maiúsculas/espaço, exatamente o tipo de erro de digitação
    que aparece em sistemas de origem de verdade)."""
    texto = texto.strip().lower()
    texto = unicodedata.normalize("NFKD", texto)
    return "".join(c for c in texto if not unicodedata.combining(c))

ROOT = Path(__file__).resolve().parent.parent
RAW = ROOT / "raw"
PROCESSED = ROOT / "processed"
PROCESSED.mkdir(parents=True, exist_ok=True)


def parse_data(valor: str) -> str:
    """Aceita 'AAAA-MM-DD' ou 'DD/MM/AAAA' e sempre devolve ISO (AAAA-MM-DD)."""
    valor = valor.strip()
    for fmt in ("%Y-%m-%d", "%d/%m/%Y"):
        try:
            return datetime.strptime(valor, fmt).date().isoformat()
        except ValueError:
            continue
    raise ValueError(f"Formato de data não reconhecido: {valor!r}")


def tratar_produtos():
    with open(RAW / "produtos.csv", encoding="utf-8") as f:
        produtos = list(csv.DictReader(f))

    # Normaliza nome (trim + minúsculo + sem acento) para enxergar duplicatas de verdade
    for p in produtos:
        p["nome_normalizado"] = normalizar(p["nome_produto"])

    # Agrupa por (nome_normalizado, preco_unitario) -> mantém o menor id_produto
    # como "canônico" e registra o mapeamento dos ids duplicados para ele.
    canonico_por_chave = {}
    for p in sorted(produtos, key=lambda p: int(p["id_produto"])):
        chave = (p["nome_normalizado"], p["preco_unitario"])
        canonico_por_chave.setdefault(chave, p["id_produto"])

    mapa_duplicatas = {}  # id duplicado -> id canônico
    produtos_tratados = []
    for p in produtos:
        chave = (p["nome_normalizado"], p["preco_unitario"])
        canonico_id = canonico_por_chave[chave]
        if p["id_produto"] != canonico_id:
            mapa_duplicatas[p["id_produto"]] = canonico_id
            continue  # não entra na tabela tratada, vira só um "alias"
        produtos_tratados.append({
            "id_produto": p["id_produto"],
            "nome_produto": p["nome_produto"].strip(),
            "categoria": p["categoria"],
            "marca": p["marca"],
            "preco_unitario": p["preco_unitario"],
            "custo_unitario": p["custo_unitario"],
        })

    with open(PROCESSED / "produtos_tratado.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=["id_produto", "nome_produto", "categoria", "marca", "preco_unitario", "custo_unitario"])
        w.writeheader()
        w.writerows(produtos_tratados)

    with open(PROCESSED / "mapa_produtos_duplicados.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["id_duplicado", "id_canonico"])
        for dup, canon in mapa_duplicatas.items():
            w.writerow([dup, canon])

    print(f"produtos: {len(produtos_tratados)} produtos únicos, "
          f"{len(mapa_duplicatas)} duplicata(s) mapeada(s): {mapa_duplicatas}")
    return mapa_duplicatas


def tratar_vendas(mapa_duplicatas: dict):
    with open(RAW / "vendas.csv", encoding="utf-8") as f:
        vendas = list(csv.DictReader(f))

    linhas_corrigidas = 0
    linhas_sem_valor = 0
    tratadas = []
    for v in vendas:
        v["data_venda"] = parse_data(v["data_venda"])

        # reaponta o produto duplicado para o id canônico
        if v["id_produto"] in mapa_duplicatas:
            v["id_produto"] = mapa_duplicatas[v["id_produto"]]
            linhas_corrigidas += 1

        # valor ausente: marca para revisão em vez de inventar um número
        if v["valor_unitario"].strip() == "":
            v["valor_unitario"] = ""
            v["status_qualidade"] = "valor_ausente_revisar"
            linhas_sem_valor += 1
        else:
            v["status_qualidade"] = "ok"

        tratadas.append(v)

    campos = ["id_venda", "data_venda", "id_cliente", "id_produto", "id_loja",
              "quantidade", "valor_unitario", "desconto", "status_qualidade"]
    with open(PROCESSED / "vendas_tratada.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=campos)
        w.writeheader()
        w.writerows(tratadas)

    print(f"vendas: {len(tratadas)} linhas, datas padronizadas para ISO, "
          f"{linhas_corrigidas} linha(s) remapeada(s) do produto duplicado, "
          f"{linhas_sem_valor} linha(s) com valor ausente marcada(s) para revisão.")


if __name__ == "__main__":
    mapa = tratar_produtos()
    tratar_vendas(mapa)

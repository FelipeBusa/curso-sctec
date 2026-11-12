"""
Gera os dados brutos da loja fictícia "Vitrine" usada neste material.

Roda de forma determinística (seed fixa) para que os números batam sempre
com os mesmos da documentação em docs/resultados_esperados.md.

Saída (pasta raw/ = "entrada do Data Lake"):
  raw/produtos.csv   -> com 1 produto duplicado (nome digitado de forma diferente)
  raw/clientes.csv   -> limpo (dimensão de referência)
  raw/lojas.csv      -> limpo (dimensão de referência)
  raw/vendas.csv     -> com datas em formatos diferentes e 1 valor ausente
  raw/pagamentos.json -> semiestruturado, aninhado por forma de pagamento

Rode com:  python3 scripts/01_gerar_dados_brutos.py
"""
import csv
import json
import random
from datetime import date, timedelta
from pathlib import Path

random.seed(42)

ROOT = Path(__file__).resolve().parent.parent
RAW = ROOT / "raw"
RAW.mkdir(parents=True, exist_ok=True)

# ---------------------------------------------------------------------------
# 1. LOJAS
# ---------------------------------------------------------------------------
lojas = [
    {"id_loja": 1, "nome_loja": "Vitrine Centro", "cidade": "São Paulo", "regiao": "Sudeste"},
    {"id_loja": 2, "nome_loja": "Vitrine Shopping Barra", "cidade": "Salvador", "regiao": "Nordeste"},
    {"id_loja": 3, "nome_loja": "Vitrine Online", "cidade": "Nacional", "regiao": "Nacional"},
]
with open(RAW / "lojas.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=["id_loja", "nome_loja", "cidade", "regiao"])
    w.writeheader()
    w.writerows(lojas)

# ---------------------------------------------------------------------------
# 2. PRODUTOS
#    Observação proposital: o produto 118 é o MESMO produto que o 101,
#    só que digitado errado no sistema de origem ("tenis runner pro ",
#    minúsculo, com espaço sobrando e sem acento). É o "produto com nome
#    duplicado" que aparece de propósito no CSV bruto, para ilustrar um
#    problema real de qualidade de dados.
#    Observação proposital 2: a categoria "Eletrônicos" tem margem bem mais
#    apertada que as demais (custo perto do preço) -- é o que sustenta a
#    pergunta de negócio em sql/03_consultas_negocio.sql ("faturamento maior
#    não significa lucro maior").
# ---------------------------------------------------------------------------
produtos = [
    # Calçados (margem boa)
    {"id_produto": 101, "nome_produto": "Tênis Runner Pro",       "categoria": "Calçados",    "marca": "Nordic",   "preco_unitario": 399.90, "custo_unitario": 180.00},
    {"id_produto": 102, "nome_produto": "Tênis Urbano Classic",   "categoria": "Calçados",    "marca": "Nordic",   "preco_unitario": 289.90, "custo_unitario": 130.00},
    {"id_produto": 103, "nome_produto": "Sandália Trilha",        "categoria": "Calçados",    "marca": "Trailway", "preco_unitario": 219.90, "custo_unitario": 95.00},
    {"id_produto": 104, "nome_produto": "Bota Impermeável",       "categoria": "Calçados",    "marca": "Trailway", "preco_unitario": 459.90, "custo_unitario": 210.00},
    # Vestuário (margem boa)
    {"id_produto": 105, "nome_produto": "Jaqueta Corta-Vento",    "categoria": "Vestuário",   "marca": "Nordic",   "preco_unitario": 329.90, "custo_unitario": 140.00},
    {"id_produto": 106, "nome_produto": "Camiseta Dry Fit",       "categoria": "Vestuário",   "marca": "Nordic",   "preco_unitario": 99.90,  "custo_unitario": 38.00},
    {"id_produto": 107, "nome_produto": "Calça Legging",          "categoria": "Vestuário",   "marca": "Flexa",    "preco_unitario": 149.90, "custo_unitario": 58.00},
    {"id_produto": 108, "nome_produto": "Shorts Running",         "categoria": "Vestuário",   "marca": "Flexa",    "preco_unitario": 119.90, "custo_unitario": 46.00},
    {"id_produto": 109, "nome_produto": "Moletom Canguru",        "categoria": "Vestuário",   "marca": "Nordic",   "preco_unitario": 219.90, "custo_unitario": 90.00},
    # Acessórios (margem ótima)
    {"id_produto": 110, "nome_produto": "Garrafa Térmica 1L",     "categoria": "Acessórios",  "marca": "Flexa",    "preco_unitario": 89.90,  "custo_unitario": 28.00},
    {"id_produto": 111, "nome_produto": "Mochila Trail 20L",      "categoria": "Acessórios",  "marca": "Trailway", "preco_unitario": 249.90, "custo_unitario": 95.00},
    {"id_produto": 112, "nome_produto": "Boné Performance",       "categoria": "Acessórios",  "marca": "Nordic",   "preco_unitario": 69.90,  "custo_unitario": 22.00},
    {"id_produto": 113, "nome_produto": "Meia Compressão (par)",  "categoria": "Acessórios",  "marca": "Flexa",    "preco_unitario": 49.90,  "custo_unitario": 16.00},
    # Eletrônicos (margem apertada -- vende muito, lucra pouco)
    {"id_produto": 114, "nome_produto": "Smartwatch Fit X",       "categoria": "Eletrônicos", "marca": "Pulse",    "preco_unitario": 899.90, "custo_unitario": 790.00},
    {"id_produto": 115, "nome_produto": "Fone Bluetooth Sport",   "categoria": "Eletrônicos", "marca": "Pulse",    "preco_unitario": 349.90, "custo_unitario": 305.00},
    {"id_produto": 116, "nome_produto": "Balança Inteligente",    "categoria": "Eletrônicos", "marca": "Pulse",    "preco_unitario": 259.90, "custo_unitario": 224.00},
    {"id_produto": 117, "nome_produto": "Faixa Cardíaca BT",      "categoria": "Eletrônicos", "marca": "Pulse",    "preco_unitario": 199.90, "custo_unitario": 171.00},
    # Duplicata proposital do produto 101 (erro de cadastro no sistema de origem)
    {"id_produto": 118, "nome_produto": "tenis runner pro ",      "categoria": "Calçados",    "marca": "Nordic",   "preco_unitario": 399.90, "custo_unitario": 180.00},
]
with open(RAW / "produtos.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=["id_produto", "nome_produto", "categoria", "marca", "preco_unitario", "custo_unitario"])
    w.writeheader()
    w.writerows(produtos)

# ---------------------------------------------------------------------------
# 3. CLIENTES
# ---------------------------------------------------------------------------
nomes = [
    "Ana Souza", "Bruno Lima", "Carla Dias", "Diego Alves", "Elisa Rocha", "Felipe Martins",
    "Gabriela Nunes", "Henrique Pires", "Isabela Castro", "João Pedro Melo", "Karina Ramos",
    "Leonardo Fonseca", "Mariana Teixeira", "Nicolas Barros", "Olivia Fernandes", "Paulo Vieira",
    "Queila Andrade", "Rafael Moreira", "Sabrina Costa", "Thiago Azevedo", "Ursula Pinto",
    "Vitor Hugo Araujo", "Wesley Cardoso", "Ximena Duarte", "Yasmin Correia", "Zeca Monteiro",
    "Amanda Freitas", "Bernardo Tavares", "Camila Ribeiro", "Daniel Guimaraes", "Eduarda Lopes",
    "Fabio Antunes", "Giovanna Peixoto", "Hugo Siqueira", "Iris Cavalcante", "Jorge Batista",
    "Laura Macedo", "Marcelo Brandao", "Natalia Farias", "Otavio Rezende", "Patricia Moura",
    "Quintino Salles", "Renata Borges", "Samuel Prado", "Tatiane Gusmao", "Ulisses Campos",
    "Valentina Soares", "William Torres", "Yago Medeiros", "Zilda Franco", "Aline Bezerra",
]
cidades = ["São Paulo", "Salvador", "Belo Horizonte", "Curitiba", "Recife", "Porto Alegre", "Fortaleza", "Brasília"]
clientes = []
for i, nome in enumerate(nomes, start=1):
    cadastro = date(2023, 1, 1) + timedelta(days=random.randint(0, 900))
    clientes.append({
        "id_cliente": i,
        "nome_cliente": nome,
        "cidade": random.choice(cidades),
        "segmento": random.choice(["Novo", "Recorrente", "Recorrente", "Recorrente"]),  # mais recorrente que novo
        "data_cadastro": cadastro.isoformat(),
    })
with open(RAW / "clientes.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=["id_cliente", "nome_cliente", "cidade", "segmento", "data_cadastro"])
    w.writeheader()
    w.writerows(clientes)

# ---------------------------------------------------------------------------
# 4. VENDAS (raw/vendas.csv) -- com os problemas propositais:
#    - datas em dois formatos (ISO e dd/mm/aaaa)
#    - 1 linha com valor_unitario ausente (célula vazia)
#    - usa o id do produto duplicado (118) em algumas linhas, de propósito
# ---------------------------------------------------------------------------
produtos_ids_normais = [p["id_produto"] for p in produtos if p["id_produto"] != 118]
preco_por_produto = {p["id_produto"]: p["preco_unitario"] for p in produtos}

vendas = []
id_venda = 1
start = date(2025, 1, 1)
end = date(2025, 12, 31)
dias_totais = (end - start).days

# distribuição mensal não uniforme (pico em maio e novembro/dezembro) para o
# desafio final (sql/03_consultas_negocio.sql) ter uma resposta interessante
# no "qual mês faturou mais"
peso_mes = {1: 0.9, 2: 0.8, 3: 0.9, 4: 0.95, 5: 1.35, 6: 1.0, 7: 0.95,
            8: 0.9, 9: 1.0, 10: 1.05, 11: 1.3, 12: 1.4}

N_VENDAS = 820
for _ in range(N_VENDAS):
    mes = random.choices(list(peso_mes), weights=list(peso_mes.values()))[0]
    dia = random.randint(1, 28)
    d = date(2025, mes, dia)

    id_cliente = random.randint(1, len(clientes))
    # produto: de vez em quando usa o id "errado" (118) no lugar do 101
    if random.random() < 0.06:
        id_produto = 118
    else:
        # Eletrônicos vende mais unidades (puxa faturamento alto, margem baixa)
        pesos = [3 if p in (114, 115, 116, 117) else 1 for p in produtos_ids_normais]
        id_produto = random.choices(produtos_ids_normais, weights=pesos)[0]

    quantidade = random.choices([1, 2, 3], weights=[0.7, 0.22, 0.08])[0]
    preco = preco_por_produto[id_produto]
    desconto = round(preco * random.choice([0, 0, 0, 0.05, 0.1]) * quantidade, 2)
    id_loja = random.choices([1, 2, 3], weights=[0.4, 0.3, 0.3])[0]

    # formato de data: a maioria ISO, um grupo em dd/mm/aaaa (sistema de PDV antigo)
    if random.random() < 0.18:
        data_str = d.strftime("%d/%m/%Y")
    else:
        data_str = d.isoformat()

    vendas.append({
        "id_venda": id_venda,
        "data_venda": data_str,
        "id_cliente": id_cliente,
        "id_produto": id_produto,
        "id_loja": id_loja,
        "quantidade": quantidade,
        "valor_unitario": preco,
        "desconto": desconto,
    })
    id_venda += 1

# injeta 1 linha com valor_unitario ausente, de propósito (problema real de
# qualidade de dados)
vendas[37]["valor_unitario"] = ""

with open(RAW / "vendas.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=["id_venda", "data_venda", "id_cliente", "id_produto", "id_loja", "quantidade", "valor_unitario", "desconto"])
    w.writeheader()
    w.writerows(vendas)

# ---------------------------------------------------------------------------
# 5. PAGAMENTOS (raw/pagamentos.json) -- semiestruturado, 1 registro por venda,
#    com estrutura aninhada (nem todo dado chega pronto como tabela).
# ---------------------------------------------------------------------------
formas = ["cartao_credito", "cartao_debito", "pix", "boleto"]
pagamentos = []
for v in vendas:
    forma = random.choices(formas, weights=[0.45, 0.2, 0.3, 0.05])[0]
    valor_total = round(v["quantidade"] * v["valor_unitario"] - v["desconto"], 2) if v["valor_unitario"] != "" else None
    reg = {
        "id_pagamento": v["id_venda"],
        "id_venda": v["id_venda"],
        "forma_pagamento": forma,
        "status": random.choices(["aprovado", "aprovado", "aprovado", "estornado"], weights=[0.85, 0.08, 0.05, 0.02])[0],
        "valor_pago": valor_total,
        "data_pagamento": v["data_venda"],
    }
    if forma == "cartao_credito":
        reg["detalhes"] = {
            "bandeira": random.choice(["Visa", "Mastercard", "Elo"]),
            "parcelas": random.choice([1, 1, 2, 3, 6]),
        }
    elif forma == "pix":
        reg["detalhes"] = {"chave_tipo": random.choice(["celular", "email", "aleatoria"])}
    pagamentos.append(reg)

with open(RAW / "pagamentos.json", "w", encoding="utf-8") as f:
    json.dump(pagamentos, f, ensure_ascii=False, indent=2)

print(f"OK: {len(lojas)} lojas, {len(produtos)} produtos (1 duplicado de propósito), "
      f"{len(clientes)} clientes, {len(vendas)} vendas (1 com valor ausente, datas em 2 formatos), "
      f"{len(pagamentos)} pagamentos (JSON aninhado) gerados em raw/.")

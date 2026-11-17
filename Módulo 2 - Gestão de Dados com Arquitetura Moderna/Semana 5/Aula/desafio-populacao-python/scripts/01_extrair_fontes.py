"""
Desafio -- Etapa 1: Extração de dados.
Fontes:
1. CSV: população brasileira no Censo 2010.
2. API: unidades federativas do IBGE.
3. Web Scraping: população brasileira na Wikipédia.
Execução:
   python scripts/01_extrair_fontes.py
"""

# ============================================================
# 1. IMPORTAÇÃO DAS BIBLIOTECAS
# ============================================================
from pathlib import Path
import pandas as pd
import requests
from bs4 import BeautifulSoup


# ============================================================
# 2. CONFIGURAÇÕES E MAPEAMENTO DOS DIRETÓRIOS
# ============================================================
ROOT = Path(__file__).resolve().parent.parent
RAW = ROOT / "raw"

URL_API_ESTADOS = (
   "https://servicodados.ibge.gov.br/api/v1/localidades/estados"
)

URL_WIKIPEDIA_POPULACAO = (
   "https://pt.wikipedia.org/wiki/"
   "Lista_de_unidades_federativas_do_Brasil_por_popula%C3%A7%C3%A3o"
)

USER_AGENT_WIKIPEDIA = {
   "User-Agent": "aula-etl-python-fiesc/1.0 (uso educacional)"
}


# ============================================================
# 3. EXTRAÇÃO DOS DADOS
# ============================================================
def extrair_populacao_2010_csv() -> pd.DataFrame:
   """Fonte 1: Extração do arquivo CSV do Censo 2010."""
   caminho_csv = RAW / "populacao_2010.csv"
   censo2010 = pd.read_csv(caminho_csv)
   print(f"[CSV] Total de linhas: {len(censo2010)}")
   print(censo2010.head())
   return censo2010


def extrair_estados_api() -> pd.DataFrame:
   """Fonte 2: Extração das unidades federativas pela API do IBGE."""
   consulta_ibge = requests.get(URL_API_ESTADOS,timeout=30)
   consulta_ibge.raise_for_status()
   ibge = pd.DataFrame(consulta_ibge.json())
   
   # Extrai o nome da região
   ibge["regiao"] = ibge["regiao"].apply(lambda regiao: regiao["nome"])

   # Seleciona as colunas necessárias
   ibge = ibge[["id", "sigla", "nome", "regiao"]]

   print(f"[API] Total de registros: {len(ibge)}")
   print(ibge.head(3))
   return ibge


def extrair_populacao_wikipedia() -> pd.DataFrame:
   """Fonte 3: Extração da população brasileira pela Wikipédia."""
   consulta_wikipedia = requests.get(
      URL_WIKIPEDIA_POPULACAO,
      timeout=30,
      headers=USER_AGENT_WIKIPEDIA
   )
   consulta_wikipedia.raise_for_status()
   consulta_wikipedia.encoding = "utf-8"
   html = BeautifulSoup(
      consulta_wikipedia.text,
      "html.parser"
   )

   # Localiza a tabela de população
   tabela = html.select_one("table.wikitable")

   if tabela is None:
      raise ValueError("Tabela de população não encontrada na Wikipédia.")

   linhas = tabela.select("tr")[2:]
   dados = []

   for tr in linhas:
      celulas = tr.find_all(["th", "td"])
      if len(celulas) < 3:
         continue

      estado = celulas[0].get_text(strip=True)

      # Exclui a linha de totalização
      if estado == "Total":
         continue

      # Remove espaços comuns e espaços não separáveis
      pop_2026 = int(celulas[1].get_text(strip=True).replace("\xa0", "").replace(" ", ""))
      pop_2022 = int(celulas[2].get_text(strip=True).replace("\xa0", "").replace(" ", ""))
      dados.append({"estado": estado,"populacao_2022": pop_2022,"populacao_2026": pop_2026})

   df = pd.DataFrame(dados)
   print(f"[Wikipedia] Total de registros: {len(df)}")
   print(df.head(5))
   return df


# ============================================================
# 4. EXECUÇÃO PRINCIPAL
# ============================================================
if __name__ == "__main__":
   print("\n========== EXTRAÇÃO DE DADOS ==========\n")
   populacao_2010 = extrair_populacao_2010_csv()

   print("\n--------------------------------------\n")
   estados = extrair_estados_api()

   print("\n--------------------------------------\n")
   populacao = extrair_populacao_wikipedia()

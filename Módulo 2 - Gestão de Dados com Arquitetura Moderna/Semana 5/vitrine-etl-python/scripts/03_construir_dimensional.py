"""
ETL tradicional (Parte 1) -- construindo o Star Schema direto em Python,
com Pandas, em vez de CREATE TABLE + INSERT em SQL (Semana 4).

Reaproveita as funções de tratamento de 02_transformar.py (import direto do
arquivo, sem repetir a lógica) e monta dim_produto, dim_cliente e
fato_vendas com merges. O resultado final (sk_produto/sk_cliente ligando
fato às dimensões) é o MESMO modelo de dw.* da Semana 4 -- só o caminho até
lá que muda.

Rode com:  python3 scripts/03_construir_dimensional.py
"""
import importlib.util
from pathlib import Path

import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
RAW = ROOT / "raw"

# importa 02_transformar.py pelo nome do arquivo (começa com dígito, não dá
# para fazer "import 02_transformar" direto)
_spec = importlib.util.spec_from_file_location("transformar", ROOT / "scripts" / "02_transformar.py")
transformar = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(transformar)


def construir_dimensoes(produtos: pd.DataFrame, clientes: pd.DataFrame):
    """Nascem direto do DataFrame, sem precisar de CREATE TABLE antes.
    Atenção: este índice é só didático -- em produção, sk_produto/sk_cliente
    deveriam vir de uma coluna SERIAL gerada pelo próprio banco (ver
    sql/00_dw_python_schema.sql, onde sk_* já chega pronto do Python)."""
    dim_produto = (
        produtos[produtos["id_produto"] == produtos["id_produto_canonico"]]
        [["id_produto", "nome_produto", "categoria"]]
        .drop_duplicates()
        .reset_index(drop=True)
    )
    dim_produto.index.name = "sk_produto"

    dim_cliente = clientes[["id_cliente", "nome_cliente", "cidade", "segmento"]].drop_duplicates().reset_index(drop=True)
    dim_cliente.index.name = "sk_cliente"

    print(f"dim_produto: {len(dim_produto)} produtos únicos")
    print(f"dim_cliente: {len(dim_cliente)} clientes")
    return dim_produto, dim_cliente


def construir_fato(vendas: pd.DataFrame, dim_produto: pd.DataFrame, dim_cliente: pd.DataFrame) -> pd.DataFrame:
    """Dois merges, duas chaves: sk_produto e sk_cliente conectam o fato às
    dimensões, igual no SQL."""
    fato_vendas = vendas.merge(
        dim_produto.reset_index(), on="id_produto", how="left"
    )
    fato_vendas = fato_vendas.merge(
        dim_cliente.reset_index(), on="id_cliente", how="left"
    )
    colunas = ["sk_produto", "sk_cliente", "data_venda", "quantidade",
               "valor_unitario", "receita", "status_qualidade"]
    fato_vendas = fato_vendas[colunas]
    print(f"fato_vendas: {len(fato_vendas)} linhas")
    return fato_vendas


if __name__ == "__main__":
    produtos = pd.read_csv(RAW / "produtos.csv")
    clientes = pd.read_csv(RAW / "clientes.csv")
    vendas = pd.read_csv(RAW / "vendas.csv")

    produtos = transformar.tratar_produtos(produtos)
    mapa_produto = produtos.set_index("id_produto")["id_produto_canonico"]
    vendas = transformar.tratar_vendas(vendas, mapa_produto)
    vendas = transformar.enriquecer(vendas)

    dim_produto, dim_cliente = construir_dimensoes(produtos, clientes)
    fato_vendas = construir_fato(vendas, dim_produto, dim_cliente)

    print("\ndim_produto:")
    print(dim_produto)
    print("\nfato_vendas (amostra):")
    print(fato_vendas.head())

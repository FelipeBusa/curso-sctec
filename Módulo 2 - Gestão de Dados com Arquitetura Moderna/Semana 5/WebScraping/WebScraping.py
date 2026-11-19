import pandas as pd
import requests
from bs4 import BeautifulSoup

url = 'https://www.estantevirtual.com.br/busca?q='

headers = {
    'User-agent':(
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36'
    )
}

livro = input('Digite o nome do livro ou autor: ')
response = requests.get(url + livro, headers=headers)
response.encoding= 'utf-8'
soup = BeautifulSoup(response.text, 'html.parser')
livros = soup.find_all ('div', attrs={'class': 'product-item product-list__item'})

dados = []

for livro in livros:
    titulo_tag = livro.find('h2', attrs={'class': 'product-item__title product-item__title--mt product-item__name'})
    autor_tag = livro.find('p', attrs={'class': 'product-item__text product-item__text--mt product-item__author'})
    preco_tag = livro.find('span', attrs={'class': 'product-item__sale-price product-item__text--darken'})

    titulo = titulo_tag.text.strip() if titulo_tag else 'Título não encontrado'
    autor = autor_tag.text.strip() if autor_tag else 'Autor não encontrado'
    preco = preco_tag.text.strip() if preco_tag else 'Preço não encontrado'

    print(f"Titulo: {titulo} | Autor: {autor} | Preço: {preco}")

    dados.append({
        'titulo': titulo,
        'autor': autor,
        'preco': preco
    } )

df = pd.DataFrame(dados)
df.to_excel('livros.xlsx', index=False)
print(df)
print(f'{len(df)} livros exportados')
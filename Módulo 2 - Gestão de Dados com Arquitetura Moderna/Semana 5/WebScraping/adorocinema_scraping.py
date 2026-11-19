"""
Web scraping de filmes em cartaz (adorocinema.com)
------------------------------------------------------
O Adorocinema (braço brasileiro do AllOCiné) renderiza a lista de
filmes em cartaz no servidor, sem proteção anti-bot, então dá pra usar
só requests + BeautifulSoup.

Extrai, de cada filme em cartaz:
  - título
  - link
  - data de estreia
  - duração
  - gênero
  - direção

Observação: os links de gênero e direção usam uma classe com um texto
"embaralhado" (provavelmente pra controlar o clique via JavaScript em
vez de um link comum), então lemos só o texto desses elementos, sem
tentar montar um link a partir deles.

No final, os dados coletados são exportados pra uma planilha Excel.
"""

import re

import pandas as pd
import requests
from bs4 import BeautifulSoup

headers = {
    'User-Agent': (
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
        'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36'
    )
}

url = 'https://www.adorocinema.com/filmes/'

response = requests.get(url, headers=headers)
response.encoding = 'utf-8'
site = BeautifulSoup(response.text, 'html.parser')

# Cada filme fica dentro de um <div class="meta ...">
filmes = site.find_all('div', attrs={'class': 'meta'})

if not filmes:
    print('Nenhum filme encontrado. O Adorocinema pode ter mudado o nome')
    print('das classes HTML, nesse caso é preciso inspecionar a página de novo')
    print('(botão direito > Inspecionar) e atualizar os nomes usados no código.')

dados = []

for filme in filmes:
    titulo_link = filme.find('a', attrs={'class': 'meta-title-link'})
    data_tag = filme.find('span', attrs={'class': 'date'})
    genero_tag = filme.find('span', attrs={'class': 'dark-grey-link'})
    direcao_bloco = filme.find('div', attrs={'class': 'meta-body-direction'})

    if not titulo_link:
        continue

    titulo = titulo_link.text.strip()
    link = 'https://www.adorocinema.com' + titulo_link['href']
    estreia = data_tag.text.strip() if data_tag else None
    genero = genero_tag.text.strip() if genero_tag else None

    print('Título:', titulo)
    print('Link:', link)

    if estreia:
        print('Estreia:', estreia)

    # A duração ("2h 05min") é texto solto dentro do bloco de infos,
    # sem uma tag só pra ela, então extraímos com uma expressão regular
    duracao = None
    info_bloco = filme.find('div', attrs={'class': 'meta-body-info'})
    if info_bloco:
        duracao_encontrada = re.search(r'\d+h\s*\d+min', info_bloco.get_text())
        if duracao_encontrada:
            duracao = duracao_encontrada.group()
            print('Duração:', duracao)

    if genero:
        print('Gênero:', genero)

    direcao = None
    if direcao_bloco:
        diretor_tag = direcao_bloco.find('span', attrs={'class': 'dark-grey-link'})
        if diretor_tag:
            direcao = diretor_tag.text.strip()
            print('Direção:', direcao)

    print('\n')

    dados.append({
        'Título': titulo,
        'Estreia': estreia,
        'Duração': duracao,
        'Gênero': genero,
        'Direção': direcao,
        'Link': link,
    })

df = pd.DataFrame(dados)
df.to_excel('filmes_em_cartaz.xlsx', index=False)
print(f'{len(df)} filmes exportados para filmes_em_cartaz.xlsx')

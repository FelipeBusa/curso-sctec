"""
Busca um produto no Mercado Livre e extrai título, link e preço de cada
resultado, exportando tudo para uma planilha Excel.

Usa Selenium (navegador real) em vez de requests porque o Mercado Livre
tem proteção anti-bot que bloqueia requisições simples.
"""

import pandas as pd
from bs4 import BeautifulSoup  # faz o parsing do HTML e permite buscar tags/classes
from selenium import webdriver  # controla um navegador Chrome de verdade via código
from selenium.webdriver.chrome.options import Options  # configura opções do Chrome
from selenium.webdriver.common.by import By  # define o tipo de seletor (ex.: por classe)
from selenium.webdriver.support import expected_conditions as EC  # condições prontas de espera
from selenium.webdriver.support.ui import WebDriverWait  # espera "inteligente" até algo aparecer

url_base = 'https://lista.mercadolivre.com.br/'
produto_nome = input('Qual produto você deseja? ')

opcoes = Options()  # guarda as configurações que serão passadas ao Chrome
opcoes.add_argument('--start-maximized')
opcoes.add_experimental_option('excludeSwitches', ['enable-automation'])  # reduz detecção como bot

navegador = webdriver.Chrome(options=opcoes)  # abre o Chrome de verdade com essas opções

try:
    navegador.get(url_base + produto_nome)

    # espera até 15s existir pelo menos um card de produto na página antes de ler o HTML
    WebDriverWait(navegador, 15).until(
        EC.presence_of_element_located((By.CLASS_NAME, 'ui-search-layout__item'))
    )
    site = BeautifulSoup(navegador.page_source, 'html.parser')  # HTML já com JS executado
finally:
    navegador.quit()  # fecha o navegador mesmo se der erro acima

produtos = site.find_all('li', attrs={'class': 'ui-search-layout__item'})  # cada <li> = um card

if not produtos:
    print('Nenhum produto encontrado. As classes HTML podem ter mudado; inspecione a página novamente.')

dados = []

for produto in produtos:
    titulo_link = produto.find('a', attrs={'class': 'poly-component__title'})  # <a> com título+link
    preco_atual = produto.find('div', attrs={'class': 'poly-price__current'})  # bloco do preço à vista

    real = centavos = None
    if preco_atual:
        real = preco_atual.find('span', attrs={'class': 'andes-money-amount__fraction'})  # parte inteira
        centavos = preco_atual.find('span', attrs={'class': 'andes-money-amount__cents'})  # parte decimal

    if not titulo_link or not real:
        continue  # card sem título/preço no formato esperado (ex.: anúncio)

    titulo = titulo_link.text
    link = titulo_link['href']  # valor do atributo href do link
    preco = real.text + ',' + centavos.text if centavos else real.text  # "inteiro,centavos" ou só inteiro

    print(f'{titulo} | R$ {preco} | {link}\n')

    dados.append({'Título': titulo, 'Preço (R$)': preco, 'Link': link})

df = pd.DataFrame(dados)
df.to_excel('produtos_mercado_livre.xlsx', index=False)
print(f'{len(df)} produtos exportados para produtos_mercado_livre.xlsx')

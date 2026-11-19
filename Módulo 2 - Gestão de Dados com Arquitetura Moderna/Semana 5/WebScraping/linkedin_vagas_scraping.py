"""
Busca vagas no LinkedIn e extrai título, empresa, localização e link de cada
resultado, exportando tudo para uma planilha Excel.

Usa a página pública de vagas (sem precisar estar logado), porque a busca
autenticada bloqueia scraping. Mesmo assim usamos Selenium (navegador real)
em vez de requests, já que o LinkedIn também tem proteção anti-bot.

Limitações (normais nesse tipo de scraping):
- Sem login, o LinkedIn mostra só as primeiras vagas (geralmente ~25).
- As classes HTML podem mudar; se o script parar de achar vagas, inspecione
  a página de novo (botão direito > Inspecionar) e atualize os seletores.
"""

import time
from urllib.parse import quote_plus

import pandas as pd
from bs4 import BeautifulSoup  # faz o parsing do HTML e permite buscar tags/classes
from selenium import webdriver  # controla um navegador Chrome de verdade via código
from selenium.webdriver.chrome.options import Options  # configura opções do Chrome
from selenium.webdriver.common.by import By  # define o tipo de seletor (ex.: por classe)
from selenium.webdriver.support import expected_conditions as EC  # condições prontas de espera
from selenium.webdriver.support.ui import WebDriverWait  # espera "inteligente" até algo aparecer

cargo = input('Qual cargo/vaga você deseja buscar? ')
localizacao = input('Em qual localização? (ex.: Brasil, São Paulo) ')

# quote_plus troca espaços por "+" e escapa acentos/caracteres especiais na URL
url = (
    'https://www.linkedin.com/jobs/search?'
    f'keywords={quote_plus(cargo)}&location={quote_plus(localizacao)}'
)

opcoes = Options()  # guarda as configurações que serão passadas ao Chrome
opcoes.add_argument('--start-maximized')
opcoes.add_experimental_option('excludeSwitches', ['enable-automation'])  # reduz detecção como bot

navegador = webdriver.Chrome(options=opcoes)  # abre o Chrome de verdade com essas opções

try:
    navegador.get(url)

    # espera até 15s existir pelo menos um card de vaga na página antes de ler o HTML
    WebDriverWait(navegador, 15).until(
        EC.presence_of_element_located((By.CLASS_NAME, 'base-card'))
    )

    # rola a página algumas vezes para carregar mais vagas antes de ler o HTML
    for _ in range(3):
        navegador.execute_script('window.scrollTo(0, document.body.scrollHeight);')
        time.sleep(1.5)

    site = BeautifulSoup(navegador.page_source, 'html.parser')  # HTML já com JS executado
finally:
    navegador.quit()  # fecha o navegador mesmo se der erro acima

vagas = site.find_all('div', attrs={'class': 'base-card'})  # cada <div> = um card de vaga

if not vagas:
    print('Nenhuma vaga encontrada. As classes HTML podem ter mudado; inspecione a página novamente.')

dados = []

for vaga in vagas:
    titulo_tag = vaga.find('h3', attrs={'class': 'base-search-card__title'})
    empresa_tag = vaga.find('h4', attrs={'class': 'base-search-card__subtitle'})
    local_tag = vaga.find('span', attrs={'class': 'job-search-card__location'})
    link_tag = vaga.find('a', attrs={'class': 'base-card__full-link'})

    if not titulo_tag or not link_tag:
        continue  # card sem título/link no formato esperado

    titulo = titulo_tag.text.strip()
    empresa = empresa_tag.text.strip() if empresa_tag else 'Não informado'
    local = local_tag.text.strip() if local_tag else 'Não informado'
    link = link_tag['href'].split('?')[0]  # remove parâmetros de rastreamento da URL

    print(f'{titulo} | {empresa} | {local} | {link}\n')

    dados.append({'Vaga': titulo, 'Empresa': empresa, 'Localização': local, 'Link': link})

df = pd.DataFrame(dados)
df.to_excel('vagas_linkedin.xlsx', index=False)
print(f'{len(df)} vagas exportadas para vagas_linkedin.xlsx')

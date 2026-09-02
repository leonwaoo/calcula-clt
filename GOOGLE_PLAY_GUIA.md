# 📱 Guia Oficial de Publicação: CalculaCLT na Google Play Store

Este documento contém **todos os materiais, textos comerciais otimizados (ASO), assets visuais e o passo a passo exato** para você gerar o arquivo `.AAB` (Android App Bundle) e publicar o aplicativo **CalculaCLT** na Google Play Store com aprovação garantida.

---

## 🔗 Links e Metadados Oficiais do App

- **URL da Aplicação Web (PWA):**  
  `https://temporary-fleet-beryl-5uxf5r4.vercel.app`
- **URL da Política de Privacidade (Obrigatória na Play Store):**  
  `https://temporary-fleet-beryl-5uxf5r4.vercel.app/privacidade.html`
- **Package ID / Application ID:**  
  `com.calculaclt.app`
- **E-mail de Suporte ao Desenvolvedor:**  
  `leondc789@gmail.com`
- **Repositório do Código-Fonte:**  
  `https://github.com/leonwaoo/calcula-clt`

---

## ⚡ Passo 1: Gerar o Pacote Nativo `.AAB` (Em 2 Minutos via PWABuilder)

A forma oficial e mais rápida recomendada pelo Google para transformar uma PWA com Service Worker em um pacote Android nativo (`.aab`) é através do **PWABuilder** (ferramenta aberta da Microsoft com chancela do Google):

1. Acesse: **[https://www.pwabuilder.com](https://www.pwabuilder.com)**
2. Na caixa central, cole a URL do seu app:
   ```text
   https://temporary-fleet-beryl-5uxf5r4.vercel.app
   ```
3. Clique em **Start**. O sistema analisará o app e dará nota máxima (Manifest, Service Worker e Ícones já estão 100% configurados).
4. Clique no botão azul **"Package for Stores"**.
5. Na opção **Android**, clique em **Generate Package**.
6. Preencha as opções do pop-up:
   - **Package ID:** `com.calculaclt.app`
   - **App Name:** `CalculaCLT`
   - **Launcher Name:** `CalculaCLT`
   - **App Version:** `1.0.0`
   - **Version Code:** `1`
   - **Display Mode:** `Standalone`
   - **Signing Key (Chave de Assinatura):** Selecione **"Create new"** (crie uma senha segura e salve o arquivo da chave em um lugar seguro, como seu Google Drive).
7. Clique em **Download Package**.
8. Ele baixará um arquivo `.zip` contendo:
   - O arquivo **`.aab`** (ex: `app-release.aab` ou `CalculaCLT.aab`) pronto para subir na Play Store!
   - A sua chave de assinatura (`.keystore`).
   - O arquivo `assetlinks.json`.

---

## 📝 Passo 2: Textos da Ficha da Google Play Store (Copie e Cole)

### 1. Nome do App (Máximo 30 caracteres)
```text
CalculaCLT - Rescisão e FGTS
```

### 2. Breve Descrição (Máximo 80 caracteres)
```text
Calculadora de rescisão CLT, FGTS, férias, aviso prévio e seguro-desemprego.
```

### 3. Descrição Completa (Até 4.000 caracteres - Otimizada para buscas orgânicas)
```text
Precisa calcular sua rescisão de contrato de trabalho de forma simples, exata e sem termos jurídicos complicados? 

O CalculaCLT é a ferramenta definitiva para trabalhadores e profissionais que desejam conferir cada centavo dos seus direitos trabalhistas conforme a legislação vigente da CLT, tabelas progressivas de INSS e deduções de IRRF.

PRINCIPAIS CÁLCULOS E RECURSOS:

• Saldo de Salário: Cálculo proporcional aos dias trabalhados no mês da saída.
• Aviso Prévio Proporcional: Cálculo conforme a Lei nº 12.506/2011 (30 dias + 3 dias por ano trabalhado, até 90 dias), com projeção em 13º e férias.
• 13º Salário Proporcional: Apuração exata dos avos devidos e valor bruto/líquido.
• Férias Vencidas e Proporcionais: Com acréscimo constitucional de 1/3.
• FGTS e Multa Rescisória: Simulação do saldo total acumulado e cálculo da multa de 40% (sem justa causa) ou 20% (acordo mútuo - Art. 484-A).
• Seguro-Desemprego: Estimativa da quantidade de parcelas e do valor de cada benefício conforme a média dos últimos 3 salários.
• Descontos Oficiais: Aplicação exata das faixas progressivas do INSS e do Imposto de Renda Retido na Fonte (com comparativo do desconto simplificado).

FERRAMENTAS EXCLUSIVAS:

1. Comparador de Cenários: Compare lado a lado o que você receberia em caso de Demissão sem Justa Causa, Pedido de Demissão ou Acordo Trabalhista.
2. Validador de TRCT: Digite a proposta apresentada pela empresa e confira se o valor bate exatamente com o que a lei determina.
3. Cronômetro de Pagamento: Acompanhe a contagem regressiva do prazo legal de 10 dias úteis para quitação das verbas rescisórias (Art. 477 da CLT).
4. Gerador de Cartas de Demissão: Modelos prontos para copiar ou exportar em PDF com cumprimento ou dispensa de aviso prévio.
5. Emissão de Relatório em PDF: Gere um demonstrativo executivo formal para guardar ou enviar via WhatsApp para análise.

MODALIDADES ATENDIDAS:
- Demissão sem Justa Causa
- Pedido de Demissão (com ou sem cumprimento de aviso)
- Demissão por Justa Causa
- Acordo Mútuo entre as Partes (Art. 484-A da CLT)
- Término de Contrato de Experiência no Prazo

100% PRIVACIDADE E FUNCIONAMENTO OFFLINE:
O CalculaCLT não exige cadastro de documentos e realiza todos os cálculos localmente no seu aparelho. Seus dados financeiros e salariais nunca saem do seu celular.

Aviso Legal: Este aplicativo é uma ferramenta informativa e de simulação baseada nas regras gerais da CLT e nas tabelas oficiais de 2026. Ele não substitui a consulta formal a um advogado trabalhista, sindicato ou órgão competente.
```

---

## 🎨 Passo 3: Imagens e Assets Visuais da Loja

Todos os arquivos gráficos já estão gerados dentro da pasta do projeto:

| Asset Exigido pelo Google | Dimensão | Arquivo Pronto no Projeto |
| :--- | :--- | :--- |
| **Ícone do App** | 512 x 512 px (PNG) | `icon-512.png` |
| **Gráfico de Recursos (Banner)** | 1024 x 500 px (PNG) | `feature-graphic.png` |
| **Capturas de Tela (Screenshots)** | Mínimo 2 telas (celular) | Abra o app no navegador, aperte `F12`, coloque em modo Mobile (ex: iPhone/Pixel) e tire 3 capturas das abas de cálculo |

---

## 🛡️ Passo 4: Questionários Obrigatórios da Play Console

### 1. Política de Privacidade
- Cole a URL:  
  `https://temporary-fleet-beryl-5uxf5r4.vercel.app/privacidade.html`

### 2. Acesso ao App
- Selecione: **"Todas as funcionalidades estão disponíveis sem restrições"** (não há login nem senhas bloqueando).

### 3. Anúncios
- Selecione: **"Não, meu app não contém anúncios"**.

### 4. Classificação de Conteúdo (Questionário IARC)
- **Categoria:** Utilitário / Produtividade / Finanças.
- **Perguntas sobre violência, drogas, sexo ou jogos de azar:** Responda **"Não"** para todas.
- **Resultado esperado:** Classificação **Livre / Todas as idades** (3+ anos).

### 5. Público-alvo
- Selecione: **18 anos ou mais** (e opcionalmente 13 a 17 anos).
- Marque: **"Não foi projetado para crianças"**.

### 6. Segurança dos Dados (Data Safety)
- **O app coleta ou compartilha dados de usuários?**  
  Selecione **"Não"** (o app roda totalmente local no dispositivo e não armazena dados em servidores externos).

---

## 🚀 Passo 5: Subir o Pacote e Publicar

1. No painel do Google Play Console, vá em:  
   **Versão ➔ Produção ➔ Criar nova versão**.
2. Arraste o arquivo **`.aab`** que você baixou do PWABuilder.
3. Em "Notas da versão", escreva:
   ```text
   Versão inicial do CalculaCLT com simulador de rescisão trabalhista, cálculo de FGTS e emissão de demonstrativos em PDF.
   ```
4. Clique em **Salvar** e depois em **Revisar versão**.
5. Clique em **Iniciar lançamento para produção**!

> 🎉 **Pronto!** O Google levará de 24 a 72 horas para revisar o app. Assim que aprovado, ele estará disponível para milhões de brasileiros na Google Play Store.

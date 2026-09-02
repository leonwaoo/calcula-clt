# OrdemPro — Ordem de Serviço para Autônomos

App Android nativo para profissionais autônomos criarem, organizarem e compartilharem ordens de serviço em PDF. Não usa servidor, não exige cadastro e mantém os dados apenas no aparelho.

## O que já está implementado

- Cadastro local do profissional (nome/empresa, CPF/CNPJ e contato)
- Criação, edição e exclusão de ordens de serviço
- Cliente, contato, serviço, descrição, valor e status
- Histórico local persistente
- PDF profissional e compartilhamento pelo seletor do Android (WhatsApp, e-mail etc.)

## Abrir e gerar o pacote para a Play Store

1. Instale a versão estável mais recente do Android Studio.
2. Escolha **Open** e selecione esta pasta `ordempro`.
3. Espere a sincronização do Gradle. No primeiro uso, o Android Studio baixará os componentes do SDK Android 36 solicitados.
4. Confirme que `applicationId` em `app/build.gradle.kts` será o identificador definitivo. Ele não pode mudar depois do primeiro envio.
5. Em **Build > Generate Signed Bundle / APK**, escolha **Android App Bundle**, crie ou selecione um keystore e gere o arquivo `.aab`.
6. Envie o `.aab` ao Console do Google Play como teste interno antes de produção.

## Informações de cadastro sugeridas

- Nome: OrdemPro — Ordem de Serviço
- Categoria: Produtividade
- Público: profissionais autônomos, MEIs e prestadores de serviços
- Descrição curta: Crie e compartilhe ordens de serviço em PDF, mesmo sem internet.
- Monetização inicial recomendada: versão gratuita com limite de histórico; depois, compra única para histórico ilimitado e personalização. O MVP atual não coleta dados nem exibe anúncios.

## Privacidade

Antes de enviar à Play Store, publique o conteúdo de `privacidade.html` em uma URL pública HTTPS (por exemplo, Vercel, GitHub Pages ou seu site) e informe essa URL no Console do Google Play.

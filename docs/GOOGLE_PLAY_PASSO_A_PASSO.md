# Publicação e recebimento pela Google Play

Este roteiro considera o aplicativo `Calcula CLT`, cujo identificador Android atual é `com.calculaclt.calcula_clt`.

## 1. Criar e verificar a conta de desenvolvedor

1. Acesse [Play Console](https://play.google.com/console) com a conta que será proprietária do aplicativo.
2. Crie a conta de desenvolvedor, escolha corretamente entre perfil pessoal e organização e conclua a verificação de identidade solicitada.
3. Guarde o e-mail proprietário da conta; ele será necessário para permissões, faturamento e suporte.

## 2. Configurar onde o dinheiro será recebido

1. Na Play Console, abra **Configurações > Perfil de pagamentos**.
2. Crie o perfil de pagamentos com nome legal, endereço físico, site e e-mail de suporte. O nome pode aparecer no recibo do cliente.
3. Em **Como você recebe pagamentos**, adicione a conta bancária e conclua a verificação solicitada. O titular, país e moeda precisam atender às exigências do perfil.
4. Defina essa conta como forma principal de recebimento.

Não use uma conta de terceiros. Para um negócio formal, use os dados e a conta bancária da empresa.

## 3. Preparar a versão que será enviada

1. Não altere o identificador `applicationId` depois da primeira publicação.
2. Crie uma chave de upload e configure a assinatura de release no arquivo `android/key.properties`; nunca envie essa chave ao Git.
3. Gere um Android App Bundle:

```powershell
flutter pub get
flutter test
flutter build appbundle --release
```

O arquivo será criado em `build/app/outputs/bundle/release/app-release.aab`.

4. Na primeira publicação, aceite o **Play App Signing**. A Google guarda a chave de assinatura do aplicativo e você usa sua chave de upload para enviar atualizações.

## 4. Criar o aplicativo na Play Console

1. Clique em **Criar app** e informe nome, idioma padrão, tipo **App** e opção gratuita. O app continua gratuito para instalar; a receita vem da compra interna.
2. Preencha a ficha da loja: descrição curta, descrição completa, ícone, imagens, e-mail de suporte e política de privacidade publicada em URL pública.
3. Em **Conteúdo do app**, preencha público-alvo, classificação indicativa, segurança dos dados, anúncios e demais declarações exigidas.
4. Em **Configuração**, declare que o app contém compras no aplicativo.

## 5. Criar a compra do Calcula CLT Pro

1. Abra **Monetizar com a Play > Produtos > Produtos únicos**.
2. Crie o produto com o ID exato `calculaclt_pro_lifetime`.
3. Nome sugerido: `Calcula CLT Pro`.
4. Tipo: **não consumível**, pois o acesso à análise e ao PDF é permanente para a conta que comprou.
5. Defina o preço e os países de venda. Comece com um único preço simples e revise depois de observar conversão e reembolsos.
6. Ative o produto.

## 6. Ligar a validação segura da compra

O aplicativo não deve confiar somente no retorno da tela de pagamento. O fluxo correto é:

1. O usuário toca em **Comprar na Google Play**.
2. A Google Play conclui ou recusa a transação.
3. O app envia o `purchaseToken` e o ID do produto ao seu servidor.
4. O servidor consulta a Google Play Developer API e só responde `{ "valid": true }` quando o estado for `PURCHASED`.
5. Só então o app libera análise e PDF; em erro, cancelamento, reembolso ou token inválido, os recursos ficam bloqueados.
6. Para o produto não consumível, o servidor deve reconhecer/confirmar a compra. Compras não reconhecidas em até três dias podem ser reembolsadas automaticamente.

No código atual, publique esse servidor e forneça a URL na compilação:

```powershell
flutter build appbundle --release --dart-define=PURCHASE_VALIDATION_URL=https://seu-dominio.com/google-play/verify
```

Antes da publicação, configure uma conta de serviço com acesso à Google Play Developer API, mantenha suas credenciais apenas no servidor e registre notificações em tempo real da Play para revogar o acesso quando houver cancelamento ou reembolso.

## 7. Testar antes de cobrar clientes

1. Envie o AAB para **Teste interno** e instale pelo link disponibilizado pela Play Store.
2. Em **Configurações > Testadores de licença**, adicione os e-mails de teste.
3. Faça compras de teste: aprovada, recusada, pendente, restauração de compra e compra já reembolsada.
4. Confirme que apenas uma resposta validada pelo servidor libera o Pro.
5. Para contas pessoais novas, mantenha ao menos 12 testadores no teste fechado, inscritos continuamente por 14 dias, antes de pedir acesso à produção.

## 8. Publicar em produção

1. Crie uma versão em **Produção**, envie o AAB e inclua notas da versão.
2. Revise todos os itens da seção **Visão geral de publicação**.
3. Envie para revisão e publique nos países selecionados após a aprovação.
4. Acompanhe falhas, avaliações, cancelamentos e reembolsos no Play Console.

## Como o pagamento chega até você

1. O cliente paga dentro da Google Play usando os meios de pagamento aceitos no país dele.
2. A Google processa a venda, impostos e a taxa de serviço aplicável.
3. O valor líquido aparece nos relatórios financeiros do Play Console.
4. As transações de um mês são normalmente pagas por volta do dia 15 do mês seguinte, desde que o saldo mínimo seja atingido e a conta bancária esteja verificada. O banco pode levar alguns dias adicionais para creditar.

Exemplo: vendas realizadas em abril entram no ciclo de pagamento de maio. Não é necessário criar PIX, checkout externo ou conta Stripe para vender o recurso digital dentro do app Android.

## Links oficiais

- [Criar perfil de pagamentos](https://support.google.com/googleplay/android-developer/answer/7161426)
- [Adicionar e verificar a conta bancária](https://support.google.com/googleplay/android-developer/answer/13628312)
- [Processamento de pedidos e repasses](https://support.google.com/googleplay/android-developer/answer/137997)
- [Produtos únicos](https://developer.android.com/google/play/billing/one-time-products)
- [Ciclo de compra e validação no servidor](https://developer.android.com/google/play/billing/lifecycle/one-time)
- [Teste de faturamento](https://developer.android.com/google/play/billing/test)
- [Requisitos de teste para contas pessoais novas](https://support.google.com/googleplay/android-developer/answer/14151465)

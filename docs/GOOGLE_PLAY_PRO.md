# Google Play Pro: operação de receita

## Produto e posicionamento

- Produto: `calculaclt_pro_lifetime`
- Tipo no Play Console: produto único, não consumível.
- Oferta: acesso vitalício ao relatório PDF, compartilhamento, memória de cálculo e análise detalhada.
- Gratuito: preenchimento do cenário e resumo financeiro final.

O preço não deve ser gravado no aplicativo. Cadastre preço e mercados no Play Console; a loja devolve o preço localizado ao app.

## Validação obrigatória

O cliente envia o token da compra para `PURCHASE_VERIFIER_URL`. O endpoint Vercel já está em `api/google-play/verify.js`: ele usa uma conta de serviço com acesso à Google Play Developer API, consulta a compra pelo `purchaseToken`, confere `packageName`, `productId` e estado de compra, e responde:

```json
{ "active": true }
```

Sem essa resposta o aplicativo não reconhece o Pro e não conclui a compra. Configure a URL na compilação de release:

```text
flutter build appbundle --release --dart-define=PURCHASE_VERIFIER_URL=https://seu-dominio.com/api/google-play/verify
```

No ambiente da Vercel, configure `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` (o JSON completo da conta de serviço) e, se necessário, `GOOGLE_PLAY_PACKAGE_NAME`. Nunca inclua credenciais da conta de serviço ou chaves privadas no aplicativo.

## Checklist de lançamento

1. Criar o produto único com o ID exato `calculaclt_pro_lifetime`.
2. Publicar um AAB em teste interno e cadastrar contas de licença.
3. Implantar e testar o endpoint de validação com compras reais de teste.
4. Inserir política de privacidade, aviso de simulação e suporte ao usuário na ficha da loja.
5. Gerar chave de upload, ativar Play App Signing e manter a chave fora do Git.
6. Somente promover para produção depois de testar compra, cancelamento, reinstalação e restauração.

## Comandos de entrega

```text
flutter pub get
flutter test
flutter build appbundle --release --dart-define=PURCHASE_VERIFIER_URL=https://SEU_DOMINIO/api/google-play/verify
```

Envie `build/app/outputs/bundle/release/app-release.aab` ao teste interno do Google Play. Instale sempre a versão do teste interno para validar cobrança; o APK instalado diretamente não usa a cobrança de produção.

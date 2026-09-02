# Calcula CLT

Aplicativo Android em Flutter para simulações trabalhistas básicas.

## Recursos

- Simulação inicial de verbas rescisórias.
- Análise detalhada e exportação em PDF reservadas ao acesso profissional.
- A liberação do acesso profissional deve ocorrer exclusivamente após validação da compra pela Google Play.

## Compra pela Google Play

O produto não é liberado pelo aplicativo. Para ativar compras, crie no Google Play Console o produto único `calculaclt_pro_lifetime` e execute o app com `PURCHASE_VALIDATION_URL` apontando para um serviço próprio. Esse serviço deve consultar a Google Play Developer API usando o token de compra e retornar `{ "valid": true }` somente para uma compra reconhecida e ativa. Sem essa variável, o botão permanece indisponível.

## Executar

```powershell
flutter pub get
flutter test
flutter build apk --debug
```

O aplicativo apresenta estimativas. Valores definitivos dependem do contrato, convenção coletiva, documentos e legislação aplicável.

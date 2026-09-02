# CalculaCLT
### Calculadora de Rescisão e Direitos Trabalhistas CLT com Relatórios em PDF

> Aplicativo exclusivamente Android. O cálculo-resumo é gratuito; análise detalhada e exportação de PDF exigem o acesso vitalício Pro, comprado e validado pela Google Play. Veja [a operação do Pro](docs/GOOGLE_PLAY_PRO.md).

Aplicativo Android de alta precisão para cálculo de verbas rescisórias da CLT, projeção de aviso prévio, FGTS com multas (40% ou 20%), tabelas progressivas de INSS e IRPF, estimativa de seguro-desemprego e emissão de demonstrativos formais em PDF.

---

## Modelo de acesso

1. **Alta Intenção de Busca (ASO - App Store Optimization):**
   * O usuário entra na App Store / Play Store buscando diretamente termos como: *"calcular rescisão"*, *"calculadora clt"*, *"seguro desemprego demissão"*, *"aviso prévio proporcional"*.
   * Você não precisa gastar com marketing; o tráfego vem da busca orgânica das lojas.

2. **Monetização Justa e de Alta Conversão:**
   * O resumo do cálculo permanece gratuito.
   * A compra única pelo Google Play libera a análise detalhada e a exportação em PDF.

3. **Custo de Servidor Zero (100% Offline):**
   * O motor de cálculo e o gerador de PDF rodam no próprio aparelho do usuário. Margem de lucro praticamente pura após a taxa das lojas (Apple/Google).

---

## 🏛️ Regras Oficiais Implementadas

* **Aviso Prévio Proporcional (Lei nº 12.506/2011):** 30 dias base + 3 dias por ano completo trabalhado (até 90 dias).
* **Projeção de Aviso Indenizado:** Soma de avos de 13º salário e férias sobre o período de projeção do aviso.
* **Tabela Progressiva do INSS:** Faixas de 7,5%, 9%, 12% e 14% com parcelas a deduzir oficiais.
* **Tabela Progressiva do IRRF:** Comparativo automático entre dedução legal (dependentes) e desconto simplificado mensal (adotando sempre a opção mais benéfica).
* **Modalidades de Rescisão:**
  * Demissão sem Justa Causa (FGTS 40% + Seguro-Desemprego)
  * Pedido de Demissão (com ou sem cumprimento de aviso)
  * Acordo Mútuo - Art. 484-A da CLT (50% aviso indenizado, 20% multa FGTS, saque de 80%)
  * Demissão por Justa Causa (preserva férias vencidas integrais - Súmula 171 TST)
  * Término de Contrato de Experiência no prazo

---

## Como executar

Na primeira execução, gere os arquivos de plataforma Android:

    flutter create --platforms=android --project-name calcula_clt .

### 1. Testar o motor de cálculo no terminal (Instantâneo)
Para simular um cálculo completo no terminal:
```bash
dart run bin/simular.dart
```

### 2. Rodar os testes unitários automatizados
Para rodar a bateria de testes que valida todas as fórmulas e regras legais:
```bash
dart test
```

### 3. Rodar a interface Android no celular ou emulador (Flutter)
```bash
flutter run
```

---

## Estrutura do projeto

```
calcula_clt/
├── bin/
│   └── simular.dart             # Script CLI para simulação no terminal
├── lib/
│   ├── models/
│   │   ├── clt_input.dart       # Entradas (salário, datas, rescisão, aviso)
│   │   └── clt_result.dart      # Saídas (proventos, descontos, FGTS, totais)
│   ├── screens/
│   │   ├── calculator_screen.dart # Formulário com máscaras e seletores
│   │   ├── result_screen.dart     # Dashboard financeiro e extrato
│   │   └── paywall_modal.dart     # Tela de conversão Pro / Pagamento único
│   ├── services/
│   │   ├── clt_calculator_service.dart # Motor jurídico de cálculos CLT
│   │   └── pdf_generator_service.dart  # Emissor de relatório PDF executivo
│   └── main.dart                # Configuração de temas e localização pt_BR
├── test/
│   └── clt_calculator_test.dart # Testes automatizados de todos os cenários
└── pubspec.yaml                 # Configuração do projeto e dependências
```

---

## 📱 Dicas de Lançamento nas Lojas (ASO Checklist)

1. **Título na App Store / Play Store:**
   `CalculaCLT: Rescisão Trabalhista, FGTS e Férias`
2. **Subtítulo (iOS):**
   `Calculadora de Rescisão CLT e Aviso`
3. **Screenshots:**
   * Destaque o valor líquido grande na tela.
   * Destaque: *"Gere seu relatório em PDF com 1 toque para enviar no WhatsApp"*.
   * Destaque: *"Descubra quanto você vai receber de FGTS e Seguro-Desemprego"*.

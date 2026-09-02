import 'package:test/test.dart';
import '../lib/models/clt_input.dart';
import '../lib/services/clt_calculator_service.dart';

void main() {
  group('Testes do Motor de Cálculo CLT (CalculaCLT)', () {
    test('1. Demissão sem Justa Causa com 2 anos de serviço e aviso indenizado', () {
      final input = CltInput(
        baseSalary: 3000.0,
        admissionDate: DateTime(2024, 1, 1),
        dismissalDate: DateTime(2026, 3, 15),
        terminationType: TerminationType.semJustaCausa,
        noticeType: NoticeType.indenizado,
        fgtsBalance: 5000.0,
      );

      final result = CltCalculatorService.calculate(input);

      // 2 anos de casa -> 30 + (2 * 3) = 36 dias de aviso prévio
      expect(result.noticeDays, equals(36));
      expect(result.noticeValue, equals(3600.0)); // (3000/30) * 36

      // Saldo de salário: 15 dias em março
      expect(result.salaryBalanceDays, equals(15));
      expect(result.salaryBalance, equals(1500.0));

      // INSS sobre R$ 1.500 (faixa 1: 7,5%)
      expect(result.inssSalary, closeTo(112.50, 0.01));

      // FGTS: Multa de 40% e direito a saque
      expect(result.fgtsPenaltyRate, equals(0.40));
      expect(result.fgtsWithdrawableAmount, greaterThan(result.fgtsEstimatedBalance));

      // Seguro-Desemprego: Elegível
      expect(result.isEligibleUnemployment, isTrue);
      expect(result.unemploymentInstallments, equals(5));
      expect(result.unemploymentInstallmentValue, greaterThan(0));

      // Verificação do total líquido positivo
      expect(result.netTerminationValue, greaterThan(0));
      expect(result.grandTotalFinancialPackage, greaterThan(result.netTerminationValue));
    });

    test('2. Pedido de Demissão com aviso prévio não cumprido', () {
      final input = CltInput(
        baseSalary: 2500.0,
        admissionDate: DateTime(2025, 1, 10),
        dismissalDate: DateTime(2026, 3, 10),
        terminationType: TerminationType.pedidoDemissao,
        noticeType: NoticeType.naoCumprido,
        fgtsBalance: 2400.0,
      );

      final result = CltCalculatorService.calculate(input);

      // Aviso prévio de pedido de demissão não cumprido gera penalidade de 1 salário
      expect(result.noticePenalty, equals(2500.0));
      expect(result.noticeValue, equals(0.0));

      // No pedido de demissão não saca FGTS
      expect(result.fgtsPenaltyRate, equals(0.0));
      expect(result.fgtsWithdrawableAmount, equals(0.0));

      // No pedido de demissão não tem seguro-desemprego
      expect(result.isEligibleUnemployment, isFalse);
      expect(result.unemploymentInstallments, equals(0));
    });

    test('3. Acordo Mútuo (Art. 484-A da CLT)', () {
      final input = CltInput(
        baseSalary: 4000.0,
        admissionDate: DateTime(2024, 6, 1),
        dismissalDate: DateTime(2026, 6, 1),
        terminationType: TerminationType.acordoMutuo,
        noticeType: NoticeType.indenizado,
        fgtsBalance: 7000.0,
      );

      final result = CltCalculatorService.calculate(input);

      // 2 anos de casa -> 36 dias. No acordo mútuo, recebe 50% do aviso indenizado
      expect(result.noticeDays, equals(36));
      final fullNotice = (4000.0 / 30.0) * 36;
      expect(result.noticeValue, closeTo(fullNotice * 0.5, 0.01));

      // Multa do FGTS de 20%
      expect(result.fgtsPenaltyRate, equals(0.20));

      // Sem seguro-desemprego
      expect(result.isEligibleUnemployment, isFalse);
    });

    test('4. Demissão por Justa Causa preserva férias vencidas integrais', () {
      final input = CltInput(
        baseSalary: 2000.0,
        admissionDate: DateTime(2024, 1, 1),
        dismissalDate: DateTime(2026, 2, 20),
        terminationType: TerminationType.justaCausa,
        noticeType: NoticeType.trabalhado,
        overdueVacationPeriods: 1, // 1 período de férias vencidas
      );

      final result = CltCalculatorService.calculate(input);

      // Perde 13º proporcional e férias proporcionais
      expect(result.proportional13th, equals(0.0));
      expect(result.proportionalVacations, equals(0.0));
      expect(result.noticeValue, equals(0.0));

      // Mantém férias vencidas integrais + 1/3 (Súmula 171 do TST)
      expect(result.overdueVacations, equals(2000.0));
      expect(result.constitutionalThird, closeTo(2000.0 / 3.0, 0.01));

      // Sem saque de FGTS e sem seguro-desemprego
      expect(result.fgtsWithdrawableAmount, equals(0.0));
      expect(result.isEligibleUnemployment, isFalse);
    });

    test('5. Teto de Aviso Prévio limitado a 90 dias (Lei 12.506/11)', () {
      // Funcionário com 25 anos de casa (25 * 3 = 75 + 30 = 105 dias, mas teto é 90)
      final input = CltInput(
        baseSalary: 5000.0,
        admissionDate: DateTime(2000, 1, 1),
        dismissalDate: DateTime(2025, 1, 1),
        terminationType: TerminationType.semJustaCausa,
        noticeType: NoticeType.indenizado,
      );

      final result = CltCalculatorService.calculate(input);
      expect(result.noticeDays, equals(90));
      expect(result.noticeValue, equals(15000.0)); // (5000/30) * 90 = 15000
    });

    test('6. Término de Contrato de Experiência no prazo', () {
      final input = CltInput(
        baseSalary: 3000.0,
        admissionDate: DateTime(2026, 1, 1),
        dismissalDate: DateTime(2026, 3, 31), // 90 dias de experiência
        terminationType: TerminationType.terminoExperiencia,
        noticeType: NoticeType.trabalhado,
        fgtsBalance: 720.0,
      );

      final result = CltCalculatorService.calculate(input);
      // Saca o FGTS mas sem multa rescisória de 40%
      expect(result.fgtsPenaltyRate, equals(0.0));
      expect(result.fgtsWithdrawableAmount, greaterThan(0));
      // Não tem aviso prévio nem seguro-desemprego
      expect(result.noticeValue, equals(0.0));
      expect(result.isEligibleUnemployment, isFalse);
    });
  });
}

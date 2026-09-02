import 'package:intl/intl.dart';
import '../lib/models/clt_input.dart';
import '../lib/services/clt_calculator_service.dart';

void main() {
  final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$ ', decimalDigits: 2);
  final dateFormat = DateFormat('dd/MM/yyyy');

  final input = CltInput(
    baseSalary: 4500.0,
    admissionDate: DateTime(2023, 1, 15),
    dismissalDate: DateTime(2026, 3, 20),
    terminationType: TerminationType.semJustaCausa,
    noticeType: NoticeType.indenizado,
    fgtsBalance: 12400.0,
    dependentsCount: 1,
  );

  final result = CltCalculatorService.calculate(input);

  print('===============================================================');
  print('          CALCULACLT - SIMULAÇÃO OFICIAL DE RESCISÃO           ');
  print('===============================================================');
  print('Salário Base:       ${currency.format(input.baseSalary)}');
  print('Admissão:           ${dateFormat.format(input.admissionDate)}');
  print('Afastamento:        ${dateFormat.format(input.dismissalDate)}');
  print('Tempo de Serviço:   ${result.totalTenureYears} anos (${result.totalTenureDays} dias)');
  print('Tipo de Rescisão:   ${input.terminationType.label}');
  print('Aviso Prévio:       ${input.noticeType.label} (${result.noticeDays} dias - Lei 12.506/11)');
  print('---------------------------------------------------------------');
  print('PROVENTOS (VERBAS RESCISÓRIAS):');
  print('  • Saldo de Salário (${result.salaryBalanceDays} dias):       ${currency.format(result.salaryBalance)}');
  print('  • Aviso Prévio Indenizado:                 ${currency.format(result.noticeValue)}');
  print('  • 13º Proporcional (${result.proportional13thMonths}/12):                  ${currency.format(result.proportional13th)}');
  print('  • 13º s/ Aviso Indenizado (${result.indemnified13thMonths}/12):            ${currency.format(result.indemnified13th)}');
  print('  • Férias Proporcionais (${result.proportionalVacationMonths}/12):             ${currency.format(result.proportionalVacations)}');
  print('  • Férias s/ Aviso Indenizado (${result.indemnifiedVacationMonths}/12):       ${currency.format(result.indemnifiedVacations)}');
  print('  • 1/3 Constitucional de Férias:            ${currency.format(result.constitutionalThird)}');
  print('  TOTAL BRUTO:                               ${currency.format(result.totalGrossEarnings)}');
  print('---------------------------------------------------------------');
  print('DESCONTOS OFICIAIS:');
  print('  • INSS sobre Saldo de Salário:             ${currency.format(result.inssSalary)}');
  print('  • INSS sobre 13º Salário:                  ${currency.format(result.inss13th)}');
  print('  • IRRF sobre Saldo de Salário:             ${currency.format(result.irrfSalary)}');
  print('  • IRRF sobre 13º Salário:                  ${currency.format(result.irrf13th)}');
  print('  TOTAL DE DESCONTOS:                       -${currency.format(result.totalDeductions)}');
  print('===============================================================');
  print('>>> LÍQUIDO A RECEBER NA RESCISÃO:           ${currency.format(result.netTerminationValue)}');
  print('===============================================================');
  print('FGTS & MULTA:');
  print('  • Saldo Estimado + Depósitos:              ${currency.format(result.fgtsEstimatedBalance)}');
  print('  • Multa Rescisória (${(result.fgtsPenaltyRate * 100).toInt()}%):                   ${currency.format(result.fgtsPenalty)}');
  print('  • Total Liberado para Saque:               ${currency.format(result.fgtsWithdrawableAmount)}');
  print('---------------------------------------------------------------');
  print('SEGURO-DESEMPREGO:');
  if (result.isEligibleUnemployment) {
    print('  • Status: APTO');
    print('  • Parcelas: ${result.unemploymentInstallments}x de ${currency.format(result.unemploymentInstallmentValue)}');
    print('  • Valor Total do Benefício:                ${currency.format(result.totalUnemploymentBenefit)}');
  } else {
    print('  • Status: NÃO ELEGÍVEL');
  }
  print('===============================================================');
  print('>>> PACOTE FINANCEIRO TOTAL:                 ${currency.format(result.grandTotalFinancialPackage)}');
  print('===============================================================');
}

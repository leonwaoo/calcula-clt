import 'dart:math';

import '../config/legal_tables.dart';
import '../models/clt_input.dart';
import '../models/clt_result.dart';

class CltCalculatorService {
  /// Executa o cálculo completo da rescisão CLT
  static CltResult calculate(CltInput input) {
    final admission = input.admissionDate;
    final dismissal = input.dismissalDate;
    final salary = input.grossRemuneration;
    final tables = LegalTables.forDate(dismissal);

    // 1. Tempo de serviço
    final totalDays = dismissal.difference(admission).inDays;
    final totalYears = totalDays ~/ 365;

    // 2. Dias de Aviso Prévio (Lei nº 12.506/2011)
    final int noticeDays = _calculateNoticeDays(
      input.terminationType,
      totalYears,
    );

    // 3. Projeção da data final com o aviso indenizado
    final bool isIndemnifiedNotice =
        input.noticeType == NoticeType.indenizado &&
        (input.terminationType == TerminationType.semJustaCausa ||
            input.terminationType == TerminationType.acordoMutuo);

    final DateTime projectedDismissal = isIndemnifiedNotice
        ? dismissal.add(Duration(days: noticeDays))
        : dismissal;

    // 4. Saldo de Salário
    final int salaryBalanceDays = dismissal.day;
    final double salaryBalance = (salary / 30.0) * salaryBalanceDays;

    // 5. Aviso Prévio (Valor a Receber ou Desconto)
    double noticeValue = 0.0;
    double noticePenalty = 0.0;

    if (input.terminationType == TerminationType.semJustaCausa) {
      if (input.noticeType == NoticeType.indenizado) {
        noticeValue = (salary / 30.0) * noticeDays;
      }
    } else if (input.terminationType == TerminationType.acordoMutuo) {
      if (input.noticeType == NoticeType.indenizado) {
        // Art. 484-A, I, 'a': metade do aviso se indenizado
        noticeValue = ((salary / 30.0) * noticeDays) * 0.5;
      }
    } else if (input.terminationType == TerminationType.pedidoDemissao) {
      if (input.noticeType == NoticeType.naoCumprido) {
        // Desconto de 30 dias de salário
        noticePenalty = salary;
      }
    }

    // 6. 13º Salário Proporcional
    int prop13thMonths = 0;
    int ind13thMonths = 0;
    double prop13th = 0.0;
    double ind13th = 0.0;

    if (input.terminationType != TerminationType.justaCausa) {
      prop13thMonths = _calculate13thMonths(admission, dismissal);
      prop13th = (salary / 12.0) * prop13thMonths;

      if (isIndemnifiedNotice) {
        final totalWithNoticeMonths = _calculate13thMonths(
          admission,
          projectedDismissal,
        );
        ind13thMonths = max(0, totalWithNoticeMonths - prop13thMonths);
        ind13th = (salary / 12.0) * ind13thMonths;
      }
    }

    // 7. Férias (Vencidas, Proporcionais e 1/3)
    double overdueVacations = 0.0;
    double propVacations = 0.0;
    double indVacations = 0.0;
    int propVacationMonths = 0;
    int indVacationMonths = 0;

    // Férias vencidas integrais são devidas inclusive na justa causa (Súmula 171 do TST)
    if (input.overdueVacationPeriods > 0) {
      overdueVacations = salary * input.overdueVacationPeriods;
    }

    if (input.terminationType != TerminationType.justaCausa) {
      propVacationMonths = _calculateVacationMonths(admission, dismissal);
      propVacations = (salary / 12.0) * propVacationMonths;

      if (isIndemnifiedNotice) {
        final totalWithNoticeVacMonths = _calculateVacationMonths(
          admission,
          projectedDismissal,
        );
        indVacationMonths = max(
          0,
          totalWithNoticeVacMonths - propVacationMonths,
        );
        indVacations = (salary / 12.0) * indVacationMonths;
      }
    }

    final double totalVacations =
        overdueVacations + propVacations + indVacations;
    final double constitutionalThird = totalVacations / 3.0;

    // 8. Descontos Oficiais: INSS
    final double inssSalary = _calculateProgressiveInss(salaryBalance, tables);
    final double inss13th = (prop13th > 0)
        ? _calculateProgressiveInss(prop13th, tables)
        : 0.0;

    // 9. Descontos Oficiais: IRRF
    final double irrfSalary = _calculateIrrf(
      taxableAmount: salaryBalance,
      inssPaid: inssSalary,
      dependentsCount: input.dependentsCount,
      tables: tables,
    );
    final double irrf13th = (prop13th > 0)
        ? _calculateIrrf(
            taxableAmount: prop13th,
            inssPaid: inss13th,
            dependentsCount: input.dependentsCount,
            tables: tables,
          )
        : 0.0;

    // 10. FGTS e Multa Rescisória
    final double estimatedPriorFgts = (input.fgtsBalance > 0)
        ? input.fgtsBalance
        : (salary * 0.08 * max(1, totalDays ~/ 30));

    // Depósito rescisório: 8% sobre saldo de salário e 13º
    final double terminationDeposit =
        (salaryBalance + prop13th + noticeValue) * 0.08;
    final double totalFgtsBase = estimatedPriorFgts + terminationDeposit;

    double fgtsPenaltyRate = 0.0;
    double fgtsWithdrawableAmount = 0.0;

    if (input.terminationType == TerminationType.semJustaCausa) {
      fgtsPenaltyRate = 0.40;
      fgtsWithdrawableAmount = totalFgtsBase + (totalFgtsBase * 0.40);
    } else if (input.terminationType == TerminationType.acordoMutuo) {
      fgtsPenaltyRate = 0.20;
      // No acordo mútuo, o trabalhador saca até 80% do saldo + multa de 20%
      fgtsWithdrawableAmount = (totalFgtsBase * 0.80) + (totalFgtsBase * 0.20);
    } else if (input.terminationType == TerminationType.terminoExperiencia) {
      // Término de experiência saca 100% do FGTS, mas sem multa de 40%
      fgtsPenaltyRate = 0.0;
      fgtsWithdrawableAmount = totalFgtsBase;
    }

    final double fgtsPenalty = totalFgtsBase * fgtsPenaltyRate;

    // 11. Seguro-Desemprego
    final (
      bool isEligible,
      int installments,
      double installmentValue,
    ) = _calculateUnemploymentBenefit(
      terminationType: input.terminationType,
      tenureMonths: totalDays ~/ 30,
      averageSalary: salary,
      requestCount: input.unemploymentRequestsCount,
      tables: tables,
    );

    return CltResult(
      totalTenureDays: totalDays,
      totalTenureYears: totalYears,
      noticeDays: noticeDays,
      salaryBalanceDays: salaryBalanceDays,
      proportional13thMonths: prop13thMonths,
      indemnified13thMonths: ind13thMonths,
      proportionalVacationMonths: propVacationMonths,
      indemnifiedVacationMonths: indVacationMonths,
      salaryBalance: salaryBalance,
      noticeValue: noticeValue,
      proportional13th: prop13th,
      indemnified13th: ind13th,
      overdueVacations: overdueVacations,
      proportionalVacations: propVacations,
      indemnifiedVacations: indVacations,
      constitutionalThird: constitutionalThird,
      inssSalary: inssSalary,
      inss13th: inss13th,
      irrfSalary: irrfSalary,
      irrf13th: irrf13th,
      noticePenalty: noticePenalty,
      customDeductions: input.customDeductions,
      fgtsEstimatedBalance: totalFgtsBase,
      fgtsTerminationDeposit: terminationDeposit,
      fgtsPenaltyRate: fgtsPenaltyRate,
      fgtsPenalty: fgtsPenalty,
      fgtsWithdrawableAmount: fgtsWithdrawableAmount,
      isEligibleUnemployment: isEligible,
      unemploymentInstallments: installments,
      unemploymentInstallmentValue: installmentValue,
    );
  }

  /// Calcula a quantidade de dias de aviso prévio conforme a Lei nº 12.506/2011
  static int _calculateNoticeDays(TerminationType type, int tenureYears) {
    if (type == TerminationType.pedidoDemissao) {
      // Para o trabalhador que pede demissão, o aviso é sempre 30 dias (Súmula 441 do TST)
      return 30;
    }
    // 30 dias base + 3 dias por ano completo trabalhado, até o limite de 90 dias
    return min(90, 30 + (tenureYears * 3));
  }

  /// Calcula meses de direito a 13º salário no ano corrente
  static int _calculate13thMonths(DateTime admission, DateTime dismissal) {
    final startOfYear = DateTime(dismissal.year, 1, 1);
    final effectiveStart = admission.isAfter(startOfYear)
        ? admission
        : startOfYear;

    int months = 0;
    DateTime current = DateTime(effectiveStart.year, effectiveStart.month, 1);

    while (current.year == dismissal.year && current.month <= dismissal.month) {
      int daysWorkedInMonth;
      if (current.year == effectiveStart.year &&
          current.month == effectiveStart.month) {
        // Primeiro mês considerado
        final lastDayOfMonth = DateTime(current.year, current.month + 1, 0).day;
        daysWorkedInMonth = (lastDayOfMonth - effectiveStart.day) + 1;
      } else if (current.year == dismissal.year &&
          current.month == dismissal.month) {
        // Mês da saída
        daysWorkedInMonth = dismissal.day;
      } else {
        // Mês completo
        daysWorkedInMonth = 30;
      }

      if (daysWorkedInMonth >= 15) {
        months++;
      }

      current = DateTime(current.year, current.month + 1, 1);
    }

    return min(12, max(0, months));
  }

  /// Calcula meses de férias proporcionais no período aquisitivo corrente
  static int _calculateVacationMonths(DateTime admission, DateTime dismissal) {
    // Encontrar o último aniversário de admissão
    int anniversaryYear = dismissal.year;
    DateTime lastAnniversary = DateTime(
      anniversaryYear,
      admission.month,
      admission.day,
    );

    if (lastAnniversary.isAfter(dismissal)) {
      anniversaryYear--;
      lastAnniversary = DateTime(
        anniversaryYear,
        admission.month,
        admission.day,
      );
    }

    final daysInPeriod = dismissal.difference(lastAnniversary).inDays;
    final fullMonths = daysInPeriod ~/ 30;
    final remainingDays = daysInPeriod % 30;

    int months = fullMonths;
    if (remainingDays >= 15) {
      months++;
    }

    return min(12, max(0, months));
  }

  /// Tabela Progressiva Oficial do INSS
  static double _calculateProgressiveInss(double base, LegalTables tables) {
    if (base <= 0) return 0.0;
    var previousCeiling = 0.0;
    var contribution = 0.0;
    for (final band in tables.inssBands) {
      final taxableSlice = min(base, band.ceiling) - previousCeiling;
      if (taxableSlice > 0) contribution += taxableSlice * band.rate;
      if (base <= band.ceiling) break;
      previousCeiling = band.ceiling;
    }
    return contribution;
  }

  /// Tabela Progressiva Oficial do IRRF com comparação do Desconto Simplificado
  static double _calculateIrrf({
    required double taxableAmount,
    required double inssPaid,
    required int dependentsCount,
    required LegalTables tables,
  }) {
    if (taxableAmount <= 0) return 0.0;

    // Opção 1: Dedução legal tradicional (INSS + dependentes)
    final double legalDeductions =
        inssPaid + (dependentsCount * tables.irrfDependentDeduction);
    final double baseLegal = max(0.0, taxableAmount - legalDeductions);

    // Opção 2: Desconto simplificado mensal
    final double baseSimplified = max(
      0.0,
      taxableAmount - tables.irrfSimplifiedDeduction,
    );

    // Usa a base mais benéfica para o trabalhador (a menor base de cálculo)
    final double chosenBase = min(baseLegal, baseSimplified);

    for (final band in tables.irrfBands) {
      if (chosenBase <= band.ceiling) {
        return max(0, (chosenBase * band.rate) - band.deduction);
      }
    }
    return 0;
  }

  /// Regras de Elegibilidade e Cálculo do Seguro-Desemprego
  static (bool, int, double) _calculateUnemploymentBenefit({
    required TerminationType terminationType,
    required int tenureMonths,
    required double averageSalary,
    required int requestCount,
    required LegalTables tables,
  }) {
    if (terminationType != TerminationType.semJustaCausa) {
      return (false, 0, 0.0);
    }

    // Carência mínima conforme a quantidade de solicitações anteriores
    int minMonthsRequired = 12;
    if (requestCount == 1) {
      minMonthsRequired = 9;
    } else if (requestCount >= 2) {
      minMonthsRequired = 6;
    }

    if (tenureMonths < minMonthsRequired) {
      return (false, 0, 0.0);
    }

    // Quantidade de parcelas
    int installments = 3;
    if (requestCount == 0) {
      // 1ª solicitação
      if (tenureMonths >= 24) {
        installments = 5;
      } else if (tenureMonths >= 12) {
        installments = 4;
      }
    } else if (requestCount == 1) {
      // 2ª solicitação
      if (tenureMonths >= 24) {
        installments = 5;
      } else if (tenureMonths >= 12) {
        installments = 4;
      } else {
        installments = 3;
      }
    } else {
      // 3ª solicitação em diante
      if (tenureMonths >= 24) {
        installments = 5;
      } else if (tenureMonths >= 12) {
        installments = 4;
      } else {
        installments = 3;
      }
    }

    // Valor da parcela (Regras oficiais CODEFAT / MTE)
    double installmentValue;
    if (averageSalary <= tables.unemployment.firstLimit) {
      installmentValue = averageSalary * tables.unemployment.firstRate;
    } else if (averageSalary <= tables.unemployment.secondLimit) {
      installmentValue =
          tables.unemployment.secondBase +
          ((averageSalary - tables.unemployment.firstLimit) *
              tables.unemployment.secondRate);
    } else {
      installmentValue = tables.unemployment.cap;
    }

    // O valor não pode ser inferior ao salário mínimo
    installmentValue = max(tables.minimumWage, installmentValue);

    return (true, installments, installmentValue);
  }
}

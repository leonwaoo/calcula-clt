class CltResult {
  // Dados de tempo e aviso
  final int totalTenureDays;
  final int totalTenureYears;
  final int noticeDays;
  final int salaryBalanceDays;
  final int proportional13thMonths;
  final int indemnified13thMonths;
  final int proportionalVacationMonths;
  final int indemnifiedVacationMonths;

  // Proventos
  final double salaryBalance;
  final double noticeValue;
  final double proportional13th;
  final double indemnified13th;
  final double overdueVacations;
  final double proportionalVacations;
  final double indemnifiedVacations;
  final double constitutionalThird;

  // Descontos
  final double inssSalary;
  final double inss13th;
  final double irrfSalary;
  final double irrf13th;
  final double noticePenalty;
  final double customDeductions;

  // FGTS
  final double fgtsEstimatedBalance;
  final double fgtsTerminationDeposit;
  final double fgtsPenaltyRate; // 0.40 ou 0.20 ou 0.0
  final double fgtsPenalty;
  final double fgtsWithdrawableAmount;

  // Seguro-Desemprego
  final bool isEligibleUnemployment;
  final int unemploymentInstallments;
  final double unemploymentInstallmentValue;

  const CltResult({
    required this.totalTenureDays,
    required this.totalTenureYears,
    required this.noticeDays,
    required this.salaryBalanceDays,
    required this.proportional13thMonths,
    required this.indemnified13thMonths,
    required this.proportionalVacationMonths,
    required this.indemnifiedVacationMonths,
    required this.salaryBalance,
    required this.noticeValue,
    required this.proportional13th,
    required this.indemnified13th,
    required this.overdueVacations,
    required this.proportionalVacations,
    required this.indemnifiedVacations,
    required this.constitutionalThird,
    required this.inssSalary,
    required this.inss13th,
    required this.irrfSalary,
    required this.irrf13th,
    required this.noticePenalty,
    required this.customDeductions,
    required this.fgtsEstimatedBalance,
    required this.fgtsTerminationDeposit,
    required this.fgtsPenaltyRate,
    required this.fgtsPenalty,
    required this.fgtsWithdrawableAmount,
    required this.isEligibleUnemployment,
    required this.unemploymentInstallments,
    required this.unemploymentInstallmentValue,
  });

  // Totais calculados
  double get totalGrossEarnings =>
      salaryBalance +
      noticeValue +
      proportional13th +
      indemnified13th +
      overdueVacations +
      proportionalVacations +
      indemnifiedVacations +
      constitutionalThird;

  double get totalDeductions =>
      inssSalary +
      inss13th +
      irrfSalary +
      irrf13th +
      noticePenalty +
      customDeductions;

  double get netTerminationValue => (totalGrossEarnings - totalDeductions) > 0
      ? (totalGrossEarnings - totalDeductions)
      : 0.0;

  double get totalUnemploymentBenefit => isEligibleUnemployment
      ? (unemploymentInstallments * unemploymentInstallmentValue)
      : 0.0;

  double get grandTotalFinancialPackage =>
      netTerminationValue + fgtsWithdrawableAmount + totalUnemploymentBenefit;
}

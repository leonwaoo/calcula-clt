class CltSimulation {
  const CltSimulation({
    required this.salary,
    required this.monthsWorked,
    required this.daysWorked,
    required this.noticePaid,
  });
  final double salary;
  final int monthsWorked;
  final int daysWorked;
  final bool noticePaid;
}

class CltResult {
  const CltResult({
    required this.salaryBalance,
    required this.notice,
    required this.proportionalVacation,
    required this.vacationBonus,
    required this.proportionalThirteenth,
  });
  final double salaryBalance;
  final double notice;
  final double proportionalVacation;
  final double vacationBonus;
  final double proportionalThirteenth;
  double get total =>
      salaryBalance +
      notice +
      proportionalVacation +
      vacationBonus +
      proportionalThirteenth;
}

class CltCalculator {
  const CltCalculator();
  CltResult simulate(CltSimulation input) {
    final months = input.monthsWorked.clamp(0, 12);
    final days = input.daysWorked.clamp(0, 30);
    final vacation = input.salary * months / 12;
    return CltResult(
      salaryBalance: input.salary * days / 30,
      notice: input.noticePaid ? input.salary : 0,
      proportionalVacation: vacation,
      vacationBonus: vacation / 3,
      proportionalThirteenth: input.salary * months / 12,
    );
  }
}

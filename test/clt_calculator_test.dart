import 'package:calcula_clt/clt_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calcula verbas proporcionais e aviso indenizado', () {
    const calculator = CltCalculator();
    final result = calculator.simulate(
      const CltSimulation(
        salary: 2400,
        monthsWorked: 6,
        daysWorked: 30,
        noticePaid: true,
      ),
    );
    expect(result.salaryBalance, 2400);
    expect(result.notice, 2400);
    expect(result.proportionalVacation, 1200);
    expect(result.vacationBonus, 400);
    expect(result.proportionalThirteenth, 1200);
    expect(result.total, 7600);
  });
}

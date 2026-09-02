import 'package:calcula_clt/config/legal_tables.dart';
import 'package:test/test.dart';

void main() {
  group('LegalTables', () {
    test('selects the table valid at the dismissal date', () {
      expect(LegalTables.forDate(DateTime(2025, 12, 31)).minimumWage, 1518);
      expect(LegalTables.forDate(DateTime(2026, 1, 1)).minimumWage, 1621);
    });

    test('keeps every table traceable to an official source', () {
      for (final table in LegalTables.all) {
        expect(table.source, startsWith('https://www.gov.br/'));
        expect(table.inssBands, isNotEmpty);
        expect(table.irrfBands, isNotEmpty);
      }
    });
  });
}

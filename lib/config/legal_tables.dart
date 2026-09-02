/// Versioned tax and social-security tables used by the calculation engine.
///
/// Update this file only with a published rule and keep its source URL and
/// effective date. The engine chooses the latest table effective on dismissal.
class LegalTables {
  const LegalTables({
    required this.effectiveFrom,
    required this.source,
    required this.minimumWage,
    required this.inssBands,
    required this.irrfBands,
    required this.irrfDependentDeduction,
    required this.irrfSimplifiedDeduction,
    required this.unemployment,
  });

  final DateTime effectiveFrom;
  final String source;
  final double minimumWage;
  final List<ProgressiveBand> inssBands;
  final List<IrrfBand> irrfBands;
  final double irrfDependentDeduction;
  final double irrfSimplifiedDeduction;
  final UnemploymentTable unemployment;

  static final List<LegalTables> all = [
    LegalTables(
      effectiveFrom: DateTime(2025, 1, 1),
      source: 'https://www.gov.br/inss/pt-br/direitos-e-deveres/inscricao-e-contribuicao/tabela-de-contribuicao-mensal',
      minimumWage: 1518,
      inssBands: [
        ProgressiveBand(1518, .075),
        ProgressiveBand(2793.88, .09),
        ProgressiveBand(4190.83, .12),
        ProgressiveBand(8157.41, .14),
      ],
      irrfBands: [
        IrrfBand(2259.20, 0, 0),
        IrrfBand(2826.65, .075, 169.44),
        IrrfBand(3751.05, .15, 381.44),
        IrrfBand(4664.68, .225, 662.77),
        IrrfBand(double.infinity, .275, 896),
      ],
      irrfDependentDeduction: 189.59,
      irrfSimplifiedDeduction: 564.80,
      unemployment: UnemploymentTable(
        firstLimit: 2041.39,
        secondLimit: 3402.65,
        firstRate: .8,
        secondBase: 1633.10,
        secondRate: .5,
        cap: 2313.74,
      ),
    ),
    LegalTables(
      effectiveFrom: DateTime(2026, 1, 1),
      source: 'https://www.gov.br/inss/pt-br/direitos-e-deveres/inscricao-e-contribuicao/tabela-de-contribuicao-mensal',
      minimumWage: 1621,
      inssBands: [
        ProgressiveBand(1621, .075),
        ProgressiveBand(2902.84, .09),
        ProgressiveBand(4354.27, .12),
        ProgressiveBand(8475.55, .14),
      ],
      irrfBands: [
        IrrfBand(2428.80, 0, 0),
        IrrfBand(2826.65, .075, 182.16),
        IrrfBand(3751.05, .15, 394.16),
        IrrfBand(4664.68, .225, 675.49),
        IrrfBand(double.infinity, .275, 908.73),
      ],
      irrfDependentDeduction: 189.59,
      irrfSimplifiedDeduction: 607.20,
      // Confirm the annual CODEFAT publication before a 2026 Play release.
      unemployment: UnemploymentTable(
        firstLimit: 2041.39,
        secondLimit: 3402.65,
        firstRate: .8,
        secondBase: 1633.10,
        secondRate: .5,
        cap: 2313.74,
      ),
    ),
  ];

  static LegalTables forDate(DateTime date) {
    return all.lastWhere(
      (table) => !table.effectiveFrom.isAfter(date),
      orElse: () => all.first,
    );
  }
}

class ProgressiveBand {
  const ProgressiveBand(this.ceiling, this.rate);
  final double ceiling;
  final double rate;
}

class IrrfBand {
  const IrrfBand(this.ceiling, this.rate, this.deduction);
  final double ceiling;
  final double rate;
  final double deduction;
}

class UnemploymentTable {
  const UnemploymentTable({
    required this.firstLimit,
    required this.secondLimit,
    required this.firstRate,
    required this.secondBase,
    required this.secondRate,
    required this.cap,
  });

  final double firstLimit;
  final double secondLimit;
  final double firstRate;
  final double secondBase;
  final double secondRate;
  final double cap;
}

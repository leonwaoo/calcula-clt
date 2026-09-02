enum TerminationType {
  semJustaCausa,
  pedidoDemissao,
  acordoMutuo,
  justaCausa,
  terminoExperiencia;

  String get label {
    switch (this) {
      case TerminationType.semJustaCausa:
        return 'Demissão sem Justa Causa';
      case TerminationType.pedidoDemissao:
        return 'Pedido de Demissão';
      case TerminationType.acordoMutuo:
        return 'Acordo Mútuo (Art. 484-A)';
      case TerminationType.justaCausa:
        return 'Demissão com Justa Causa';
      case TerminationType.terminoExperiencia:
        return 'Término de Contrato de Experiência';
    }
  }

  String get description {
    switch (this) {
      case TerminationType.semJustaCausa:
        return 'Empregador demite o funcionário sem motivo grave. Garante todos os direitos, FGTS + 40% e seguro-desemprego.';
      case TerminationType.pedidoDemissao:
        return 'O empregado pede para sair. Não tem direito ao saque do FGTS, nem à multa de 40%, nem ao seguro-desemprego.';
      case TerminationType.acordoMutuo:
        return 'Acordo entre as partes. Recebe metade do aviso indenizado, 20% de multa do FGTS e saca até 80% do saldo.';
      case TerminationType.justaCausa:
        return 'Motivo grave cometido pelo empregado. Perde 13º proporcional, férias proporcionais, FGTS e seguro.';
      case TerminationType.terminoExperiencia:
        return 'Final natural do prazo contratado. Saca FGTS sem multa de 40%, não tem seguro nem aviso prévio.';
    }
  }
}

enum NoticeType {
  trabalhado,
  indenizado,
  dispensado,
  naoCumprido;

  String get label {
    switch (this) {
      case NoticeType.trabalhado:
        return 'Trabalhado';
      case NoticeType.indenizado:
        return 'Indenizado pela Empresa';
      case NoticeType.dispensado:
        return 'Dispensado pela Empresa (sem desconto)';
      case NoticeType.naoCumprido:
        return 'Não Cumprido (com desconto)';
    }
  }
}

class CltInput {
  final double baseSalary;
  final double additionalEarnings; // Horas extras médias, insalubridade, etc.
  final DateTime admissionDate;
  final DateTime dismissalDate;
  final TerminationType terminationType;
  final NoticeType noticeType;
  final int overdueVacationPeriods; // Quantidade de férias vencidas integrais (0, 1, 2...)
  final int dependentsCount; // Número de dependentes para IRRF
  final double fgtsBalance; // Saldo do FGTS para fins rescisórios (opcional/estimável)
  final double customDeductions; // Descontos adicionais (faltas, adiantamentos, etc.)
  final int unemploymentRequestsCount; // 0 para primeira vez, 1 para segunda, 2+ para terceira

  const CltInput({
    required this.baseSalary,
    this.additionalEarnings = 0.0,
    required this.admissionDate,
    required this.dismissalDate,
    required this.terminationType,
    required this.noticeType,
    this.overdueVacationPeriods = 0,
    this.dependentsCount = 0,
    this.fgtsBalance = 0.0,
    this.customDeductions = 0.0,
    this.unemploymentRequestsCount = 0,
  });

  double get grossRemuneration => baseSalary + additionalEarnings;
}

import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/clt_input.dart';
import '../models/clt_result.dart';

class PdfGeneratorService {
  static final _currencyFormat =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);
  static final _dateFormat = DateFormat('dd/MM/yyyy');

  /// Gera os bytes do documento PDF completo
  static Future<Uint8List> generateTerminationReport({
    required CltInput input,
    required CltResult result,
    String workerName = 'Trabalhador(a)',
    String companyName = 'Empresa Empregadora',
    bool isPro = false,
  }) async {
    final doc = pw.Document();

    final primaryColor = PdfColor.fromHex('#1E3A8A'); // Azul institucional
    final secondaryColor = PdfColor.fromHex('#059669'); // Verde aprovação
    final dangerColor = PdfColor.fromHex('#DC2626'); // Vermelho desconto
    final grayBackground = PdfColor.fromHex('#F3F4F6');

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Cabeçalho
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: primaryColor,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'DEMONSTRATIVO DE RESCISÃO CONTRATUAL',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Simulação com base na Legislação Trabalhista (CLT)',
                      style: const pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'CalculaCLT',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      _dateFormat.format(DateTime.now()),
                      style: const pw.TextStyle(color: PdfColors.white, fontSize: 8),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (!isPro)
            pw.Container(
              margin: const pw.EdgeInsets.only(top: 8),
              padding: const pw.EdgeInsets.all(6),
              alignment: pw.Alignment.center,
              color: PdfColor.fromHex('#FEF3C7'),
              child: pw.Text(
                'DOCUMENTO GERADO NA VERSÃO GRATUITA - CalculaCLT App',
                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#92400E'),
                ),
              ),
            ),

          pw.SizedBox(height: 16),

          // Dados do Contrato
          pw.Text(
            '1. DADOS DO CONTRATO DE TRABALHO',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: primaryColor),
          ),
          pw.SizedBox(height: 6),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: grayBackground,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Column(
              children: [
                _buildDataRow('Colaborador(a):', workerName, 'Empregador:', companyName),
                pw.SizedBox(height: 4),
                _buildDataRow(
                  'Data de Admissão:',
                  _dateFormat.format(input.admissionDate),
                  'Data de Afastamento:',
                  _dateFormat.format(input.dismissalDate),
                ),
                pw.SizedBox(height: 4),
                _buildDataRow(
                  'Tipo de Rescisão:',
                  input.terminationType.label,
                  'Aviso Prévio:',
                  '${input.noticeType.label} (${result.noticeDays} dias)',
                ),
                pw.SizedBox(height: 4),
                _buildDataRow(
                  'Salário Base:',
                  _currencyFormat.format(input.baseSalary),
                  'Tempo de Casa:',
                  '${result.totalTenureYears} ano(s) e ${(result.totalTenureDays % 365) ~/ 30} mês(es)',
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 14),

          // Tabela de Proventos
          pw.Text(
            '2. VERBAS RESCISÓRIAS (PROVENTOS)',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: secondaryColor),
          ),
          pw.SizedBox(height: 6),
          _buildItemTable(
            items: [
              _TableItem('Saldo de Salário', '${result.salaryBalanceDays} dias trabalhados', result.salaryBalance),
              if (result.noticeValue > 0)
                _TableItem('Aviso Prévio Indenizado', 'Lei nº 12.506/2011 (${result.noticeDays} dias)', result.noticeValue),
              if (result.proportional13th > 0)
                _TableItem('13º Salário Proporcional', '${result.proportional13thMonths}/12 avos', result.proportional13th),
              if (result.indemnified13th > 0)
                _TableItem('13º Salário s/ Aviso Indenizado', '${result.indemnified13thMonths}/12 avos projetados', result.indemnified13th),
              if (result.overdueVacations > 0)
                _TableItem('Férias Vencidas Integrais', '${input.overdueVacationPeriods} período(s)', result.overdueVacations),
              if (result.proportionalVacations > 0)
                _TableItem('Férias Proporcionais', '${result.proportionalVacationMonths}/12 avos', result.proportionalVacations),
              if (result.indemnifiedVacations > 0)
                _TableItem('Férias s/ Aviso Indenizado', '${result.indemnifiedVacationMonths}/12 avos projetados', result.indemnifiedVacations),
              if (result.constitutionalThird > 0)
                _TableItem('1/3 Constitucional de Férias', 'Art. 7º, XVII da CF/88', result.constitutionalThird),
            ],
            totalLabel: 'TOTAL DE PROVENTOS BRUTOS:',
            totalValue: result.totalGrossEarnings,
            totalColor: secondaryColor,
          ),

          pw.SizedBox(height: 14),

          // Tabela de Descontos
          pw.Text(
            '3. DESCONTOS LEGAIS',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: dangerColor),
          ),
          pw.SizedBox(height: 6),
          _buildItemTable(
            items: [
              if (result.inssSalary > 0)
                _TableItem('INSS sobre Saldo de Salário', 'Tabela Progressiva Oficial', result.inssSalary),
              if (result.inss13th > 0)
                _TableItem('INSS sobre 13º Salário', 'Tabela Progressiva Oficial', result.inss13th),
              if (result.irrfSalary > 0)
                _TableItem('IRRF sobre Saldo de Salário', 'Com dedução de dependentes', result.irrfSalary),
              if (result.irrf13th > 0)
                _TableItem('IRRF sobre 13º Salário', 'Tributação exclusiva na fonte', result.irrf13th),
              if (result.noticePenalty > 0)
                _TableItem('Aviso Prévio Não Cumprido', 'Desconto legal de 1 mês', result.noticePenalty),
              if (result.customDeductions > 0)
                _TableItem('Outros Descontos/Adiantamentos', 'Informado pelo usuário', result.customDeductions),
            ],
            totalLabel: 'TOTAL DE DESCONTOS:',
            totalValue: result.totalDeductions,
            totalColor: dangerColor,
          ),

          pw.SizedBox(height: 14),

          // Destaque do Valor Líquido
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#ECFDF5'),
              border: pw.Border.all(color: secondaryColor, width: 2),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'VALOR LÍQUIDO A RECEBER NA RESCISÃO:',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: primaryColor),
                ),
                pw.Text(
                  _currencyFormat.format(result.netTerminationValue),
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: secondaryColor),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 14),

          // FGTS e Seguro-Desemprego
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // FGTS
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('4. FGTS & MULTA',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: primaryColor)),
                      pw.SizedBox(height: 4),
                      _buildSimpleRow('Saldo Base:', _currencyFormat.format(result.fgtsEstimatedBalance)),
                      _buildSimpleRow('Multa Rescisória (${(result.fgtsPenaltyRate * 100).toInt()}%):',
                          _currencyFormat.format(result.fgtsPenalty)),
                      pw.Divider(thickness: 0.5),
                      _buildSimpleRow(
                        'Total Disponível Saque:',
                        _currencyFormat.format(result.fgtsWithdrawableAmount),
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 12),
              // Seguro-Desemprego
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('5. SEGURO-DESEMPREGO',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: primaryColor)),
                      pw.SizedBox(height: 4),
                      _buildSimpleRow('Elegibilidade:', result.isEligibleUnemployment ? 'SIM (Apto)' : 'NÃO'),
                      if (result.isEligibleUnemployment) ...[
                        _buildSimpleRow('Parcelas Estimadas:', '${result.unemploymentInstallments} parcelas'),
                        _buildSimpleRow('Valor por Parcela:', _currencyFormat.format(result.unemploymentInstallmentValue)),
                        pw.Divider(thickness: 0.5),
                        _buildSimpleRow(
                          'Benefício Total:',
                          _currencyFormat.format(result.totalUnemploymentBenefit),
                          isBold: true,
                        ),
                      ] else ...[
                        pw.SizedBox(height: 8),
                        pw.Text(
                          'Modalidade de rescisão ou tempo de carência não conferem direito ao benefício.',
                          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 16),

          // Rodapé informativo
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: grayBackground,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Text(
              'Aviso Legal: Este demonstrativo é uma estimativa com fins informativos baseada na CLT, Lei 12.506/2011 e tabelas vigentes de INSS e IRRF. Não substitui o Termo de Rescisão de Contrato de Trabalho (TRCT) homologado.',
              style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  /// Compartilha o PDF diretamente com o WhatsApp ou outros apps
  static Future<void> printOrShareReport({
    required CltInput input,
    required CltResult result,
    bool isPro = false,
  }) async {
    final pdfBytes = await generateTerminationReport(
      input: input,
      result: result,
      isPro: isPro,
    );

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'Rescisao_CLT_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  static pw.Widget _buildDataRow(String label1, String val1, String label2, String val2) {
    return pw.Row(
      children: [
        pw.Expanded(
          child: pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(text: '$label1 ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                pw.TextSpan(text: val1, style: const pw.TextStyle(fontSize: 8)),
              ],
            ),
          ),
        ),
        pw.Expanded(
          child: pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(text: '$label2 ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                pw.TextSpan(text: val2, style: const pw.TextStyle(fontSize: 8)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSimpleRow(String label, String val, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(fontSize: 8, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(val,
              style: pw.TextStyle(fontSize: 8, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ],
      ),
    );
  }

  static pw.Widget _buildItemTable({
    required List<_TableItem> items,
    required String totalLabel,
    required double totalValue,
    required PdfColor totalColor,
  }) {
    return pw.Column(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: PdfColors.grey200,
          child: pw.Row(
            children: [
              pw.Expanded(flex: 3, child: pw.Text('Rubrica / Descrição', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8))),
              pw.Expanded(flex: 3, child: pw.Text('Referência Legal / Base', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8))),
              pw.Expanded(flex: 2, child: pw.Text('Valor (R\$)', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8))),
            ],
          ),
        ),
        ...items.map((item) => pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5)),
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(flex: 3, child: pw.Text(item.name, style: const pw.TextStyle(fontSize: 8))),
                  pw.Expanded(flex: 3, child: pw.Text(item.reference, style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700))),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      _currencyFormat.format(item.value),
                      textAlign: pw.TextAlign.right,
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                ],
              ),
            )),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          color: PdfColor.fromHex('#F9FAFB'),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(totalLabel, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: totalColor)),
              pw.Text(_currencyFormat.format(totalValue), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: totalColor)),
            ],
          ),
        ),
      ],
    );
  }
}

class _TableItem {
  final String name;
  final String reference;
  final double value;

  _TableItem(this.name, this.reference, this.value);
}

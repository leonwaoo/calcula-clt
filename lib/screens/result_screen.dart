import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/clt_input.dart';
import '../models/clt_result.dart';
import '../services/pdf_generator_service.dart';
import '../services/pro_access_service.dart';
import 'paywall_modal.dart';

class ResultScreen extends StatefulWidget {
  final CltInput input;
  final CltResult result;

  const ResultScreen({super.key, required this.input, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );
  final _dateFormat = DateFormat('dd/MM/yyyy');

  bool _isProUser = false;
  bool _isGeneratingPdf = false;
  late final ProAccessService _proAccess;
  StreamSubscription<ProAccessStatus>? _proSubscription;

  @override
  void initState() {
    super.initState();
    _proAccess = ProAccessService();
    _proSubscription = _proAccess.status.listen((status) {
      if (!mounted) return;
      setState(() => _isProUser = status == ProAccessStatus.pro);
      if (status == ProAccessStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível validar a compra. Tente restaurar suas compras.',
            ),
          ),
        );
      }
    });
    _proAccess.initialize();
  }

  @override
  void dispose() {
    _proSubscription?.cancel();
    _proAccess.dispose();
    super.dispose();
  }

  void _onExportPdfPressed() async {
    if (!_isProUser) {
      await PaywallModal.show(context, _proAccess);
    } else {
      _generateAndSharePdf();
    }
  }

  void _generateAndSharePdf() async {
    setState(() => _isGeneratingPdf = true);
    try {
      await PdfGeneratorService.printOrShareReport(
        input: widget.input,
        result: widget.result,
        isPro: _isProUser,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erro ao gerar PDF: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPdf = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = widget.result;
    final input = widget.input;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Resultado da Rescisão',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          if (!_isProUser)
            TextButton.icon(
              onPressed: () async {
                await PaywallModal.show(context, _proAccess);
              },
              icon: const Icon(Icons.star, color: Color(0xFFF59E0B), size: 18),
              label: const Text(
                'PRO',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB45309),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Resumo do contrato
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.badge_outlined,
                    color: Color(0xFF3B82F6),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          input.terminationType.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_dateFormat.format(input.admissionDate)} até ${_dateFormat.format(input.dismissalDate)} (${result.totalTenureYears}a ${(result.totalTenureDays % 365) ~/ 30}m)',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // HERO CARD: Valor Líquido a Receber na Rescisão
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF065F46), Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF059669).withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'LÍQUIDO A RECEBER NA RESCISÃO',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Na Conta',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _currencyFormat.format(result.netTerminationValue),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Bruto: ${_currencyFormat.format(result.totalGrossEarnings)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Descontos: -${_currencyFormat.format(result.totalDeductions)}',
                        style: const TextStyle(
                          color: Color(0xFFFECACA),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // CARDS SECUNDÁRIOS: FGTS + SEGURO
            Row(
              children: [
                // Card FGTS
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 16,
                              color: Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'FGTS + Multa ${(result.fgtsPenaltyRate * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _currencyFormat.format(result.fgtsWithdrawableAmount),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: result.fgtsWithdrawableAmount > 0
                                ? const Color(0xFF1E3A8A)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          result.fgtsWithdrawableAmount > 0
                              ? 'Disponível p/ Saque'
                              : 'Sem direito a saque',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Card Seguro-Desemprego
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.shield_outlined,
                              size: 16,
                              color: Color(0xFF7C3AED),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Seguro-Desemprego',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          result.isEligibleUnemployment
                              ? '${result.unemploymentInstallments}x ${_currencyFormat.format(result.unemploymentInstallmentValue)}'
                              : 'Inapto',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: result.isEligibleUnemployment
                                ? const Color(0xFF5B21B6)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          result.isEligibleUnemployment
                              ? 'Total: ${_currencyFormat.format(result.totalUnemploymentBenefit)}'
                              : 'Sem direito',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Card do Pacote Financeiro Total
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PACOTE FINANCEIRO TOTAL',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E40AF),
                        ),
                      ),
                      Text(
                        'Rescisão + FGTS Saque + Seguro',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _currencyFormat.format(result.grandTotalFinancialPackage),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E40AF),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            if (_isProUser) ...[
              Text(
                'Análise detalhada de verbas',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              _buildSectionCard(
                title: 'Verbas Rescisórias (Proventos)',
                total: result.totalGrossEarnings,
                color: const Color(0xFF059669),
                items: [
                  _buildRowItem(
                    'Saldo de Salário (${result.salaryBalanceDays} dias)',
                    result.salaryBalance,
                  ),
                  if (result.noticeValue > 0)
                    _buildRowItem(
                      'Aviso Prévio Indenizado (${result.noticeDays} dias)',
                      result.noticeValue,
                    ),
                  if (result.proportional13th > 0)
                    _buildRowItem(
                      '13º Salário Proporcional (${result.proportional13thMonths}/12)',
                      result.proportional13th,
                    ),
                  if (result.indemnified13th > 0)
                    _buildRowItem(
                      '13º s/ Aviso Indenizado (${result.indemnified13thMonths}/12)',
                      result.indemnified13th,
                    ),
                  if (result.overdueVacations > 0)
                    _buildRowItem(
                      'Férias Vencidas Integrais',
                      result.overdueVacations,
                    ),
                  if (result.proportionalVacations > 0)
                    _buildRowItem(
                      'Férias Proporcionais (${result.proportionalVacationMonths}/12)',
                      result.proportionalVacations,
                    ),
                  if (result.indemnifiedVacations > 0)
                    _buildRowItem(
                      'Férias s/ Aviso Indenizado (${result.indemnifiedVacationMonths}/12)',
                      result.indemnifiedVacations,
                    ),
                  if (result.constitutionalThird > 0)
                    _buildRowItem(
                      '1/3 Constitucional de Férias',
                      result.constitutionalThird,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              _buildSectionCard(
                title: 'Descontos Oficiais',
                total: result.totalDeductions,
                color: const Color(0xFFDC2626),
                isDeduction: true,
                items: [
                  if (result.inssSalary > 0)
                    _buildRowItem(
                      'INSS sobre Saldo de Salário',
                      result.inssSalary,
                      isDeduction: true,
                    ),
                  if (result.inss13th > 0)
                    _buildRowItem(
                      'INSS sobre 13º Salário',
                      result.inss13th,
                      isDeduction: true,
                    ),
                  if (result.irrfSalary > 0)
                    _buildRowItem(
                      'IRRF sobre Saldo de Salário',
                      result.irrfSalary,
                      isDeduction: true,
                    ),
                  if (result.irrf13th > 0)
                    _buildRowItem(
                      'IRRF sobre 13º Salário',
                      result.irrf13th,
                      isDeduction: true,
                    ),
                  if (result.noticePenalty > 0)
                    _buildRowItem(
                      'Desconto de Aviso Não Cumprido',
                      result.noticePenalty,
                      isDeduction: true,
                    ),
                  if (result.customDeductions > 0)
                    _buildRowItem(
                      'Outros Descontos/Adiantamentos',
                      result.customDeductions,
                      isDeduction: true,
                    ),
                ],
              ),
            ] else
              _buildProAnalysisCard(),

            const SizedBox(height: 24),

            // BOTÃO DE EXPORTAÇÃO PDF (MONETIZAÇÃO)
            ElevatedButton.icon(
              onPressed: _isGeneratingPdf ? null : _onExportPdfPressed,
              icon: _isGeneratingPdf
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.picture_as_pdf_rounded, size: 20),
              label: Text(
                _isGeneratingPdf
                    ? 'Gerando Relatório...'
                    : 'EXPORTAR RELATÓRIO EM PDF',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 3,
              ),
            ),

            const SizedBox(height: 12),

            // Caixa de Avaliação ASO
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.thumb_up_alt_outlined,
                    color: Color(0xFFB45309),
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'O CalculaCLT te ajudou a entender seus direitos? Avalie nosso app com 5 estrelas na loja!',
                      style: TextStyle(fontSize: 11, color: Color(0xFF92400E)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required double total,
    required Color color,
    required List<Widget> items,
    bool isDeduction = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: color,
                  ),
                ),
                Text(
                  '${isDeduction ? '-' : ''}${_currencyFormat.format(total)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Column(children: items),
          ),
        ],
      ),
    );
  }

  Widget _buildProAnalysisCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF5FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9D5FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Color(0xFF7E22CE)),
              SizedBox(width: 8),
              Text(
                'Análise detalhada é Pro',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF581C87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Desbloqueie a memória de cálculo, rubricas, descontos, fundamentos legais e o relatório PDF compartilhável.',
            style: TextStyle(fontSize: 12, color: Color(0xFF6B21A8)),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => PaywallModal.show(context, _proAccess),
            icon: const Icon(Icons.lock_open),
            label: const Text('DESBLOQUEAR ANÁLISE PRO'),
          ),
        ],
      ),
    );
  }

  Widget _buildRowItem(String label, double value, {bool isDeduction = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
            ),
          ),
          Text(
            '${isDeduction ? '-' : ''}${_currencyFormat.format(value)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDeduction
                  ? const Color(0xFFDC2626)
                  : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

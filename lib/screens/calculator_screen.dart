import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/clt_input.dart';
import '../services/clt_calculator_service.dart';
import 'result_screen.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateFormat = DateFormat('dd/MM/yyyy');

  // Controladores de texto
  final _salaryController = TextEditingController(text: '3000,00');
  final _additionalsController = TextEditingController();
  final _fgtsBalanceController = TextEditingController();
  final _customDeductionsController = TextEditingController();

  // Estados
  DateTime _admissionDate = DateTime.now().subtract(
    const Duration(days: 730),
  ); // 2 anos atrás
  DateTime _dismissalDate = DateTime.now();
  TerminationType _terminationType = TerminationType.semJustaCausa;
  NoticeType _noticeType = NoticeType.indenizado;
  int _overdueVacationsCount = 0;
  int _dependentsCount = 0;
  int _unemploymentRequestsCount = 0;

  @override
  void dispose() {
    _salaryController.dispose();
    _additionalsController.dispose();
    _fgtsBalanceController.dispose();
    _customDeductionsController.dispose();
    super.dispose();
  }

  double _parseCurrency(String text) {
    if (text.trim().isEmpty) return 0.0;
    final cleaned = text.replaceAll('.', '').replaceAll(',', '.').trim();
    return double.tryParse(cleaned) ?? 0.0;
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final salary = _parseCurrency(_salaryController.text);
    final additionals = _parseCurrency(_additionalsController.text);
    final fgts = _parseCurrency(_fgtsBalanceController.text);
    final deductions = _parseCurrency(_customDeductionsController.text);

    if (_dismissalDate.isBefore(_admissionDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A data de demissão não pode ser anterior à data de admissão.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final input = CltInput(
      baseSalary: salary,
      additionalEarnings: additionals,
      admissionDate: _admissionDate,
      dismissalDate: _dismissalDate,
      terminationType: _terminationType,
      noticeType: _noticeType,
      overdueVacationPeriods: _overdueVacationsCount,
      dependentsCount: _dependentsCount,
      fgtsBalance: fgts,
      customDeductions: deductions,
      unemploymentRequestsCount: _unemploymentRequestsCount,
    );

    final result = CltCalculatorService.calculate(input);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ResultScreen(input: input, result: result),
      ),
    );
  }

  Future<void> _selectDate({required bool isAdmission}) async {
    final initialDate = isAdmission ? _admissionDate : _dismissalDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1980),
      lastDate: DateTime(2035),
      locale: const Locale('pt', 'BR'),
    );

    if (picked != null) {
      setState(() {
        if (isAdmission) {
          _admissionDate = picked;
        } else {
          _dismissalDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.calculate_outlined, color: Color(0xFF1E3A8A)),
            SizedBox(width: 8),
            Text(
              'CalculaCLT',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Banner de Destaque
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.security, color: Color(0xFF2563EB), size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Cálculo 100% atualizado com as regras da CLT, Lei 12.506/11 e tabelas vigentes.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1E40AF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Seção 1: Salário e Remuneração
                _buildCardContainer(
                  title: '1. Remuneração Mensal',
                  icon: Icons.payments_outlined,
                  children: [
                    TextFormField(
                      controller: _salaryController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Salário Base Bruto (R\$)',
                        hintText: 'Ex: 3.500,00',
                        prefixText: 'R\$ ',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty)
                          return 'Informe o salário base.';
                        if (_parseCurrency(val) <= 0)
                          return 'O salário deve ser maior que zero.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _additionalsController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Média de Horas Extras / Adicionais (R\$) [Opcional]',
                        hintText: '0,00',
                        prefixText: 'R\$ ',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Seção 2: Datas do Contrato
                _buildCardContainer(
                  title: '2. Período Trabalhado',
                  icon: Icons.calendar_month_outlined,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(isAdmission: true),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Data Admissão',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _dateFormat.format(_admissionDate),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(isAdmission: false),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Data Afastamento',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _dateFormat.format(_dismissalDate),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Seção 3: Tipo de Rescisão e Aviso Prévio
                _buildCardContainer(
                  title: '3. Motivo da Saída e Aviso',
                  icon: Icons.work_history_outlined,
                  children: [
                    DropdownButtonFormField<TerminationType>(
                      value: _terminationType,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Rescisão',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      items: TerminationType.values
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(
                                type.label,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _terminationType = val;
                            if (val == TerminationType.pedidoDemissao) {
                              _noticeType = NoticeType.trabalhado;
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _terminationType.description,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<NoticeType>(
                      value: _noticeType,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Aviso Prévio',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      items: NoticeType.values
                          .map(
                            (notice) => DropdownMenuItem(
                              value: notice,
                              child: Text(
                                notice.label,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _noticeType = val);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Seção 4: Férias Vencidas e Dependentes
                _buildCardContainer(
                  title: '4. Férias Vencidas & Dependentes',
                  icon: Icons.beach_access_outlined,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Períodos de Férias Vencidas:',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF334155),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: _overdueVacationsCount > 0
                                  ? () =>
                                        setState(() => _overdueVacationsCount--)
                                  : null,
                            ),
                            Text(
                              '$_overdueVacationsCount',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () =>
                                  setState(() => _overdueVacationsCount++),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Dependentes (Dedução IRRF):',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF334155),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: _dependentsCount > 0
                                  ? () => setState(() => _dependentsCount--)
                                  : null,
                            ),
                            Text(
                              '$_dependentsCount',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () =>
                                  setState(() => _dependentsCount++),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Seção 5: FGTS e Outros Descontos
                _buildCardContainer(
                  title: '5. Saldo FGTS & Descontos (Opcional)',
                  icon: Icons.savings_outlined,
                  children: [
                    TextFormField(
                      controller: _fgtsBalanceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Saldo Atual do FGTS (R\$)',
                        hintText: 'Se vazio, estimaremos pelo tempo',
                        prefixText: 'R\$ ',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _customDeductionsController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Outros Descontos / Faltas / Vales (R\$)',
                        hintText: '0,00',
                        prefixText: 'R\$ ',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Botão Principal de Ação
                ElevatedButton.icon(
                  onPressed: _calculate,
                  icon: const Icon(Icons.calculate, size: 22),
                  label: const Text(
                    'CALCULAR RESCISÃO COMPLETA',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 3,
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContainer({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF1E3A8A), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

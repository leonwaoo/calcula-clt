import 'package:calcula_clt/clt_calculator.dart';
import 'package:calcula_clt/pro_purchase_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() => runApp(const CalculaCltApp());

class CalculaCltApp extends StatelessWidget {
  const CalculaCltApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Calcula CLT',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF075E54)),
      scaffoldBackgroundColor: const Color(0xFFF7F8F7),
      useMaterial3: true,
    ),
    home: const CalculatorPage(),
  );
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});
  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final _salary = TextEditingController();
  final _months = TextEditingController(text: '12');
  final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final _purchase = ProPurchaseService();
  CltResult? _result;
  bool _noticePaid = true;

  @override
  void initState() {
    super.initState();
    _purchase.initialize();
  }

  @override
  void dispose() {
    _salary.dispose();
    _months.dispose();
    _purchase.dispose();
    super.dispose();
  }

  void _simulate() {
    final salary = double.tryParse(
      _salary.text.replaceAll('.', '').replaceAll(',', '.'),
    );
    final months = int.tryParse(_months.text);
    if (salary == null || salary <= 0 || months == null || months < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe um salário e os meses trabalhados.'),
        ),
      );
      return;
    }
    setState(
      () => _result = const CltCalculator().simulate(
        CltSimulation(
          salary: salary,
          monthsWorked: months,
          noticePaid: _noticePaid,
        ),
      ),
    );
  }

  void _showProAccess() => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _ProSheet(purchase: _purchase),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'Calcula CLT',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Simule sua rescisão',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text('Faça uma estimativa inicial das verbas trabalhistas.'),
          const SizedBox(height: 24),
          _Section(
            title: 'Dados do contrato',
            child: Column(
              children: [
                TextField(
                  controller: _salary,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Último salário mensal',
                    prefixText: 'R\$ ',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _months,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Meses trabalhados no ano',
                  ),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Aviso-prévio indenizado'),
                  value: _noticePaid,
                  onChanged: (value) => setState(() => _noticePaid = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: _simulate,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
            ),
            child: const Text('Calcular rescisão'),
          ),
          if (_result != null) ...[
            const SizedBox(height: 26),
            _ResultCard(result: _result!, currency: _currency),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _showProAccess,
              icon: const Icon(Icons.workspace_premium_outlined),
              label: const Text('Desbloquear análise e relatório PDF'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
          const SizedBox(height: 20),
          const Text(
            'A simulação é informativa e não substitui a conferência de documentos ou orientação profissional.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    ),
  );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    ),
  );
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result, required this.currency});
  final CltResult result;
  final NumberFormat currency;
  @override
  Widget build(BuildContext context) => _Section(
    title: 'Estimativa da rescisão',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          currency.format(result.total),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Color(0xFF075E54),
          ),
        ),
        const SizedBox(height: 12),
        _line('Saldo de salário', result.salaryBalance),
        _line('Aviso-prévio', result.notice),
        _line(
          'Férias proporcionais + 1/3',
          result.proportionalVacation + result.vacationBonus,
        ),
        _line('13º proporcional', result.proportionalThirteenth),
      ],
    ),
  );
  Widget _line(String label, double value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label), Text(currency.format(value))],
    ),
  );
}

class _ProSheet extends StatelessWidget {
  const _ProSheet({required this.purchase});
  final ProPurchaseService purchase;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recursos profissionais',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'A análise detalhada e o relatório em PDF são liberados somente após a confirmação da compra pela Google Play.',
          ),
          const SizedBox(height: 20),
          ValueListenableBuilder<ProPurchaseState>(
            valueListenable: purchase.state,
            builder: (context, state, _) {
              final ready = state == ProPurchaseState.ready;
              final buying = state == ProPurchaseState.purchasing;
              final active = state == ProPurchaseState.active;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    onPressed: ready ? purchase.buy : null,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: Text(
                      buying
                          ? 'Confirmando compra...'
                          : active
                          ? 'Acesso confirmado'
                          : 'Comprar na Google Play',
                    ),
                  ),
                  if (state == ProPurchaseState.unavailable)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        'As compras ainda não estão disponíveis. Configure o produto e o servidor de validação antes de publicar.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  if (state == ProPurchaseState.failed)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        'Não foi possível confirmar a compra. O acesso continua bloqueado.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    ),
  );
}

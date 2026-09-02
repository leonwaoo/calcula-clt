import 'package:calcula_clt/clt_calculator.dart';
import 'package:calcula_clt/pro_purchase_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const _ink = Color(0xFF17251F);
const _forest = Color(0xFF075E54);
const _mint = Color(0xFFE9F5F0);
const _paper = Color(0xFFF6F7F4);

void main() => runApp(const CalculaCltApp());

class CalculaCltApp extends StatelessWidget {
  const CalculaCltApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Calcula CLT',
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: _paper,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _forest,
        brightness: Brightness.light,
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAF8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD6DED9)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD6DED9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _forest, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
      ),
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
  final _days = TextEditingController(text: '30');
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
    _days.dispose();
    _purchase.dispose();
    super.dispose();
  }

  void _simulate() {
    final salary = double.tryParse(
      _salary.text.replaceAll('.', '').replaceAll(',', '.'),
    );
    final months = int.tryParse(_months.text);
    final days = int.tryParse(_days.text);
    if (salary == null ||
        salary <= 0 ||
        months == null ||
        months < 0 ||
        days == null ||
        days < 0 ||
        days > 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Revise salário, meses e dias trabalhados.'),
        ),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    setState(
      () => _result = const CltCalculator().simulate(
        CltSimulation(
          salary: salary,
          monthsWorked: months,
          daysWorked: days,
          noticePaid: _noticePaid,
        ),
      ),
    );
  }

  void _showLegalInfo() => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => const _LegalSheet(),
  );

  void _showProAccess() => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => _ProSheet(purchase: _purchase),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _Hero(onLegalTap: _showLegalInfo)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const _SectionHeading(
                number: '01',
                title: 'Dados da rescisão',
                caption: 'Use os dados do último mês de trabalho.',
              ),
              const SizedBox(height: 12),
              _FormCard(
                salary: _salary,
                months: _months,
                days: _days,
                noticePaid: _noticePaid,
                onNoticeChanged: (value) => setState(() => _noticePaid = value),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: _simulate,
                style: FilledButton.styleFrom(
                  backgroundColor: _forest,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Calcular estimativa',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
              const SizedBox(height: 12),
              const _MethodNote(),
              if (_result != null) ...[
                const SizedBox(height: 32),
                const _SectionHeading(
                  number: '02',
                  title: 'Sua estimativa',
                  caption:
                      'Valores brutos antes de descontos e particularidades.',
                ),
                const SizedBox(height: 12),
                _ResultCard(result: _result!, currency: _currency),
                const SizedBox(height: 18),
                _ProCard(onTap: _showProAccess),
                const SizedBox(height: 20),
                _LegalChecklist(onTap: _showLegalInfo),
              ],
            ]),
          ),
        ),
      ],
    ),
  );
}

class _Hero extends StatelessWidget {
  const _Hero({required this.onLegalTap});
  final VoidCallback onLegalTap;

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [_forest, Color(0xFF0D7A69)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
    ),
    child: SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calculate_outlined,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'CALCULA CLT',
                  style: TextStyle(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onLegalTap,
                  icon: const Icon(Icons.info_outline),
                  tooltip: 'Como calculamos',
                ),
              ],
            ),
            const SizedBox(height: 27),
            const Text(
              'Entenda sua\nrescisão com clareza.',
              style: TextStyle(
                fontSize: 31,
                height: 1.08,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 11),
            const Text(
              'Uma estimativa inicial, organizada por verba e feita para você conferir os próximos passos.',
              style: TextStyle(
                fontSize: 15,
                height: 1.45,
                color: Color(0xFFE5F7F0),
              ),
            ),
            const SizedBox(height: 22),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _HeroChip(
                  icon: Icons.lock_outline,
                  label: 'Dados somente no aparelho',
                ),
                _HeroChip(icon: Icons.description_outlined, label: 'Base CLT'),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .13),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white.withValues(alpha: .18)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: Colors.white),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.number,
    required this.title,
    required this.caption,
  });
  final String number;
  final String title;
  final String caption;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _mint,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          number,
          style: const TextStyle(
            color: _forest,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: _ink,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              caption,
              style: const TextStyle(fontSize: 13, color: Color(0xFF647069)),
            ),
          ],
        ),
      ),
    ],
  );
}

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.salary,
    required this.months,
    required this.days,
    required this.noticePaid,
    required this.onNoticeChanged,
  });
  final TextEditingController salary;
  final TextEditingController months;
  final TextEditingController days;
  final bool noticePaid;
  final ValueChanged<bool> onNoticeChanged;
  @override
  Widget build(BuildContext context) => _SurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel(
          icon: Icons.payments_outlined,
          label: 'Último salário mensal',
        ),
        const SizedBox(height: 8),
        TextField(
          controller: salary,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            prefixText: 'R\$ ',
            hintText: 'Ex.: 2.500,00',
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FieldLabel(
                    icon: Icons.calendar_month_outlined,
                    label: 'Meses no ano',
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: months,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: '12'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FieldLabel(
                    icon: Icons.today_outlined,
                    label: 'Dias no mês',
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: days,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: '30'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F8F6),
            borderRadius: BorderRadius.circular(14),
          ),
          child: SwitchListTile.adaptive(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 4,
            ),
            title: const Text(
              'Aviso-prévio indenizado',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            subtitle: const Text(
              'Inclui uma remuneração no cálculo',
              style: TextStyle(fontSize: 12),
            ),
            value: noticePaid,
            activeTrackColor: const Color(0xFF92CBBE),
            onChanged: onNoticeChanged,
          ),
        ),
      ],
    ),
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 16, color: _forest),
      const SizedBox(width: 7),
      Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          color: _ink,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _MethodNote extends StatelessWidget {
  const _MethodNote();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF7E7),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFF0DEB8)),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.lightbulb_outline, color: Color(0xFF9A680B), size: 20),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Informe apenas o que você souber. O resultado é uma estimativa bruta e será detalhado por verba.',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.35,
              color: Color(0xFF664B14),
            ),
          ),
        ),
      ],
    ),
  );
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result, required this.currency});
  final CltResult result;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) => _SurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TOTAL ESTIMADO',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
            fontSize: 11,
            color: Color(0xFF607067),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          currency.format(result.total),
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: _forest,
            fontSize: 34,
          ),
        ),
        const SizedBox(height: 3),
        const Text(
          'Sem considerar descontos legais e particularidades do contrato.',
          style: TextStyle(fontSize: 12, color: Color(0xFF647069)),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 18),
          child: Divider(height: 1),
        ),
        _line(
          'Saldo de salário',
          result.salaryBalance,
          Icons.account_balance_wallet_outlined,
        ),
        _line('Aviso-prévio', result.notice, Icons.schedule_outlined),
        _line(
          'Férias proporcionais + 1/3',
          result.proportionalVacation + result.vacationBonus,
          Icons.beach_access_outlined,
        ),
        _line(
          '13º proporcional',
          result.proportionalThirteenth,
          Icons.card_giftcard_outlined,
        ),
      ],
    ),
  );

  Widget _line(String label, double value, IconData icon) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: _mint,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 18, color: _forest),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: _ink,
            ),
          ),
        ),
        Text(
          currency.format(value),
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: _ink,
          ),
        ),
      ],
    ),
  );
}

class _ProCard extends StatelessWidget {
  const _ProCard({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(20),
    onTap: onTap,
    child: Ink(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF172D29), Color(0xFF075E54)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.workspace_premium_outlined,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Análise completa e PDF',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Confira cenários, pontos de atenção e gere um relatório organizado.',
                  style: TextStyle(
                    color: Color(0xFFD6EEE7),
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 13),
                Text(
                  'VER RECURSOS PROFISSIONAIS',
                  style: TextStyle(
                    color: Color(0xFF9DE1CF),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .7,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: Colors.white,
          ),
        ],
      ),
    ),
  );
}

class _LegalChecklist extends StatelessWidget {
  const _LegalChecklist({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => _SurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.gavel_outlined, color: _forest),
            const SizedBox(width: 9),
            const Expanded(
              child: Text(
                'Antes de considerar o valor final',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: _ink,
                ),
              ),
            ),
            TextButton(onPressed: onTap, child: const Text('Saiba mais')),
          ],
        ),
        const SizedBox(height: 7),
        const _Check(
          text: 'FGTS, multa rescisória e seguro-desemprego seguem regras próprias.',
        ),
        const _Check(
          text: 'Faltas, adicionais, comissões e acordo coletivo podem alterar o cálculo.',
        ),
        const _Check(
          text: 'Descontos de INSS, IRRF e outros valores não estão incluídos nesta estimativa.',
        ),
      ],
    ),
  );
}

class _Check extends StatelessWidget {
  const _Check({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_outline, size: 18, color: _forest),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.35,
              color: Color(0xFF4C5B53),
            ),
          ),
        ),
      ],
    ),
  );
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE1E7E2)),
    ),
    child: child,
  );
}

class _LegalSheet extends StatelessWidget {
  const _LegalSheet();
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Como esta estimativa funciona',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: _ink,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'O cálculo apresenta uma referência para rescisão sem justa causa, usando salário mensal, dias trabalhados, meses no ano e aviso-prévio indenizado.',
          ),
          const SizedBox(height: 14),
          const _Check(
            text: 'Saldo de salário: remuneração proporcional aos dias trabalhados no mês.',
          ),
          const _Check(
            text: 'Férias proporcionais: 1/12 por mês considerado, acrescidas de 1/3 constitucional.',
          ),
          const _Check(
            text: '13º proporcional: 1/12 do salário por mês considerado.',
          ),
          const SizedBox(height: 16),
          const Text(
            'O resultado não substitui holerites, TRCT, convenção coletiva ou orientação profissional. Situações como pedido de demissão, justa causa, contrato de experiência, férias vencidas e adicionais exigem conferência específica.',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: Color(0xFF4C5B53),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ProSheet extends StatelessWidget {
  const _ProSheet({required this.purchase});
  final ProPurchaseService purchase;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _mint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.workspace_premium_outlined, color: _forest),
          ),
          const SizedBox(height: 16),
          const Text(
            'Recursos profissionais',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _ink,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Gere o relatório em PDF e consulte uma análise mais detalhada da sua simulação. O acesso é liberado somente após a validação da compra pela Google Play.',
            style: TextStyle(height: 1.4),
          ),
          const SizedBox(height: 18),
          const _Check(text: 'Compra única vinculada à sua conta Google.'),
          const _Check(text: 'Validação de compra antes de liberar o acesso.'),
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
                      backgroundColor: _forest,
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
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
                      padding: EdgeInsets.only(top: 11),
                      child: Text(
                        'As compras serão ativadas após a configuração do produto no Google Play Console e do servidor de validação.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF647069),
                        ),
                      ),
                    ),
                  if (state == ProPurchaseState.failed)
                    const Padding(
                      padding: EdgeInsets.only(top: 11),
                      child: Text(
                        'A compra não foi confirmada. O acesso continua bloqueado para sua segurança.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9A2518),
                        ),
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

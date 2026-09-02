import 'package:flutter/material.dart';

import '../services/pro_access_service.dart';

class PaywallModal extends StatelessWidget {
  const PaywallModal({super.key, required this.proAccess});

  final ProAccessService proAccess;

  static Future<void> show(BuildContext context, ProAccessService proAccess) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaywallModal(proAccess: proAccess),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: StreamBuilder<ProAccessStatus>(
          stream: proAccess.status,
          initialData: proAccess.isPro
              ? ProAccessStatus.pro
              : ProAccessStatus.free,
          builder: (context, snapshot) {
            final status = snapshot.data ?? ProAccessStatus.free;
            final loading = status == ProAccessStatus.loading;
            final unavailable =
                status == ProAccessStatus.unavailable ||
                status == ProAccessStatus.error;
            final price =
                proAccess.product?.price ?? 'Preço exibido pela Google Play';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    height: 4,
                    width: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Image.asset(
                      'assets/branding/calculaclt-logo.png',
                      width: 46,
                      height: 46,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CalculaCLT Pro',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF172554),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Acesso vitalício pelo Google Play',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Entenda sua rescisão com segurança.',
                  style: TextStyle(
                    fontSize: 24,
                    height: 1.12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Desbloqueie a memória de cálculo e o documento pronto para compartilhar. O cálculo-resumo continua gratuito.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 20),
                const _Benefit(
                  icon: Icons.analytics_outlined,
                  title: 'Análise detalhada',
                  description: 'Rubricas, descontos e fundamentos legais em uma leitura simples.',
                ),
                const _Benefit(
                  icon: Icons.picture_as_pdf_outlined,
                  title: 'Relatório PDF profissional',
                  description: 'Exporte e compartilhe seu demonstrativo sem marca d’água.',
                ),
                const _Benefit(
                  icon: Icons.workspace_premium_outlined,
                  title: 'Compra única',
                  description: 'Sem assinatura: o acesso é vinculado à sua conta Google.',
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF172554),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lock_outline_rounded,
                        color: Color(0xFF6EE7B7),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Acesso vitalício',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              price,
                              style: const TextStyle(
                                color: Color(0xFFBBF7D0),
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        'Google Play',
                        style: TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: loading || unavailable || proAccess.isPro
                      ? null
                      : () => proAccess.buyLifetimeAccess(),
                  icon: Icon(loading ? Icons.sync : Icons.lock_open_rounded),
                  label: Text(
                    loading
                        ? 'VALIDANDO COMPRA...'
                        : proAccess.isPro
                        ? 'ACESSO PRO ATIVO'
                        : 'DESBLOQUEAR COM GOOGLE PLAY',
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                if (unavailable)
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      'A compra estará disponível somente após a publicação no Google Play e a validação da conta.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFFB45309), fontSize: 12),
                    ),
                  ),
                TextButton(
                  onPressed: loading ? null : proAccess.restorePurchases,
                  child: const Text('Restaurar compras'),
                ),
                const Text(
                  'O pagamento e a validação são feitos pela Google Play. Nenhum PIX ou dado de pagamento é processado pelo app.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.35,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({
    required this.icon,
    required this.title,
    required this.description,
  });
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: const Color(0xFFDBEAFE),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF1D4ED8), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.3,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

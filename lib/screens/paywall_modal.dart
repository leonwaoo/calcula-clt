import 'package:flutter/material.dart';

import '../services/pro_access_service.dart';

class PaywallModal extends StatelessWidget {
  final ProAccessService proAccess;

  const PaywallModal({super.key, required this.proAccess});

  static Future<void> show(BuildContext context, ProAccessService proAccess) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaywallModal(proAccess: proAccess),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Barra superior e fechar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'PRO',
                      style: TextStyle(
                        color: Color(0xFFB45309),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Título e Subtítulo
              Text(
                'Desbloqueie o Relatório Oficial em PDF',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tenha em mãos o demonstrativo detalhado para conferir cada centavo da sua rescisão e contestar irregularidades no RH.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Lista de Benefícios
              _buildFeature(
                icon: Icons.picture_as_pdf_rounded,
                title: 'PDF Formal com Base Legal',
                subtitle: 'Citação dos artigos da CLT e da Lei 12.506/11 para cada verba calculada.',
              ),
              _buildFeature(
                icon: Icons.send_rounded,
                title: 'Envio Direto no WhatsApp',
                subtitle: 'Compartilhe o documento em 1 clique com seu advogado ou família.',
              ),
              _buildFeature(
                icon: Icons.verified_user_rounded,
                title: 'Sem Marcas d\'Água',
                subtitle: 'Documento limpo, executivo e pronto para ser impresso ou assinado.',
              ),
              _buildFeature(
                icon: Icons.history_rounded,
                title: 'Histórico Ilimitado',
                subtitle: 'Salve e compare quantas simulações quiser offline.',
              ),

              const SizedBox(height: 24),

              // Card do Plano Vitalício (Destaque ASO)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
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
                          'Acesso Vitalício',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Pague 1x, Use para Sempre',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'R\$ 19,90',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'pagamento único',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Sem mensalidades ou cobranças surpresa.',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Botão de Ação CTA
              StreamBuilder<ProAccessStatus>(
                stream: proAccess.status,
                initialData: proAccess.isPro
                    ? ProAccessStatus.pro
                    : ProAccessStatus.free,
                builder: (context, snapshot) {
                  final status = snapshot.data ?? ProAccessStatus.free;
                  final loading = status == ProAccessStatus.loading;
                  return ElevatedButton(
                    onPressed: loading || proAccess.isPro
                        ? null
                        : () async {
                            final started = await proAccess.buyLifetimeAccess();
                            if (!started && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Produto indisponível. Confira a configuração no Google Play Console.',
                                  ),
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      loading
                          ? 'VALIDANDO COMPRA...'
                          : proAccess.isPro
                          ? 'VERSÃO PRO ATIVA'
                          : 'COMPRAR ACESSO VITALÍCIO',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Botão Restaurar Compras
              Center(
                child: TextButton(
                  onPressed: proAccess.restorePurchases,
                  child: const Text(
                    'Já comprou? Restaurar Compras',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF2563EB), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
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
    );
  }
}

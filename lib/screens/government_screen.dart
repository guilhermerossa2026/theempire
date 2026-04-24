import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../utils/formatters.dart';

/// Tela do Governo — sistema fiscal e upgrades contábeis
class GovernmentScreen extends StatelessWidget {
  const GovernmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: const [
        _FiscalStatusCard(),
        SizedBox(height: 20),
        _SectionTitle('CONTABILIDADE & JURÍDICO'),
        SizedBox(height: 12),
        _UpgradeCard(
          id: 'junior_accountant',
          title: 'Contador Júnior',
          description: 'Reduz impostos em 10%',
          cost: 5000,
          icon: Icons.account_balance_wallet_rounded,
          color: Color(0xFF1565C0),
        ),
        SizedBox(height: 12),
        _UpgradeCard(
          id: 'law_firm',
          title: 'Escritório de Advocacia',
          description: 'Reduz multas em 50%',
          cost: 50000,
          icon: Icons.gavel_rounded,
          color: Color(0xFF4A148C),
        ),
        SizedBox(height: 12),
        _UpgradeCard(
          id: 'intl_consulting',
          title: 'Consultoria Internacional',
          description: 'Reduz impostos em 30%',
          cost: 500000,
          icon: Icons.public_rounded,
          color: Color(0xFF00695C),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.black45,
        fontWeight: FontWeight.w900,
        fontSize: 11,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _FiscalStatusCard extends StatelessWidget {
  const _FiscalStatusCard();

  @override
  Widget build(BuildContext context) {
    return Selector<GameProvider, (int, double, double, double)>(
      selector: (_, g) => (
        g.taxCountdown,
        g.monthlyGrossProfit,
        g.totalTaxesPaid,
        g.balance,
      ),
      builder: (context, data, _) {
        final (countdown, gross, paid, balance) = data;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F4F8),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFD0D5DD),
                blurRadius: 12,
                offset: Offset(8, 8),
              ),
              BoxShadow(
                color: Colors.white,
                blurRadius: 12,
                offset: Offset(-8, -8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8A2BE2).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.account_balance_rounded,
                      color: Color(0xFF8A2BE2),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RECEITA FEDERAL',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'Ciclo Fiscal Ativo',
                          style: TextStyle(color: Colors.black38, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '${countdown}s',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF8A2BE2),
                        ),
                      ),
                      const Text(
                        'PRÓXIMA',
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.black38,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1, color: Color(0xFFE0E0E0)),
              ),
              _InfoRow(
                label: 'Lucro Bruto (Ciclo)',
                value: formatMoney(gross),
                valueColor: Colors.black87,
              ),
              const SizedBox(height: 8),
              _InfoRow(
                label: 'Saldo Atual',
                value: formatMoney(balance),
                valueColor: Colors.black87,
              ),
              const SizedBox(height: 8),
              _InfoRow(
                label: 'Total Pago ao Governo',
                value: formatMoney(paid),
                valueColor: Colors.red[700]!,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.black45, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _UpgradeCard extends StatelessWidget {
  final String id;
  final String title;
  final String description;
  final double cost;
  final IconData icon;
  final Color color;

  const _UpgradeCard({
    required this.id,
    required this.title,
    required this.description,
    required this.cost,
    required this.icon,
    required this.color,
  });

  bool _isBought(GameProvider g) {
    switch (id) {
      case 'junior_accountant':
        return g.hasJuniorAccountant;
      case 'law_firm':
        return g.hasLawFirm;
      case 'intl_consulting':
        return g.hasIntlConsulting;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<GameProvider, (double, bool)>(
      selector: (_, g) => (g.balance, _isBought(g)),
      builder: (context, data, _) {
        final (balance, bought) = data;
        final canAfford = balance >= cost;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F4F8),
            borderRadius: BorderRadius.circular(20),
            border: bought
                ? Border.all(
                    color: const Color(0xFF39FF14).withValues(alpha: 0.4))
                : null,
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFD0D5DD),
                blurRadius: 10,
                offset: Offset(6, 6),
              ),
              BoxShadow(
                color: Colors.white,
                blurRadius: 10,
                offset: Offset(-6, -6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: bought
                      ? const Color(0xFF39FF14).withValues(alpha: 0.15)
                      : color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: bought ? const Color(0xFF39FF14) : color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.black45,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: bought || !canAfford
                    ? null
                    : () {
                        HapticFeedback.mediumImpact();
                        context.read<GameProvider>().buyFiscalUpgrade(id, cost);
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: bought
                        ? null
                        : canAfford
                            ? const LinearGradient(
                                colors: [
                                  Color(0xFFFFD700),
                                  Color(0xFFF9A825)
                                ],
                              )
                            : null,
                    color: bought
                        ? const Color(0xFF39FF14).withValues(alpha: 0.15)
                        : canAfford
                            ? null
                            : const Color(0xFFE8E8E8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    bought ? 'ATIVO ✓' : formatMoney(cost),
                    style: TextStyle(
                      color: bought
                          ? const Color(0xFF2DBF04)
                          : canAfford
                              ? Colors.black87
                              : Colors.black38,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

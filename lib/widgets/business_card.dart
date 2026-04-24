import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/business.dart';
import '../providers/game_provider.dart';
import '../utils/formatters.dart';

/// Card neumórfico premium para exibição e upgrade de negócios
class BusinessCard extends StatelessWidget {
  final Business business;

  const BusinessCard({super.key, required this.business});

  // Cor de gradiente baseada no nível do negócio
  List<Color> _getGradient() {
    if (business.level == 0) {
      return [const Color(0xFF3A3A3A), const Color(0xFF1A1A1A)];
    }
    if (business.level < 5) {
      return [const Color(0xFF4B0082), const Color(0xFF1A0033)];
    }
    if (business.level < 10) {
      return [const Color(0xFF8A2BE2), const Color(0xFF4B0082)];
    }
    return [const Color(0xFFFFD700), const Color(0xFFF57F17)];
  }

  // Ícone de status do negócio
  Widget _buildStatusBadge() {
    if (business.isBroken && !business.hasManager) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.red[700],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.build_rounded, color: Colors.white, size: 10),
            SizedBox(width: 3),
            Text(
              'QUEBRADO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
    if (business.hasManager) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFF39FF14).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: const Color(0xFF39FF14).withValues(alpha: 0.5)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_rounded,
                color: Color(0xFF39FF14), size: 10),
            SizedBox(width: 3),
            Text(
              'GERENTE',
              style: TextStyle(
                color: Color(0xFF39FF14),
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final game = context.read<GameProvider>();

    return Selector<GameProvider, double>(
      selector: (_, g) => g.balance,
      builder: (context, balance, _) {
        final bool canAfford = balance >= business.upgradeCost;
        final gradientColors = _getGradient();

        return Container(
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              children: [
                // ── Área do Ícone ────────────────────────────────
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Círculo decorativo de fundo
                      Positioned(
                        top: -20,
                        right: -20,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                      ),
                      // Emoji do negócio
                      Center(
                        child: Text(
                          business.icon,
                          style: const TextStyle(fontSize: 52),
                        ),
                      ),
                      // Badge de nível
                      if (business.level > 0)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'NV ${business.level}',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      // Badge de status
                      Positioned(
                        top: 8,
                        right: 8,
                        child: _buildStatusBadge(),
                      ),
                    ],
                  ),
                ),

                // ── Informações ──────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          business.name,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        // Lucro por segundo
                        Row(
                          children: [
                            const Icon(
                              Icons.bolt,
                              color: Color(0xFF39FF14),
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              business.level > 0
                                  ? '${formatMoney(business.currentProfit)}/s'
                                  : 'Inativo',
                              style: TextStyle(
                                color: business.level > 0
                                    ? const Color(0xFF2DBF04)
                                    : Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // ── Exibição de Custo ─────────────────────────
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            business.isBroken && !business.hasManager
                                ? 'Custo de Reparo: ${formatMoney(business.upgradeCost * 0.5)}'
                                : business.level == 0
                                    ? 'Custo de Abertura: ${formatMoney(business.initialCost)}'
                                    : 'Custo Upgrade: ${formatMoney(business.upgradeCost)}',
                            style: TextStyle(
                              color: Colors.black45,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),

                        // ── Botão de Ação ────────────────────────────
                        if (business.isBroken && !business.hasManager)
                          _RepairButton(business: business)
                        else
                          _UpgradeButton(
                            business: business,
                            canAfford: canAfford,
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              game.upgradeBusiness(business);
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _UpgradeButton extends StatelessWidget {
  final Business business;
  final bool canAfford;
  final VoidCallback onTap;

  const _UpgradeButton({
    required this.business,
    required this.canAfford,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: canAfford ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 38,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: canAfford
              ? const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFF9A825)],
                )
              : null,
          color: canAfford ? null : const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(12),
          boxShadow: canAfford
              ? [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            business.level == 0 ? 'ABRIR NEGÓCIO' : 'UPGRADE NÍVEL',
            style: TextStyle(
              color: canAfford ? Colors.black87 : Colors.black38,
              fontWeight: FontWeight.w900,
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _RepairButton extends StatelessWidget {
  final Business business;

  const _RepairButton({required this.business});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.read<GameProvider>().repairBusiness(business);
      },
      child: Container(
        height: 38,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red[400]!, Colors.red[700]!],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.build_rounded, color: Colors.white, size: 13),
            SizedBox(width: 4),
            Text(
              'REPARAR AGORA',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

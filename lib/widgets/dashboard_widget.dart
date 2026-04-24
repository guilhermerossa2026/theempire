import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../utils/formatters.dart';

/// Widget do painel principal: saldo, renda/s e botão de clique neumórfico
class DashboardWidget extends StatefulWidget {
  const DashboardWidget({super.key});

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onTapDown(_) => setState(() => _isPressed = true);
  void _onTapUp(_) => setState(() => _isPressed = false);

  @override
  Widget build(BuildContext context) {
    // Usando Selector para rebuildar apenas quando balance ou debt mudam
    return Selector<GameProvider, (double, double, double, int)>(
      selector: (_, g) =>
          (g.balance, g.debt, g.totalIncomePerSecond, g.taxCountdown),
      builder: (context, data, _) {
        final (balance, debt, income, countdown) = data;
        final bool hasDebt = debt > 0;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F4F8),
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFD0D5DD),
                blurRadius: 15,
                offset: Offset(8, 8),
              ),
              BoxShadow(
                color: Colors.white,
                blurRadius: 15,
                offset: Offset(-8, -8),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'EMPIRE TYCOON',
                        style: TextStyle(
                          color: Color(0xFF8A2BE2),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasDebt ? 'EM DÍVIDA' : 'EMPRESÁRIO',
                        style: TextStyle(
                          color: hasDebt
                              ? Colors.red[700]
                              : Colors.black54,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  // Contador Fiscal
                  _FiscalCountdown(countdown: countdown),
                ],
              ),

              const SizedBox(height: 16),

              // ── Saldo Principal ──────────────────────────────
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: hasDebt ? Colors.red[700]! : Colors.black87,
                  fontFamily: 'Roboto',
                ),
                child: Text(
                  hasDebt ? '-${formatMoney(debt)}' : formatMoney(balance),
                ),
              ),

              const SizedBox(height: 8),

              // ── Renda por segundo ────────────────────────────
              if (income > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF39FF14).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF39FF14).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.trending_up,
                        color: Color(0xFF2DBF04),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+ ${formatMoney(income)}/s',
                        style: const TextStyle(
                          color: Color(0xFF2DBF04),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // ── Botão de Clique Neumórfico ───────────────────
              GestureDetector(
                onTapDown: _onTapDown,
                onTapUp: _onTapUp,
                onTapCancel: () => setState(() => _isPressed = false),
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.read<GameProvider>().clickToEarn();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF1F4F8),
                    boxShadow: _isPressed
                        ? [
                            const BoxShadow(
                              color: Color(0xFFD0D5DD),
                              blurRadius: 6,
                              offset: Offset(4, 4),
                            ),
                            const BoxShadow(
                              color: Colors.white,
                              blurRadius: 6,
                              offset: Offset(-4, -4),
                            ),
                          ]
                        : [
                            const BoxShadow(
                              color: Color(0xFFD0D5DD),
                              blurRadius: 15,
                              offset: Offset(10, 10),
                            ),
                            const BoxShadow(
                              color: Colors.white,
                              blurRadius: 15,
                              offset: Offset(-10, -10),
                            ),
                          ],
                  ),
                  child: Center(
                    child: ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF9D50BB),
                              Color(0xFF4B0082),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8A2BE2)
                                  .withValues(alpha: 0.5),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.emoji_events_rounded,
                          color: Color(0xFFFFD700),
                          size: 38,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'TOQUE PARA GANHAR',
                style: TextStyle(
                  color: Colors.black38,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Indicador visual do contador fiscal
class _FiscalCountdown extends StatelessWidget {
  final int countdown;

  const _FiscalCountdown({required this.countdown});

  @override
  Widget build(BuildContext context) {
    final bool isUrgent = countdown <= 15;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isUrgent
            ? Colors.red[50]
            : const Color(0xFF8A2BE2).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUrgent
              ? Colors.red[300]!
              : const Color(0xFF8A2BE2).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            '${countdown}s',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isUrgent ? Colors.red[700] : const Color(0xFF8A2BE2),
            ),
          ),
          Text(
            'IMPOSTO',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: isUrgent ? Colors.red[400] : Colors.black38,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/property.dart';
import '../providers/game_provider.dart';
import '../utils/formatters.dart';

/// Tela de Imóveis
class PropertyScreen extends StatelessWidget {
  const PropertyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final properties = context.read<GameProvider>().properties;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: properties.length,
      itemBuilder: (context, i) => _PropertyCard(property: properties[i]),
    );
  }
}

class _PropertyCard extends StatelessWidget {
  final Property property;

  const _PropertyCard({required this.property});

  List<Color> _getPropertyGradient() {
    switch (property.quantity) {
      case 0:
        return [const Color(0xFF37474F), const Color(0xFF263238)];
      default:
        return [const Color(0xFF1565C0), const Color(0xFF0D47A1)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<GameProvider, double>(
      selector: (_, g) => g.balance,
      builder: (context, balance, _) {
        final canAfford = balance >= property.cost;
        final gradient = _getPropertyGradient();

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Ícone com gradiente
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradient,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: gradient[0].withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      property.icon,
                      style: const TextStyle(fontSize: 34),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // Informações
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              property.name,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (property.quantity > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8A2BE2)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'x${property.quantity}',
                                style: const TextStyle(
                                  color: Color(0xFF8A2BE2),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.home_rounded,
                            color: Color(0xFF39FF14),
                            size: 13,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${formatMoney(property.rentIncome)}/s',
                            style: const TextStyle(
                              color: Color(0xFF2DBF04),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      if (property.quantity > 0)
                        Text(
                          'Total: ${formatMoney(property.totalIncome)}/s',
                          style: const TextStyle(
                            color: Colors.black38,
                            fontSize: 11,
                          ),
                        ),
                      const SizedBox(height: 10),
                      // Botão comprar
                      GestureDetector(
                        onTap: canAfford
                            ? () {
                                HapticFeedback.mediumImpact();
                                context
                                    .read<GameProvider>()
                                    .buyProperty(property);
                              }
                            : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: canAfford
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFFFFD700),
                                      Color(0xFFF9A825)
                                    ],
                                  )
                                : null,
                            color: canAfford ? null : const Color(0xFFE8E8E8),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: canAfford
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFFFFD700)
                                          .withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              formatMoney(property.cost),
                              style: TextStyle(
                                color: canAfford
                                    ? Colors.black87
                                    : Colors.black38,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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

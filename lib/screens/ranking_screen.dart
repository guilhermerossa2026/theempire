import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../utils/formatters.dart';

/// Tela de Ranking — leaderboard dos bilionários
class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  Color _getMedalColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFFFFD700);
      case 1:
        return const Color(0xFFB0BEC5);
      case 2:
        return const Color(0xFFBF8970);
      default:
        return const Color(0xFF8A2BE2);
    }
  }

  IconData _getMedalIcon(int index) {
    switch (index) {
      case 0:
        return Icons.emoji_events_rounded;
      case 1:
        return Icons.military_tech_rounded;
      case 2:
        return Icons.military_tech_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<GameProvider, double>(
      selector: (_, g) => g.balance,
      builder: (context, balance, _) {
        final ranking = context.read<GameProvider>().getRanking();

        return Column(
          children: [
            // Header do Ranking
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: const Column(
                children: [
                  Text(
                    '🏆 RANKING GLOBAL',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    'Bilionários do Mundo',
                    style: TextStyle(color: Colors.black45, fontSize: 12),
                  ),
                ],
              ),
            ),

            // Lista do ranking
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                itemCount: ranking.length,
                itemBuilder: (context, index) {
                  final entry = ranking[index];
                  final isMe = entry['isMe'] as bool;
                  final medalColor = _getMedalColor(index);

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isMe
                          ? const Color(0xFF8A2BE2).withValues(alpha: 0.08)
                          : const Color(0xFFF1F4F8),
                      borderRadius: BorderRadius.circular(18),
                      border: isMe
                          ? Border.all(
                              color: const Color(0xFF8A2BE2)
                                  .withValues(alpha: 0.3),
                            )
                          : null,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFFD0D5DD),
                          blurRadius: 8,
                          offset: Offset(5, 5),
                        ),
                        BoxShadow(
                          color: Colors.white,
                          blurRadius: 8,
                          offset: Offset(-5, -5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Posição
                        SizedBox(
                          width: 32,
                          child: index < 3
                              ? Icon(
                                  _getMedalIcon(index),
                                  color: medalColor,
                                  size: 24,
                                )
                              : Text(
                                  '${index + 1}º',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: medalColor,
                                    fontSize: 14,
                                  ),
                                ),
                        ),

                        const SizedBox(width: 12),

                        // Avatar
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isMe
                                ? const Color(0xFF8A2BE2)
                                    .withValues(alpha: 0.15)
                                : Colors.black.withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              entry['avatar'] as String,
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Nome
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry['name'] as String,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isMe
                                      ? const Color(0xFF8A2BE2)
                                      : Colors.black87,
                                ),
                              ),
                              if (isMe)
                                const Text(
                                  'Você',
                                  style: TextStyle(
                                    color: Color(0xFF8A2BE2),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Patrimônio
                        Text(
                          formatMoney(entry['netWorth'] as double),
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            color:
                                isMe ? const Color(0xFF8A2BE2) : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'dart:math';

/// Modelo de Negócio do Jogo
class Business {
  final String name;
  final String icon;
  final double initialCost;
  final double baseProfit;
  final double riskProbability;

  int level;
  bool isBroken;
  bool isUnderCrise;
  bool hasManager;

  Business({
    required this.name,
    required this.icon,
    required this.initialCost,
    required this.baseProfit,
    required this.riskProbability,
    this.level = 0,
    this.isBroken = false,
    this.isUnderCrise = false,
    this.hasManager = false,
  });

  /// Custo para o próximo upgrade (cresce 50% por nível)
  double get upgradeCost => initialCost * pow(1.5, level);

  /// Custo para contratar gerente (25x o custo inicial)
  double get managerCost => initialCost * 25;

  /// Lucro atual por segundo
  double get currentProfit {
    if (level == 0) return 0;
    if (isUnderCrise || (isBroken && !hasManager)) return 0;
    return baseProfit * level * 1.2;
  }

  void upgrade() => level++;
  void repair() => isBroken = false;
  void hireManager() => hasManager = true;
}

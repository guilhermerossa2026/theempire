/// Modelo de Ativo Financeiro (Crypto / Ações)
class Asset {
  final String name;
  final String symbol;
  final double volatility;
  final bool isCrypto;

  double currentPrice;
  List<double> history;

  Asset({
    required this.name,
    required this.symbol,
    required this.currentPrice,
    required this.volatility,
    this.isCrypto = false,
  }) : history = [];

  /// Variação percentual em relação ao último preço registrado
  double get changePercentage {
    if (history.isEmpty) return 0;
    return ((currentPrice - history.last) / history.last) * 100;
  }

  bool get isPositive => changePercentage >= 0;
}

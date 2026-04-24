/// Modelo de Imóvel
class Property {
  final String name;
  final String icon;
  final double cost;
  final double rentIncome;

  int quantity;

  Property({
    required this.name,
    required this.icon,
    required this.cost,
    required this.rentIncome,
    this.quantity = 0,
  });

  /// Renda total por segundo (todos os imóveis deste tipo)
  double get totalIncome => quantity * rentIncome;
}

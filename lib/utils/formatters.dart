/// Formata valores monetários grandes com sufixos (K, M, B, T)
String formatMoney(double value) {
  final bool isNegative = value < 0;
  final double absValue = value.abs();
  String formatted;

  if (absValue < 1000) {
    formatted = absValue.toStringAsFixed(2);
  } else if (absValue < 1000000) {
    formatted = '${(absValue / 1000).toStringAsFixed(2)}K';
  } else if (absValue < 1000000000) {
    formatted = '${(absValue / 1000000).toStringAsFixed(2)}M';
  } else if (absValue < 1000000000000) {
    formatted = '${(absValue / 1000000000).toStringAsFixed(2)}B';
  } else {
    formatted = '${(absValue / 1000000000000).toStringAsFixed(2)}T';
  }

  return isNegative ? '-\$ $formatted' : '\$ $formatted';
}

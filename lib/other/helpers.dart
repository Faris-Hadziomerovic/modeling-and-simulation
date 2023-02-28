class Helpers {
  static String toPercentage(num total, num? part) {
    if (part == null) return '0 %';
    return '${(part / total * 100).toStringAsFixed(2)} %';
  }

  static double toPercentageDouble(num total, num? part) {
    if (part == null) return 0.0;
    return (part / total) * 100;
  }
}

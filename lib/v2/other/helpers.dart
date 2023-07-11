class Helpers {
  static String toPercentage(num total, num? part) {
    if (part == null) return '0 %';
    return '${(part / total * 100).toStringAsFixed(2)} %';
  }

  static double toPercentageDouble(num total, num? part) {
    if (part == null) return 0.0;
    return (part / total) * 100;
  }

  static String durationToString(Duration duration) {
    return duration.toString().split('.')[0];
  }

  static String secondsToDurationString(int seconds) {
    return durationToString(Duration(seconds: seconds));
  }

  static int convertMinutesToSeconds(double minutes) {
    return (minutes * 60).floor();
  }

  static int convertSecondsToMinutes(double seconds) {
    return (seconds / 60).floor();
  }
}

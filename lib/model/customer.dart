class Customer {
  final int arrivalTime;
  final int ordinalNumber;
  late final int _queueExitTime;

  int get queueExitTime => _queueExitTime;

  Customer({
    required this.arrivalTime,
    required this.ordinalNumber,
  });

  void hasExitedQueue(int currentMinute) {
    _queueExitTime = currentMinute;
  }
}

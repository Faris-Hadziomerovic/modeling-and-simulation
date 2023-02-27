class Worker {
  final String name;
  final int startTime;
  final int endTime;
  final int speedBonus;
  bool busy = false;

  Worker({
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.speedBonus,
  });

  bool isWorking(int currentMinute) {
    return startTime <= currentMinute && currentMinute < endTime;
  }
}

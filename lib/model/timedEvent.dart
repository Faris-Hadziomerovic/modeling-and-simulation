class TimedEvent {
  final String name;
  final int startTime;
  final int endTime;

  const TimedEvent({
    required this.name,
    required this.startTime,
    required this.endTime,
  });

  bool isActive(int currentMinute) {
    return startTime <= currentMinute && currentMinute < endTime;
  }
}

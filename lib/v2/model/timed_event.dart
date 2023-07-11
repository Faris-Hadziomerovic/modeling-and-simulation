// Unimportant - ignore

class TimedEvent {
  final String name;
  final Duration startTime;
  final Duration endTime;

  const TimedEvent({
    required this.name,
    required this.startTime,
    required this.endTime,
  });

  bool isActive(int currentSecond) {
    return startTime.inSeconds <= currentSecond && currentSecond < endTime.inSeconds;
  }
}

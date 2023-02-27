import '../model/timedEvent.dart';

class Peaks {
  static const peak1 = TimedEvent(
    name: 'Peak 1',
    startTime: 720, // 12:00
    endTime: 780, // 13:00
  );

  static const peak2 = TimedEvent(
    name: 'Peak 2',
    startTime: 1050, // 17:30
    endTime: 1230, // 20:30
  );
}

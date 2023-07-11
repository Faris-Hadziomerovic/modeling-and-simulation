import '../model/timed_event.dart';

/// Time event constants used in the simulation.
class TimedEvents {
  static const openHours = TimedEvent(
    name: 'Open hours:   8:00 - 22:00',
    startTime: Duration(hours: 8),
    endTime: Duration(hours: 22),
  );

  static const peak1 = TimedEvent(
    name: 'Peak 1:   12:00 - 13:00',
    startTime: Duration(hours: 12),
    endTime: Duration(hours: 13),
  );

  static const peak2 = TimedEvent(
    name: 'Peak 2:   17:30 - 20:30',
    startTime: Duration(hours: 17, minutes: 30),
    endTime: Duration(hours: 20, minutes: 30),
  );

  /// Returns `true` if the peak event is active for the [currentTime].
  static bool isPeakTime({required Duration currentTime}) {
    return peak1.startTime <= currentTime && currentTime <= peak1.endTime ||
        peak2.startTime <= currentTime && currentTime <= peak2.endTime;
  }
}

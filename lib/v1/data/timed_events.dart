import '../constants/worker_shifts.dart';
import '../model/timedEvent.dart';

class TimedEvents {
  static const openHours = TimedEvent(
    name: 'Open hours:   8:00 - 22:00',
    startTime: 480, // 8:00
    endTime: 1320, // 22:00
  );

  static const peak1 = TimedEvent(
    name: 'Peak 1:   12:00 - 13:00',
    startTime: 720, // 12:00
    endTime: 780, // 13:00
  );

  static const peak2 = TimedEvent(
    name: 'Peak 2:   17:30 - 20:30',
    startTime: 1050, // 17:30
    endTime: 1230, // 20:30
  );

  static const overlap1 = TimedEvent(
    name: 'Overlap 1: John-Baker',
    startTime: WorkerShifts.bakerStartTime,
    endTime: WorkerShifts.johnEndTime,
  );

  static const overlap2 = TimedEvent(
    name: 'Overlap 2: Able-Baker',
    startTime: WorkerShifts.ableStartTime,
    endTime: WorkerShifts.bakerEndTime,
  );

  /// Returns <code>true</code> if the peak event is active for the <i>currentMinute</i>.
  /// <i>isNormalizedTime</i> represents if the time starts from 480 (counting from 8:00) or 0 (for normalized time this is 00:00)
  static bool isPeakTime({required int currentMinute, bool isNormalizedTime = true}) {
    if (isNormalizedTime) {
      return peak1.startTime <= currentMinute && currentMinute <= peak1.endTime ||
          peak2.startTime <= currentMinute && currentMinute <= peak2.endTime;
    } else {
      return peak1.startTime - 480 <= currentMinute && currentMinute <= peak1.endTime - 480 ||
          peak2.startTime - 480 <= currentMinute && currentMinute <= peak2.endTime - 480;
    }
  }

  /// Returns <code>true</code> if the overlap event (two worker shifts are overlapping) is active for the <i>currentMinute</i>.
  /// <i>isNormalizedTime</i> represents if the time starts from 480 (counting from 8:00) or 0 (for normalized time this is 00:00)
  static bool isOverlapTime({required int currentMinute, bool isNormalizedTime = true}) {
    if (isNormalizedTime) {
      return overlap1.startTime <= currentMinute && currentMinute <= overlap1.endTime ||
          overlap2.startTime <= currentMinute && currentMinute <= overlap2.endTime;
    } else {
      return overlap1.startTime - 480 <= currentMinute && currentMinute <= overlap1.endTime - 480 ||
          overlap2.startTime - 480 <= currentMinute && currentMinute <= overlap2.endTime - 480;
    }
  }
}

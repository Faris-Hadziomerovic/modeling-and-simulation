import '../constants/timed_events.dart';
import '../model/queue_v2.dart';
import '../other/helpers.dart';
import '../model/worker_v2.dart';

/// TODO: Everything should in seconds or Duration (prefered).
///
/// This is maybe done.
class WorkersV2 {
  late final WorkerV2 John;
  late final WorkerV2 Baker;
  late final WorkerV2 Able;

  Duration get combinedWorkingTime => John.totalWorkTime + Baker.totalWorkTime + Able.totalWorkTime;
  Duration get combinedBusyTime => John.busyTime + Baker.busyTime + Able.busyTime;
  Duration get combinedIdleTime => John.idleTime + Baker.idleTime + Able.idleTime;
  Duration get combinedServiceTime => John.totalServiceTime + Baker.totalServiceTime + Able.totalServiceTime;

  String get busyToWorkPercentage => Helpers.toPercentage(combinedWorkingTime.inSeconds, combinedBusyTime.inSeconds);
  String get idleToWorkPercentage => Helpers.toPercentage(combinedWorkingTime.inSeconds, combinedIdleTime.inSeconds);

  String get JohnWorkTimePercentage => Helpers.toPercentage(combinedWorkingTime.inSeconds, John.totalWorkTime.inSeconds);
  String get JohnBusyToCombinedWorkPercentage => Helpers.toPercentage(combinedBusyTime.inSeconds, John.busyTime.inSeconds);
  String get JohnIdleToCombinedWorkPercentage => Helpers.toPercentage(combinedIdleTime.inSeconds, John.idleTime.inSeconds);

  String get BakerWorkTimePercentage => Helpers.toPercentage(combinedWorkingTime.inSeconds, Baker.totalWorkTime.inSeconds);
  String get BakerBusyToCombinedWorkPercentage => Helpers.toPercentage(combinedBusyTime.inSeconds, Baker.busyTime.inSeconds);
  String get BakerIdleToCombinedWorkPercentage => Helpers.toPercentage(combinedIdleTime.inSeconds, Baker.idleTime.inSeconds);

  String get AbleWorkTimePercentage => Helpers.toPercentage(combinedWorkingTime.inSeconds, Able.totalWorkTime.inSeconds);
  String get AbleBusyToCombinedWorkPercentage => Helpers.toPercentage(combinedBusyTime.inSeconds, Able.busyTime.inSeconds);
  String get AbleIdleToCombinedWorkPercentage => Helpers.toPercentage(combinedIdleTime.inSeconds, Able.idleTime.inSeconds);

  WorkersV2({bool useModifiedVersion = false}) {
    John = WorkerV2(
      name: 'John',
      startTime: TimedEvents.openHours.startTime,
      endTime: TimedEvents.openHours.endTime,
      speedFactor: 1.25, // this will slow him down
      queue: CustomerQueueV2(),
    );

    Baker = WorkerV2(
      name: 'Baker',
      startTime: TimedEvents.openHours.startTime,
      endTime: TimedEvents.openHours.endTime,
      speedFactor: 1.0,
      queue: CustomerQueueV2(),
    );

    Able = WorkerV2(
      name: 'Able',
      startTime: TimedEvents.openHours.startTime,
      endTime: TimedEvents.openHours.endTime,
      speedFactor: 0.70, // this will speed him up
      queue: CustomerQueueV2(),
    );
  }

  void synchronizeTime({required Duration currentTime, bool printStatus = false}) {
    John.refreshBusyStatus(currentTime);
    Baker.refreshBusyStatus(currentTime);
    Able.refreshBusyStatus(currentTime);

    if (printStatus) {
      print('------------------------------------------------');
      print('Time: ${Helpers.durationToString(currentTime)}');
      printWorkingStatus(currentTime: currentTime);
      printBusyStatus();
      print('------------------------------------------------');
    }
  }

  bool haveOverlap({required Duration currentTime}) => true;

  void printWorkingStatus({required Duration currentTime}) {
    print('John: ${John.isWorking(currentTime) ? 'working' : 'not working'}');
    print('Baker: ${Baker.isWorking(currentTime) ? 'working' : 'not working'}');
    print('Able: ${Able.isWorking(currentTime) ? 'working' : 'not working'}');
  }

  void printBusyStatus() {
    print('John: ${John.isBusy ? 'busy' : 'available'}');
    print('Baker: ${Baker.isBusy ? 'busy' : 'available'}');
    print('Able: ${Able.isBusy ? 'busy' : 'available'}');
  }

  void printStatistics() {
    print('---------------------------------------------------------------------------');
    John.printStatistics();
    print('-');
    Baker.printStatistics();
    print('-');
    Able.printStatistics();
    print('-');

    print('Combined working time: ${combinedWorkingTime}');
    print('Combined service time: ${combinedServiceTime}');
    print('-');
    print("John's part of total work time: ${JohnWorkTimePercentage}");
    print("Baker's part of total work time: ${BakerWorkTimePercentage}");
    print("Able's part of total work time: ${AbleWorkTimePercentage}");
    print('-');
    print('Combined busy time: ${combinedBusyTime}');
    print('Busy to work time ratio: ${busyToWorkPercentage}');
    print('-');
    print("John's part of combined busy time: ${JohnBusyToCombinedWorkPercentage}");
    print("Baker's part of combined busy time: ${BakerBusyToCombinedWorkPercentage}");
    print("Able's part of combined busy time: ${AbleBusyToCombinedWorkPercentage}");
    print('-');
    print('Combined idle time: ${combinedIdleTime}');
    print('Idle to work time ratio: ${idleToWorkPercentage}');
    print('-');
    print("John's part of combined idle time: ${JohnIdleToCombinedWorkPercentage}");
    print("Baker's part of combined idle time: ${BakerIdleToCombinedWorkPercentage}");
    print("Able's part of combined idle time: ${AbleIdleToCombinedWorkPercentage}");
    print('---------------------------------------------------------------------------');
  }
}

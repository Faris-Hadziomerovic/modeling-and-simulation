import '../constants/worker_shifts.dart';
import '../model/worker.dart';
import '../other/helpers.dart';

class Workers {
  late final Worker John;
  late final Worker Baker;
  late final Worker Able;

  int get combinedWorkingTime => John.totalWorkTime + Baker.totalWorkTime + Able.totalWorkTime;
  int get combinedBusyTime => John.busyTime + Baker.busyTime + Able.busyTime;
  int get combinedIdleTime => John.idleTime + Baker.idleTime + Able.idleTime;
  int get combinedServiceTime => John.totalServiceTime + Baker.totalServiceTime + Able.totalServiceTime;

  String get busyToWorkPercentage => Helpers.toPercentage(combinedWorkingTime, combinedBusyTime);
  String get idleToWorkPercentage => Helpers.toPercentage(combinedWorkingTime, combinedIdleTime);

  String get JohnWorkTimePercentage => Helpers.toPercentage(combinedWorkingTime, John.totalWorkTime);
  String get JohnBusyToCombinedWorkPercentage => Helpers.toPercentage(combinedBusyTime, John.busyTime);
  String get JohnIdleToCombinedWorkPercentage => Helpers.toPercentage(combinedIdleTime, John.idleTime);

  String get BakerWorkTimePercentage => Helpers.toPercentage(combinedWorkingTime, Baker.totalWorkTime);
  String get BakerBusyToCombinedWorkPercentage => Helpers.toPercentage(combinedBusyTime, Baker.busyTime);
  String get BakerIdleToCombinedWorkPercentage => Helpers.toPercentage(combinedIdleTime, Baker.idleTime);

  String get AbleWorkTimePercentage => Helpers.toPercentage(combinedWorkingTime, Able.totalWorkTime);
  String get AbleBusyToCombinedWorkPercentage => Helpers.toPercentage(combinedBusyTime, Able.busyTime);
  String get AbleIdleToCombinedWorkPercentage => Helpers.toPercentage(combinedIdleTime, Able.idleTime);

  Workers() {
    John = Worker(
      name: 'John',
      startTime: WorkerShifts.johnStartTime,
      endTime: WorkerShifts.johnEndTime,
      speedBonus: 7, // this will slow him down
    );

    Baker = Worker(
      name: 'Baker',
      startTime: WorkerShifts.bakerStartTime,
      endTime: WorkerShifts.bakerEndTime,
      speedBonus: 0,
    );

    Able = Worker(
      name: 'Able',
      startTime: WorkerShifts.ableStartTime,
      endTime: WorkerShifts.ableEndTime,
      speedBonus: -10, // this will speed him up
    );
  }

  void synchronizeTime({required int currentMinute, bool printStatus = false}) {
    John.refreshBusyStatus(currentMinute);
    Baker.refreshBusyStatus(currentMinute);
    Able.refreshBusyStatus(currentMinute);

    if (printStatus) {
      print('------------------------------------------------');
      print('Time: $currentMinute minute.');
      printWorkingStatus(currentMinute: currentMinute);
      printBusyStatus();
      print('------------------------------------------------');
    }
  }

  bool haveOverlap({required int currentMinute}) {
    return John.isWorking(currentMinute) && Baker.isWorking(currentMinute) ||
        Able.isWorking(currentMinute) && Baker.isWorking(currentMinute);
  }

  void printWorkingStatus({required int currentMinute}) {
    print('John: ${John.isWorking(currentMinute) ? 'working' : 'not working'}');
    print('Baker: ${Baker.isWorking(currentMinute) ? 'working' : 'not working'}');
    print('Able: ${Able.isWorking(currentMinute) ? 'working' : 'not working'}');
  }

  void printBusyStatus() {
    print('John: ${John.isBusy ? 'busy' : 'available'}');
    print('Baker: ${Baker.isBusy ? 'busy' : 'available'}');
    print('Able: ${Able.isBusy ? 'busy' : 'available'}');
  }

  void printStatistics() {
    print('---------------------------------------------------------------------------');
    John.printStatistics();
    print('');
    Baker.printStatistics();
    print('');
    Able.printStatistics();
    print('');

    print('Combined working time: ${combinedWorkingTime}');
    print('Combined service time: ${combinedServiceTime}');
    print('');
    print("John's part of total work time: ${JohnWorkTimePercentage}");
    print("Baker's part of total work time: ${BakerWorkTimePercentage}");
    print("Able's part of total work time: ${AbleWorkTimePercentage}");
    print('');
    print('Combined busy time: ${combinedBusyTime}');
    print('Busy to work time ratio: ${busyToWorkPercentage}');
    print('');
    print("John's part of combined busy time: ${JohnBusyToCombinedWorkPercentage}");
    print("Baker's part of combined busy time: ${BakerBusyToCombinedWorkPercentage}");
    print("Able's part of combined busy time: ${AbleBusyToCombinedWorkPercentage}");
    print('');
    print('Combined idle time: ${combinedIdleTime}');
    print('Idle to work time ratio: ${idleToWorkPercentage}');
    print('');
    print("John's part of combined idle time: ${JohnIdleToCombinedWorkPercentage}");
    print("Baker's part of combined idle time: ${BakerIdleToCombinedWorkPercentage}");
    print("Able's part of combined idle time: ${AbleIdleToCombinedWorkPercentage}");
    print('---------------------------------------------------------------------------');
  }
}

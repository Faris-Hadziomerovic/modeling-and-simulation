import '../model/worker.dart';

class Workers {
  late final Worker John;
  late final Worker Baker;
  late final Worker Able;

  Workers() {
    John = Worker(
      name: 'John',
      startTime: 480, // 8:00
      endTime: 840, // 14:00
      speedBonus: 3, // this will slow him down
    );

    Baker = Worker(
      name: 'Baker',
      startTime: 720, // 12:00
      endTime: 1200, // 20:00
      speedBonus: 0,
    );

    Able = Worker(
      name: 'Able',
      startTime: 960, // 16:00
      endTime: 1320, // 22:00
      speedBonus: -3, // this will speed him up
    );
  }

  void synchronizeTime({required int currentMinute}) {
    John.refreshBusyStatus(currentMinute);
    Baker.refreshBusyStatus(currentMinute);
    Able.refreshBusyStatus(currentMinute);

    if (John.isBusy && Baker.isBusy || Baker.isBusy && Able.isBusy) {
      print('\n------------------------------------------------\n');
      print('Time: $currentMinute minute.');
      printWorkingStatus(currentMinute: currentMinute);
      printBusyStatus();
      print('\n------------------------------------------------\n');
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
}

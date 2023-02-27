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
      startTime: 960, // 14:00
      endTime: 1320, // 22:00
      speedBonus: -3, // this will speed him up
    );
  }
}

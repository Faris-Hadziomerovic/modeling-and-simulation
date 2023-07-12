import '../other/helpers.dart';
import '../model/worker_v2.dart';
import './queues_v2.dart';

/// This is done for now.
///
/// Convenience class for creating needed workers for the simulation.
class WorkersV2 {
  late final WorkerV2 John;
  late final WorkerV2 Baker;
  late final WorkerV2 Able;

  WorkersV2({CustomerQueuesV2? queues}) {
    queues ??= CustomerQueuesV2();

    John = WorkerV2(
      name: 'John',
      speedFactor: 1.25, // this will slow him down
      queue: queues.john,
      completedQueue: queues.completed,
    );

    Baker = WorkerV2(
      name: 'Baker',
      speedFactor: 1.0,
      queue: queues.baker,
      completedQueue: queues.completed,
    );

    Able = WorkerV2(
      name: 'Able',
      speedFactor: 0.70, // this will speed him up
      queue: queues.able,
      completedQueue: queues.completed,
    );
  }

  /// Synchronizes all workers with the current time.
  ///
  /// Prints their busy status if [printStatus] is `true`.
  void synchronizeTime({required Duration currentTime, bool printStatus = false}) {
    John.refreshBusyStatus(currentTime);
    Baker.refreshBusyStatus(currentTime);
    Able.refreshBusyStatus(currentTime);

    if (printStatus) {
      print('------------------------------------------------');
      print('Time: ${Helpers.durationToString(currentTime)}');
      printBusyStatus();
      print('------------------------------------------------');
    }
  }

  /// Prints the workers' busy status.
  void printBusyStatus() {
    print('John: ${John.isBusy ? 'busy' : 'available'}');
    print('Baker: ${Baker.isBusy ? 'busy' : 'available'}');
    print('Able: ${Able.isBusy ? 'busy' : 'available'}');
  }
}

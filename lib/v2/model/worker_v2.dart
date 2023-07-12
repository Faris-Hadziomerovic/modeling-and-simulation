// NOT FINISHED
// Need to document some things, remove other things.

import 'dart:math';

import '../constants/general_constants.dart';
import '../constants/service_time.dart';
import '../data/service_time.dart';
import 'customer_v2.dart';
import '../other/helpers.dart';
import 'queue_v2.dart';

/// Everything is in seconds.
class WorkerV2 {
  /// For logging
  final String name;

  /// The speed that is factored in the final service time.
  ///
  /// Lower is faster, higher is slower.
  ///
  /// Range from `0.0` to `2.0`, realistically it should range from around `0.60` to `1.40`. <br>
  final double speedFactor;

  /// Worker will now control the queue and take customers out.
  final CustomerQueueV2 queue;

  /// The place where customers go when their journey is complete.
  final CustomerQueueV2 completedQueue;

  bool _busy = false;
  Duration _freeAt = Duration.zero;
  Duration _totalServiceTime = Duration.zero;
  int _totalCustomersServed = 0;

  bool get isBusy => _busy;
  bool get isNotBusy => !_busy;
  Duration get freeAt => _freeAt;
  Duration get totalServiceTime => _totalServiceTime;
  int get totalCustomersServed => _totalCustomersServed;

  /// Statistic for logging. <br>
  /// The total service time divided by the total number of customers served.
  Duration get averageServiceTime => Duration(seconds: (totalServiceTime.inSeconds / totalCustomersServed).round());

  WorkerV2({
    required this.name,
    required this.speedFactor,
    required this.queue,
    required this.completedQueue,
  });

  void incrementTotalServiceTime() => _totalServiceTime += Time.oneSecond;

  /// Synchronizes the worker with the current minute and refreshes their [isBusy] status.
  void refreshBusyStatus(Duration currentTime) {
    if (currentTime >= _freeAt) {
      _busy = false;
    }
  }

  // TODO: finish this
  void syncTime({required Duration currentTime}) {}

  /// Sets the workers [isBusy] status to `true`,
  /// increments busy time, updates service time and customers served count.
  ///
  /// Completes the customers journey.
  void assignCustomer({
    required Duration currentTime,
    required CustomerV2 customer,
    bool printUpdate = false,
  }) {
    final serviceTime = _generateServiceTime(itemCount: customer.numberOfItemsInCart);
    _totalServiceTime += serviceTime;
    _freeAt = currentTime + serviceTime;
    _busy = true;
    incrementTotalServiceTime();
    _totalCustomersServed++;

    customer.beginService(currentTime: currentTime, serviceTime: serviceTime);

    if (printUpdate) {
      print(
        '$name was assigned a customer at ${Helpers.durationToString(currentTime)}'
        ' with a service time of ${Helpers.durationToString(serviceTime)}.',
      );
    }

    // The customers story ends here.
    completedQueue.add(customer, currentTime: currentTime);
  }

  /// Generates service time for the worker according to their [speedFactor].
  /// If [itemCount] is not null then the service time will be calculated based on it,
  /// the speed factor and the [ServiceTime.secondsPerItem] constant.
  ///
  /// <b> TODO: improve this if needed and dont forget to change serviceTimeInMinutes to seconds when its also changed </b>
  Duration _generateServiceTime({int? itemCount}) {
    if (itemCount != null) {
      final serviceTimeInSeconds = itemCount * ServiceTime.secondsPerItem * speedFactor;

      return Duration(seconds: serviceTimeInSeconds.round());
    }

    final serviceTimeInMinutes = ServiceTimeData.getServiceTime(Random().nextInt(100)) * speedFactor;

    return Duration(seconds: Helpers.convertMinutesToSeconds(serviceTimeInMinutes));
  }

  /// Prints all the worker's information and their current status.
  void printStatus(int? currentMinute) {
    if (currentMinute != null) print('Current time: $currentMinute');
    print('Name: $name');
    print('Status: ${_busy ? 'busy' : 'available'}');
    if (_busy) print('Next available time: $_freeAt');
    print('Total service time: $_totalServiceTime minutes');
    print('Average service time: $averageServiceTime minutes');
    print('Service time (addition) bonus: $speedFactor');
  }

  /// Prints all the worker's statistics.
  void printStatistics() {
    print('Name: $name');
    print('Service time (addition) bonus: $speedFactor');
    print('Total service time: $_totalServiceTime');
    print('Average service time: $averageServiceTime');
  }

  String toCsv() {
    return '';
  }

  String toStringVerbose() {
    return '''
      Name: $name,
      Status: ${_busy ? 'busy' : 'available'}, ${_busy ? '/nNext available time: $_freeAt,' : ''}
      Service time (addition) bonus: $speedFactor,
      Total service time: $_totalServiceTime,
      Average service time: $averageServiceTime''';
  }

  @override
  String toString() => name;

  /// Removes a customer from the queue and assignes them to the worker if possible.
  /// Updates worker's stats accordingly.
  ///
  /// <b> TODO: modify to suit new assignment </b>
  void doWork({
    required Duration currentTime,
    CustomerQueueV2? queue,
  }) {
    queue ??= this.queue;

    if (isNotBusy) {
      if (queue.isNotEmpty) {
        final customer = queue.remove(
          currentTime: currentTime,
          printUpdates: true,
        );

        assignCustomer(
          currentTime: currentTime,
          customer: customer,
          printUpdate: true,
        );
      }
    } else {
      incrementTotalServiceTime();
    }
  }
}

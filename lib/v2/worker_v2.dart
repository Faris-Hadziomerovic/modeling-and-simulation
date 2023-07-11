import 'dart:math';

import 'constants/general_constants.dart';
import 'constants/service_time.dart';
import 'data/service_time.dart';
import 'model/customer_v2.dart';
import 'other/helpers.dart';

/// Everything is in seconds.
class WorkerV2 {
  final String name;
  final Duration startTime;
  final Duration endTime;
  final double speedFactor;

  late final Duration totalWorkTime;

  bool _busy = false;
  Duration _idleTime = Duration.zero;
  Duration _busyTime = Duration.zero;
  Duration _freeAt = Duration.zero;
  Duration _totalServiceTime = Duration.zero;
  int _totalCustomersServed = 0;

  bool get isBusy => _busy;
  bool get isNotBusy => !_busy;
  Duration get idleTime => _idleTime;
  Duration get busyTime => _busyTime;
  Duration get freeAt => _freeAt;
  Duration get totalServiceTime => _totalServiceTime;
  int get totalCustomersServed => _totalCustomersServed;

  double get averageServiceTime => double.parse((totalServiceTime.inSeconds / totalCustomersServed).toStringAsFixed(2));

  WorkerV2({
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.speedFactor,
  }) : assert(endTime > startTime) {
    totalWorkTime = endTime - startTime;
  }

  void incrementIdleTime() => _idleTime += Time.oneSecond;
  void incrementBusyTime() => _busyTime += Time.oneSecond;

  /// Returns `true` if it's the workers shift.
  bool isWorking(Duration currentTime) {
    return startTime <= currentTime && currentTime <= endTime;
  }

  /// Synchronizes the worker with the current minute and refreshes their <code>busy</code> status.
  void refreshBusyStatus(Duration currentTime) {
    if (currentTime >= _freeAt) {
      _busy = false;
    }
  }

  /// Sets the workers <i>busy</i> status to <code>true</code>,
  /// increments busy time, updates service time and customers served count.
  void assignCustomer({required Duration currentTime, required CustomerV2 customer, bool printUpdate = false}) {
    final serviceTime = _generateServiceTime(itemCount: customer.numberOfItemsInCart);
    _totalServiceTime += serviceTime;
    _freeAt = currentTime + serviceTime;
    _busy = true;
    incrementBusyTime();
    _totalCustomersServed++;

    if (printUpdate) {
      print(
        '$name was assigned a customer at ${Helpers.durationToString(currentTime)}'
        ' with a service time of ${Helpers.durationToString(serviceTime)} seconds.',
      );
    }
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
    print('Total idle time: $_idleTime minutes');
    print('Total busy time: $_busyTime minutes');
    print('Total service time: $_totalServiceTime minutes');
    print('Average service time: $averageServiceTime minutes');
    print('Service time (addition) bonus: $speedFactor');
  }

  /// Prints all the worker's statistics.
  void printStatistics() {
    print('Name: $name');
    print('Service time (addition) bonus: $speedFactor');
    print('Total work time: $totalWorkTime');
    print('Total service time: $_totalServiceTime');
    print('Average service time: $averageServiceTime');
    print('Total idle time: $_idleTime minutes');
    print('Total busy time: $_busyTime minutes');
  }

  String toStringVerbose() {
    return '''
      Name: $name,
      Status: ${_busy ? 'busy' : 'available'}, ${_busy ? '/nNext available time: $_freeAt,' : ''}
      Service time (addition) bonus: $speedFactor,
      Total work time: $totalWorkTime,
      Total service time: $_totalServiceTime,
      Average service time: $averageServiceTime,
      Total idle time: $_idleTime,
      Total busy time: $_busyTime''';
  }

  @override
  String toString() => name;
}

import 'dart:math';

import '../data/service_time.dart';
import '../other/helpers.dart';

/// Everything is in minutes.
class Worker {
  final String name;
  final int startTime;
  final int endTime;
  final int speedBonus;
  late final int totalWorkTime;

  bool _busy = false;
  int _idleTime = 0;
  int _busyTime = 0;
  int _freeAt = 0;
  int _totalServiceTime = 0;
  int _totalCustomersServed = 0;

  bool get isBusy => _busy;
  bool get isNotBusy => !_busy;
  int get idleTime => _idleTime;
  int get busyTime => _busyTime;
  int get freeAt => _freeAt;
  int get totalServiceTime => _totalServiceTime;
  int get totalCustomersServed => _totalCustomersServed;

  String get busyToWorkPercent => Helpers.toPercentage(totalWorkTime, busyTime);
  String get idleToWorkPercent => Helpers.toPercentage(totalWorkTime, idleTime);
  double get busyToWorkRatio => double.parse((busyTime / totalWorkTime).toStringAsFixed(2));
  double get idleToWorkRatio => double.parse((idleTime / totalWorkTime).toStringAsFixed(2));
  double get averageServiceTime => double.parse((totalServiceTime / totalCustomersServed).toStringAsFixed(2));

  Worker({
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.speedBonus,
  }) : assert(endTime > startTime) {
    totalWorkTime = endTime - startTime;
  }

  void incrementIdleTime() => _idleTime++;
  void incrementBusyTime() => _busyTime++;

  /// Returns <code>true</code> if it's the workers shift.
  bool isWorking(int currentMinute) {
    return startTime <= currentMinute && currentMinute <= endTime;
  }

  /// Synchronizes the worker with the current minute and refreshes their <code>busy</code> status.
  void refreshBusyStatus(int currentMinute) {
    if (currentMinute >= _freeAt) {
      _busy = false;
    }
  }

  /// Sets the workers <i>busy</i> status to <code>true</code>,
  /// increments busy time, updates service time and customers served count.
  void assignCustomer({required int currentMinute, bool printUpdate = false}) {
    final serviceTime = _generateServiceTime();
    _totalServiceTime += serviceTime;
    _freeAt = currentMinute + serviceTime;
    _busy = true;
    incrementBusyTime();
    _totalCustomersServed++;

    if (printUpdate) ('$name was assigned a customer at $currentMinute with a service time of $serviceTime');
  }

  /// Generates service time for the worker according to their <i>speedBonus</i>.
  int _generateServiceTime() {
    return ServiceTimeData.getServiceTime(Random().nextInt(100) + speedBonus);
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
    print('Service time (addition) bonus: $speedBonus');
  }

  /// Prints all the worker's statistics.
  void printStatistics() {
    print('Name: $name');
    print('Service time (addition) bonus: $speedBonus');
    print('Total work time: $totalWorkTime');
    print('Total service time: $_totalServiceTime');
    print('Average service time: $averageServiceTime');
    print('Total idle time: $_idleTime minutes');
    print('Total busy time: $_busyTime minutes');
    print('Idle time ratio: $idleToWorkPercent');
    print('Busy time ratio: $busyToWorkPercent');
  }

  String toStringVerbose() {
    return '''
      Name: $name,
      Status: ${_busy ? 'busy' : 'available'}, ${_busy ? '/nNext available time: $_freeAt,' : ''}
      Service time (addition) bonus: $speedBonus,
      Total work time: $totalWorkTime,
      Total service time: $_totalServiceTime,
      Average service time: $averageServiceTime,
      Total idle time: $_idleTime,
      Total busy time: $_busyTime,
      Idle time ratio: $idleToWorkPercent,
      Busy time ratio: $busyToWorkPercent''';
  }

  @override
  String toString() => name;
}

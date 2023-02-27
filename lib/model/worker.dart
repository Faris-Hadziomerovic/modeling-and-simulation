import 'dart:math';

import '../data/service_time.dart';

class Worker {
  final String name;
  final int startTime;
  final int endTime;
  final int speedBonus;
  bool _busy = false;
  int _idleMinutes = 0;
  int _busyMinutes = 0;
  int _freeAt = 0;

  Worker({
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.speedBonus,
  });

  bool get isBusy => _busy;

  bool get isNotBusy => !_busy;

  void incrementIdleTime() => _idleMinutes++;
  void incrementBusyTime() => _busyMinutes++;

  /// Returns <code>true</code> if it's the workers shift.
  bool isWorking(int currentMinute) {
    return startTime <= currentMinute && currentMinute < endTime;
  }

  /// Synchronizes the worker with the current minute and refreshes their <code>busy</code> status.
  void refreshBusyStatus(int currentMinute) {
    if (currentMinute >= _freeAt) {
      _busy = false;
    }
  }

  /// Sets the workers <code>busy</code> status to <code>true</code>
  void assignCustomer(int currentMinute) {
    final serviceTime = _generateServiceTime();
    _freeAt = currentMinute + serviceTime;
    _busy = true;
    incrementBusyTime();
  }

  /// Prints all the worker information.
  void printStatus(int? currentMinute) {
    if (currentMinute != null) print('Current time: $currentMinute');
    print('Name: $name');
    print('Status: ${_busy ? 'busy' : 'available'}');
    if (!_busy) print('Next available time: $_freeAt');
    print('Idle time: $_idleMinutes minutes');
    print('Busy time: $_busyMinutes minutes');
    print('Service time (addition) bonus: $speedBonus');
  }

  /// Generates service time for the worker according to their <code>speedBonus</code>
  int _generateServiceTime() {
    return getServiceTime(Random().nextInt(100) + speedBonus);
  }
}

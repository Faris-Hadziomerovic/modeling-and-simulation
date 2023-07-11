// NOT FINISHED
// TODO: Need to add logging of important things that Hana mentioned.
// TODO: Need to refactor into new time model.

import './customer_v2.dart';

/// This is the main customer queue where they wait until served. <br>
/// Each worker should be assigned a queue. <br>
/// There should be a completed customer queue also where they all go after being served.
///
/// The statistics for now are mostly unimportand, this queue mostly just keeps customers customers until their service.
/// Keep them for now and remove what is unused in the final version.
class CustomerQueueV2 {
  final _queue = <CustomerV2>[];

  int _queueLengthAccumulator = 0;
  int _queueLengthRecordedTimes = 0;

  int _totalNumberOfCustomers = 0;
  int _maxLength = 0;
  int _minuteOfMaxLength = 0;
  int _totalWaitingTime = 0;
  int _longestWaitingTime = 0;
  int _timeOfArrivalOfLongestWaitingCustomer = 0;
  int _timeOfExitOfLongestWaitingCustomer = 0;

  List<CustomerV2> get queueData => [..._queue];

  int get length => _queue.length;
  bool get isEmpty => _queue.isEmpty;
  bool get isNotEmpty => _queue.isNotEmpty;

  int get totalNumberOfCustomers => _totalNumberOfCustomers;
  int get maxLength => _maxLength;
  int get minuteOfMaxLength => _minuteOfMaxLength;
  int get totalWaitingTime => _totalWaitingTime;
  int get longestWaitingTime => _longestWaitingTime;
  int get timeOfArrivalOfLongestWaitingCustomer => _timeOfArrivalOfLongestWaitingCustomer;
  int get timeOfExitOfLongestWaitingCustomer => _timeOfExitOfLongestWaitingCustomer;

  double get averageQueueLength => double.parse((_queueLengthAccumulator / _queueLengthRecordedTimes).toStringAsFixed(2));
  double get averageWaitingTime => double.parse((totalWaitingTime / totalNumberOfCustomers).toStringAsFixed(2));

  CustomerQueueV2();

  /// Takes note of the current queue length and how many times it was recorded for average length statistics.
  void recordQueueLength() {
    _queueLengthAccumulator += length;
    _queueLengthRecordedTimes++;
  }

  /// Adds customer at the end of the queue.
  void add(CustomerV2 customer, {required int currentMinute, bool printUpdates = false}) {
    _queue.add(customer);

    _totalNumberOfCustomers++;

    if (printUpdates) print('Customer added to queue at minute: $currentMinute');

    if (_queue.length > _maxLength) {
      _maxLength = _queue.length;
      _minuteOfMaxLength = currentMinute;
      if (printUpdates) print('Longest queue length yet: $_maxLength');
    }
  }

  /// Removes and returns the customer at the first position from queue.
  CustomerV2 remove({required int currentMinute, bool printUpdates = false}) {
    if (_queue.isEmpty) throw Exception('Queue is empty');

    final customer = _queue.removeAt(0);

    final waitingTime = customer.exitQueue(currentMinute);

    _totalWaitingTime += waitingTime;

    if (printUpdates) {
      print('Customer removed from queue at minute: $currentMinute');
      print('Current queue length: ${_queue.length}');
    }

    if (waitingTime > _longestWaitingTime) {
      _longestWaitingTime = waitingTime;
      _timeOfArrivalOfLongestWaitingCustomer = customer.arrivalTime;
      _timeOfExitOfLongestWaitingCustomer = customer.queueExitTime!;

      if (printUpdates) {
        print('Longest waiting time yet: $_longestWaitingTime minutes');
        print('Time of arrival: ${_timeOfArrivalOfLongestWaitingCustomer}');
        print('Time of exit: ${_timeOfExitOfLongestWaitingCustomer}');
      }
    }

    return customer;
  }

  void printStatistics() {
    print('---------------------------------------------------------------------------');
    print('Total number of customers that entered the queue: $totalNumberOfCustomers');
    print('');
    print('Longest queue length: $maxLength');
    print('Time of longest queue length: $minuteOfMaxLength');
    print('Average queue length: $averageQueueLength');
    print('');
    print('Total waiting time: $totalWaitingTime');
    print('Average waiting time: $averageWaitingTime');
    print('Longest waiting time: $longestWaitingTime');
    print('Longest waiting customer arrival time: $timeOfArrivalOfLongestWaitingCustomer');
    print('Longest waiting customer exit time: $timeOfExitOfLongestWaitingCustomer');
    print('---------------------------------------------------------------------------');
  }

  @override
  String toString() {
    return ''' 
    Total number of customers: $totalNumberOfCustomers,
    Current queue length: ${_queue.length},
    Longest queue length: $_maxLength,
    Total waiting time: $_totalWaitingTime,
    Longest waiting time: $_longestWaitingTime,
    Average waiting time: $averageWaitingTime,
    The queue: ${_queue.toString()}
    ''';
  }
}

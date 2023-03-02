import './customer.dart';

class CustomerQueue {
  final _queue = <Customer>[];

  int _queueLengthAccumulator = 0;
  int _queueLengthRecordedTimes = 0;

  int _maxLength = 0;
  int _minuteOfMaxLength = 0;
  int _totalWaitingTime = 0;
  int _longestWaitingTime = 0;
  int _totalNumberOfCustomers = 0;

  List<Customer> get queueData => [..._queue];

  int get length => _queue.length;
  bool get isEmpty => _queue.isEmpty;
  bool get isNotEmpty => _queue.isNotEmpty;

  int get maxLength => _maxLength;
  int get minuteOfMaxLength => _minuteOfMaxLength;
  int get totalWaitingTime => _totalWaitingTime;
  int get longestWaitingTime => _longestWaitingTime;
  int get totalNumberOfCustomers => _totalNumberOfCustomers;

  double get averageQueueLength => double.parse((_queueLengthAccumulator / _queueLengthRecordedTimes).toStringAsFixed(2));
  double get averageWaitingTime => double.parse((totalWaitingTime / totalNumberOfCustomers).toStringAsFixed(2));

  CustomerQueue();

  void recordQueueLength() {
    _queueLengthAccumulator += length;
    _queueLengthRecordedTimes++;
  }

  /// Adds customer at the end of the queue.
  void add(Customer customer, {required int currentMinute, bool printUpdates = false}) {
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
  Customer remove({required int currentMinute, bool printUpdates = false}) {
    if (_queue.isEmpty) throw Exception('Queue is empty');

    final customer = _queue.removeAt(0);

    final waitingTime = customer.exitQueue(currentMinute);

    _totalWaitingTime += waitingTime;

    if (waitingTime > _longestWaitingTime) {
      _longestWaitingTime = waitingTime;
      if (printUpdates) print('Longest waiting time yet: $_longestWaitingTime');
    }

    if (printUpdates) {
      print('Customer removed from queue at minute: $currentMinute');
      print('Current queue length: ${_queue.length}');
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
    print('Longest waiting time: $longestWaitingTime');
    print('Average waiting time: $averageWaitingTime');
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

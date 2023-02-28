import 'customer.dart';

class CustomerQueue {
  int maxLength = 0;
  int minuteOfMaxLength = 0;

  final _queue = <Customer>[];

  int get length => _queue.length;
  bool get isEmpty => _queue.isEmpty;
  bool get isNotEmpty => _queue.isNotEmpty;

  CustomerQueue();

  /// Adds customer at the end of the queue.
  void add(Customer customer, {required int currentMinute, bool printUpdates = false}) {
    _queue.add(customer);

    if (printUpdates) print('Customer added to queue at minute: $currentMinute');

    if (_queue.length > maxLength) {
      maxLength = _queue.length;
      minuteOfMaxLength = currentMinute;
      if (printUpdates) print('Longest queue length: $maxLength');
    }
  }

  /// Removes customer at the first position from queue.
  Customer remove({required int currentMinute, bool printUpdates = false}) {
    if (_queue.isEmpty) throw Exception('Queue is empty');

    if (printUpdates) {
      print('Customer removed from queue at minute: $currentMinute');
      print('Current queue length: ${_queue.length - 1}');
    }

    return _queue.removeAt(0);
  }

  @override
  String toString() {
    return _queue.toString();
  }
}

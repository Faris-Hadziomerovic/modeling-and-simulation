// NOT FINISHED
// TODO: Need to add logging of important things that Hana mentioned.
// TODO: Need to refactor into new time model.

import './customer_v2.dart';
import '../other/helpers.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:excel/excel.dart';

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
  int _peakLength = 0;
  Duration _timeOfPeakLength = Duration.zero;
  Duration _totalWaitingTime = Duration.zero;
  Duration _longestWaitingTime = Duration.zero;
  Duration _timeOfArrivalOfLongestWaitingCustomer = Duration.zero;
  Duration _timeOfExitOfLongestWaitingCustomer = Duration.zero;

  List<CustomerV2> get queueData => [..._queue];

  int get length => _queue.length;
  bool get isEmpty => _queue.isEmpty;
  bool get isNotEmpty => _queue.isNotEmpty;

  int get totalNumberOfCustomers => _totalNumberOfCustomers;
  int get peakLength => _peakLength;
  Duration get timeOfPeakLength => _timeOfPeakLength;
  Duration get totalWaitingTime => _totalWaitingTime;
  Duration get longestWaitingTime => _longestWaitingTime;
  Duration get timeOfArrivalOfLongestWaitingCustomer => _timeOfArrivalOfLongestWaitingCustomer;
  Duration get timeOfExitOfLongestWaitingCustomer => _timeOfExitOfLongestWaitingCustomer;

  double get averageQueueLength => double.parse((_queueLengthAccumulator / _queueLengthRecordedTimes).toStringAsFixed(2));
  Duration get averageWaitingTime => Duration(seconds: (totalWaitingTime.inSeconds / totalNumberOfCustomers).round());

  CustomerQueueV2();

  /// <b> NOT IMPORTANT - IGNORE </b>
  ///
  /// Takes note of the current queue length and how many times it was recorded for average length statistics.
  void recordQueueLength() {
    _queueLengthAccumulator += length;
    _queueLengthRecordedTimes++;
  }

  /// Adds customer at the end of the queue.
  void add(CustomerV2 customer, {required Duration currentTime, bool printUpdates = false}) {
    _queue.add(customer);

    _totalNumberOfCustomers++;

    if (printUpdates) print('Customer added to queue at: ${Helpers.durationToString(currentTime)}');

    if (_queue.length > _peakLength) {
      _peakLength = _queue.length;
      _timeOfPeakLength = currentTime;

      if (printUpdates) print('Longest queue length yet: $_peakLength customers');
    }
  }

  /// Removes and returns the customer at the first position from queue.
  CustomerV2 remove({
    required Duration currentTime,
    bool printUpdates = false,
  }) {
    if (_queue.isEmpty) throw Exception('Queue is empty');

    final customer = _queue.removeAt(0);

    final waitingTime = customer.exitQueue(
      currentTime: currentTime,
    );

    _totalWaitingTime += waitingTime;

    if (printUpdates) {
      print('Customer removed from queue at: ${Helpers.durationToString(currentTime)}');
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

  String allCustomersToCsv() {
    String data = 'numberOfItemsInCart,'
        'mood,'
        'ordinalNumber,'
        'initialReadyToWaitTime,'
        'actualReadyToWaitTime,'
        'arrivalTime,'
        'hasRageQuitted,'
        'decision,'
        'waiting time,'
        'serviceTime\n';
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['NewSheet'];
    sheetObject.appendRow([
      'Mood',
      'OrdinalNumber',
      'initialReadyToWaitTime',
      'actualReadyToWaitTime',
      'arrivalTime',
      'hasRageQuitted',
      'decision',
      'waiting time',
      'serviceTime'
    ]);

    var list = _queue.map((e) => sheetObject.appendRow(e.toCsv() as List));
    excel.save(fileName: 'DataSheetExcel.xlsx');
    // TODO: is this okay?!?
    return data + _queue.map((e) => e.toCsv()).join();
  }

  void printStatistics() {
    print('---------------------------------------------------------------------------');
    print('Total number of customers that entered the queue: $totalNumberOfCustomers');
    print('');
    print('Longest queue length: $peakLength');
    print('Time of longest queue length: $timeOfPeakLength');
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
    Longest queue length: $_peakLength,
    Total waiting time: $_totalWaitingTime,
    Longest waiting time: $_longestWaitingTime,
    Average waiting time: $averageWaitingTime,
    The queue: ${_queue.toString()}
    ''';
  }
}

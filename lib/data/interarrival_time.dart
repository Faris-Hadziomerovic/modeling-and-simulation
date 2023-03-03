import 'dart:math';

import '../other/helpers.dart';
import './timed_events.dart';

class ArrivalData {
  Map<int, int> customersPerHourCounter = {
    8: 0,
    9: 0,
    10: 0,
    11: 0,
    12: 0,
    13: 0,
    14: 0,
    15: 0,
    16: 0,
    17: 0,
    18: 0,
    19: 0,
    20: 0,
    21: 0,
  };
  Map<int, int> allCounter = {
    1: 0,
    2: 0,
    3: 0,
    4: 0,
    5: 0,
    6: 0,
    7: 0,
    8: 0,
  };
  Map<int, int> normalCounter = {
    1: 0,
    2: 0,
    3: 0,
    4: 0,
    5: 0,
    6: 0,
    7: 0,
    8: 0,
  };
  Map<int, int> peakCounter = {
    1: 0,
    2: 0,
    3: 0,
    4: 0,
    5: 0,
    6: 0,
    7: 0,
    8: 0,
  };

  final allInterarrivalTimes = <int>[];
  final normalInterarrivalTimes = <int>[];
  final peakInterarrivalTimes = <int>[];

  final _allArrivalTimes = <int>[];
  final _normalArrivalTimes = <int>[];
  final _peakArrivalTimes = <int>[];

  int get numberOfArrivals => _allArrivalTimes.length;
  int get numberOfNormalArrivals => _normalArrivalTimes.length;
  int get numberOfPeakArrivals => _peakArrivalTimes.length;

  /// Normalized by being shifted forward by 480
  List<int> get arrivalTimes => _allArrivalTimes.map((e) => e + 480).toList();

  /// Normalized by being shifted forward by 480
  List<int> get normalArrivalTimes => _normalArrivalTimes.map((e) => e + 480).toList();

  /// Normalized by being shifted forward by 480
  List<int> get peakArrivalTimes => _peakArrivalTimes.map((e) => e + 480).toList();

  ArrivalData({bool printData = false, int? seed}) {
    generateNewArrivalData(printData: printData, seed: seed);
  }

  /// Returns an <code>int</code> representing number of minutes between arrivals based on the <i>randomNumber</i> passed.
  int getInterarrivalTime(int randomNumber) {
    final Map<bool, int> interarrivalMap = {
      randomNumber < 5: 1,
      5 <= randomNumber && randomNumber < 10: 2,
      10 <= randomNumber && randomNumber < 20: 3,
      20 <= randomNumber && randomNumber < 40: 4,
      40 <= randomNumber && randomNumber < 60: 5,
      60 <= randomNumber && randomNumber < 80: 6,
      80 <= randomNumber && randomNumber < 95: 7,
      95 <= randomNumber: 8,
    };

    final result = interarrivalMap[true] as int;

    // adding another tally for the result
    var count = allCounter[result] as int;
    count++;
    allCounter[result] = count;

    count = normalCounter[result] as int;
    count++;
    normalCounter[result] = count;

    return result;
  }

  /// Returns an <code>int</code> representing number of minutes between arrivals based on the <i>randomNumber</i> passed.
  /// This method gives more probability for lower numbers to represent denser interarrival times.
  int getPeakInterarrivalTime(int randomNumber) {
    final Map<bool, int> peakInterarrivalMap = {
      randomNumber < 25: 1,
      25 <= randomNumber && randomNumber < 55: 2,
      55 <= randomNumber && randomNumber < 75: 3,
      75 <= randomNumber && randomNumber < 85: 4,
      85 <= randomNumber && randomNumber < 90: 5,
      90 <= randomNumber && randomNumber < 98: 6,
      98 <= randomNumber: 7,
    };
    // final Map<bool, int> peakInterarrivalMap = {
    //   randomNumber < 10: 1,
    //   10 <= randomNumber && randomNumber < 26: 2,
    //   26 <= randomNumber && randomNumber < 46: 3,
    //   46 <= randomNumber && randomNumber < 66: 4,
    //   66 <= randomNumber && randomNumber < 81: 5,
    //   81 <= randomNumber && randomNumber < 91: 6,
    //   91 <= randomNumber && randomNumber < 98: 7,
    //   98 <= randomNumber: 8,
    // };

    final result = peakInterarrivalMap[true] as int;

    // adding another tally for the result
    var count = allCounter[result] as int;
    count++;
    allCounter[result] = count;

    count = peakCounter[result] as int;
    count++;
    peakCounter[result] = count;

    return result;
  }

  /// Generate and set new arrivals data.
  /// Will print data to console if <i>printData</i> is <code>true</code>.
  /// The data will be generated based on the <i>seed</i>.
  void generateNewArrivalData({bool printData = false, int? seed}) {
    _reset();

    final random = Random(seed);

    int interarrivalTime = 0;
    int arrivalTime = 0;

    // Simulates arrivals of customers to the supermarket
    // This data will be used in the minute-to-minute simulation later on
    do {
      //      12:00 - 13:00  -->  peak I                 17:30 - 20:30  -->  peak II
      if (TimedEvents.isPeakTime(currentMinute: arrivalTime, isNormalizedTime: false)) {
        // During peak times the arrivals are denser
        interarrivalTime = getPeakInterarrivalTime(random.nextInt(100));
        arrivalTime += interarrivalTime;
        peakInterarrivalTimes.add(interarrivalTime);
        _peakArrivalTimes.add(arrivalTime);
      } else {
        // During normal times the arrivals are more spread out
        interarrivalTime = getInterarrivalTime(random.nextInt(100));
        arrivalTime += interarrivalTime;
        normalInterarrivalTimes.add(interarrivalTime);
        _normalArrivalTimes.add(arrivalTime);
      }

      allInterarrivalTimes.add(interarrivalTime);
      _allArrivalTimes.add(arrivalTime);
      _incrementCustomerPerHour(arrivalTime: arrivalTime);
    } while (_allArrivalTimes.last < TimedEvents.openHours.endTime - 480 - 10);

    if (printData) printArrivalData();
  }

  /// Clears and resets all lists and maps.
  void _reset() {
    allInterarrivalTimes.clear();
    normalInterarrivalTimes.clear();
    peakInterarrivalTimes.clear();
    _allArrivalTimes.clear();
    _normalArrivalTimes.clear();
    _peakArrivalTimes.clear();

    for (var i = 1; i <= 8; i++) {
      allCounter[i] = 0;
      normalCounter[i] = 0;
      peakCounter[i] = 0;
    }

    for (var i = 8; i < 22; i++) {
      customersPerHourCounter[i] = 0;
    }
  }

  void printArrivalData({bool printLists = false}) {
    final arrivalsCount = _allArrivalTimes.length;
    final normalArrivalsCount = _normalArrivalTimes.length;
    final peakArrivalsCount = _peakArrivalTimes.length;

    print('---------------------------------------------------------------------------');

    print('Normal - total hours ratio:  10/14  \t --> \t ${Helpers.toPercentage(14, 10)}');
    print('Peak - total hours ratio:     4/14  \t --> \t ${Helpers.toPercentage(14, 4)}');
    print(
      'Normal - total hours arrival number ratio: $normalArrivalsCount/$arrivalsCount  \t --> \t ${Helpers.toPercentage(arrivalsCount, normalArrivalsCount)}',
    );
    print(
      'Peak - total hours arrival number ratio:   $peakArrivalsCount/$arrivalsCount  \t --> \t ${Helpers.toPercentage(arrivalsCount, peakArrivalsCount)}',
    );

    print('---------------------------------------------------------------------------');

    print('Total interarrival time distributions: ');
    for (var i = 1; i <= 8; i++) {
      print(
        '$i minute: ${allCounter[i]}/$arrivalsCount  \t --> \t ${Helpers.toPercentage(arrivalsCount, allCounter[i])}',
      );
    }

    print('---------------------------------------------------------------------------');

    print('Normal interarrival time distributions: ');
    for (var i = 1; i <= 8; i++) {
      print(
        '$i minute: ${normalCounter[i]}/$normalArrivalsCount  \t --> \t ${Helpers.toPercentage(normalArrivalsCount, normalCounter[i])}',
      );
    }

    print('---------------------------------------------------------------------------');

    print('Peak interarrival time distributions: ');
    for (var i = 1; i <= 8; i++) {
      print(
        '$i minute: ${peakCounter[i]}/$peakArrivalsCount  \t --> \t ${Helpers.toPercentage(peakArrivalsCount, peakCounter[i])}',
      );
    }

    print('---------------------------------------------------------------------------');

    print('Customers per hour distributions: ');
    for (var i = 8; i < 22; i++) {
      print('$i:00 - ${i + 1}:00 --> ${customersPerHourCounter[i]} customers');
    }

    print('---------------------------------------------------------------------------');

    print('Total number of arrivals: ');
    print(_allArrivalTimes.length);

    if (printLists) {
      print('Chronologically ordered interarrival times: ');
      print(allInterarrivalTimes);

      print('Customer arrival times: ');
      print(_allArrivalTimes);

      print('---------------------------------------------------------------------------');
    }

    print('Number of arrivals during normal hours: ');
    print(_normalArrivalTimes.length);

    if (printLists) {
      print('Chronologically ordered interarrival times during normal hours: ');
      print(normalInterarrivalTimes);

      print('Customer arrival times during normal hours: ');
      print(_normalArrivalTimes);

      print('---------------------------------------------------------------------------');
    }

    print('Number of arrivals during peak hours: ');
    print(_peakArrivalTimes.length);

    if (printLists) {
      print('Chronologically ordered interarrival times during peak hours: ');
      print(peakInterarrivalTimes);

      print('Customer arrival times during peak hours: ');
      print(_peakArrivalTimes);
    }

    print('---------------------------------------------------------------------------');
  }

  /// Increments counter for customers per hour map.
  /// <i>isNormalized</i> tells the function if it should shift the arrival time by 480.
  /// If it is <code>true</code> that means the parameter is normalized and should NOT be shifted.
  void _incrementCustomerPerHour({required int arrivalTime, bool isNormalized = false}) {
    arrivalTime += isNormalized ? 0 : 480;

    final hour = (arrivalTime) ~/ 60;

    var customerCount = customersPerHourCounter[hour] ?? 0;

    customerCount++;

    customersPerHourCounter[hour] = customerCount;
  }
}

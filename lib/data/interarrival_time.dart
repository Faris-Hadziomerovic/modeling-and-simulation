import 'dart:math';

import '../other/helpers.dart';
import 'timed_events.dart';

class ArrivalData {
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
      randomNumber < 3: 1,
      3 <= randomNumber && randomNumber < 10: 2,
      10 <= randomNumber && randomNumber < 21: 3,
      21 <= randomNumber && randomNumber < 35: 4,
      35 <= randomNumber && randomNumber < 50: 5,
      50 <= randomNumber && randomNumber < 75: 6,
      75 <= randomNumber && randomNumber < 90: 7,
      90 <= randomNumber: 8,
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
      randomNumber < 10: 1,
      10 <= randomNumber && randomNumber < 26: 2,
      26 <= randomNumber && randomNumber < 46: 3,
      46 <= randomNumber && randomNumber < 66: 4,
      66 <= randomNumber && randomNumber < 81: 5,
      81 <= randomNumber && randomNumber < 91: 6,
      91 <= randomNumber && randomNumber < 98: 7,
      98 <= randomNumber: 8,
    };

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
    } while (_allArrivalTimes.last < TimedEvents.openHours.endTime - 480);

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
  }

  void printArrivalData() {
    final arrivalsCount = _allArrivalTimes.length;
    final normalArrivalsCount = _normalArrivalTimes.length;
    final peakArrivalsCount = _peakArrivalTimes.length;

    print('\n-----------------------------------------------------\n');

    print('Normal - total hours ratio:  10/14  \t --> \t ${Helpers.toPercentage(14, 10)}');
    print('Peak - total hours ratio:     4/14  \t --> \t ${Helpers.toPercentage(14, 4)}');
    print(
      'Normal - total hours arrival number ratio: $normalArrivalsCount/$arrivalsCount  \t --> \t ${Helpers.toPercentage(arrivalsCount, normalArrivalsCount)}',
    );
    print(
      'Peak - total hours arrival number ratio:   $peakArrivalsCount/$arrivalsCount  \t --> \t ${Helpers.toPercentage(arrivalsCount, peakArrivalsCount)}',
    );

    print('\n-----------------------------------------------------\n');

    print('Total interarrival time distributions: ');
    for (var i = 1; i <= 8; i++) {
      print(
        '$i minute: ${allCounter[i]}/$arrivalsCount  \t --> \t ${Helpers.toPercentage(arrivalsCount, allCounter[i])}',
      );
    }

    print('\n-----------------------------------------------------\n');

    print('Normal interarrival time distributions: ');
    for (var i = 1; i <= 8; i++) {
      print(
        '$i minute: ${normalCounter[i]}/$normalArrivalsCount  \t --> \t ${Helpers.toPercentage(normalArrivalsCount, normalCounter[i])}',
      );
    }

    print('\n-----------------------------------------------------\n');

    print('Peak interarrival time distributions: ');
    for (var i = 1; i <= 8; i++) {
      print(
        '$i minute: ${peakCounter[i]}/$peakArrivalsCount  \t --> \t ${Helpers.toPercentage(peakArrivalsCount, peakCounter[i])}',
      );
    }

    print('\n-----------------------------------------------------\n');

    print('Total number of arrivals: ');
    print(_allArrivalTimes.length);

    print('Chronologically ordered interarrival times: ');
    print(allInterarrivalTimes);

    print('Customer arrival times: ');
    print(_allArrivalTimes);

    print('\n-----------------------------------------------------\n');

    print('Number of arrivals during normal hours: ');
    print(_normalArrivalTimes.length);

    print('Chronologically ordered interarrival times during normal hours: ');
    print(normalInterarrivalTimes);

    print('Customer arrival times during normal hours: ');
    print(_normalArrivalTimes);

    print('\n-----------------------------------------------------\n');

    print('Number of arrivals during peak hours: ');
    print(_peakArrivalTimes.length);

    print('Chronologically ordered interarrival times during peak hours: ');
    print(peakInterarrivalTimes);

    print('Customer arrival times during peak hours: ');
    print(_peakArrivalTimes);
  }
}

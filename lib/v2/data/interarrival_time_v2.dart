import 'dart:math';

import '../constants/general_constants.dart';
import '../constants/timed_events.dart';
import '../other/helpers.dart';

/// This class generates customer arrival (at the dicision point) data.
///
/// <b> TODO: Modify to generate full [CustomerV2] in the final map.
/// Maybe generate them now via a distribution function? </b>
class ArrivalDataV2 {
  // The lists hold the data on when to spawn a customer at the decision point.
  final _allArrivalTimes = <Duration>[];

  // Do we keep these?
  // These are sort of made for testing how the distributions work, they seem unnecessary in the grand scheme of things.
  final _normalArrivalTimes = <Duration>[];
  final _peakArrivalTimes = <Duration>[];

  final allInterarrivalTimes = <Duration>[];
  final normalInterarrivalTimes = <Duration>[];
  final peakInterarrivalTimes = <Duration>[];

  // The following maps are there for testing how the distributions are executed.
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
  Map<int, int> allCounter = {};
  Map<int, int> normalCounter = {};
  Map<int, int> peakCounter = {};

  // -----------------------------------------------------------------------------------------------------------------------------
  // GETTERS ARE BELOW
  // -----------------------------------------------------------------------------------------------------------------------------

  int get numberOfArrivals => _allArrivalTimes.length;
  int get numberOfNormalArrivals => _normalArrivalTimes.length;
  int get numberOfPeakArrivals => _peakArrivalTimes.length;

  /// The time at which customers arrive at the decision point (and at which they spawn).
  List<Duration> get arrivalTimes => _allArrivalTimes;
  List<Duration> get normalArrivalTimes => _normalArrivalTimes;
  List<Duration> get peakArrivalTimes => _peakArrivalTimes;

  /// The time in seconds at which customers arrive at the decision point (and at which they spawn).
  List<int> get arrivalTimesInSeconds => _allArrivalTimes.map((time) => time.inSeconds).toList();

  //
  //
  //
  // ////////////////////////////////////////////////////////////////
  //
  //
  //

  /// Generates new arrival data that can be found in the [arrivalTimes] property.
  ///
  /// If the [seed] argument is `null` then the generated data will be randomly generated, but if it's provided then
  /// the data will be generated based on the seed which will be the same every time the exact seed is used.
  /// Use it to fine tune the system.
  ArrivalDataV2({bool printData = false, int? seed}) {
    generateNewArrivalData(seed: seed, shouldPrintData: printData);
  }

  /// Generate and set new arrivals data.
  ///
  /// The data will be generated based on the [seed].
  void generateNewArrivalData({int? seed, bool shouldPrintData = false}) {
    reset();

    final random = Random(seed);

    Duration interarrivalTime = Duration.zero;
    Duration arrivalTime = TimedEvents.openHours.startTime;

    // Simulates arrivals of customers to the supermarket.
    // This data will be used in the second-to-second simulation later on...
    var startTime = TimedEvents.openHours.startTime;
    var endTime = TimedEvents.openHours.endTime;

    for (var time = startTime; time < endTime - Time.tenMinutes;) {
      // //      12:00 - 13:00  -->  peak I                 17:30 - 20:30  -->  peak II
      if (TimedEvents.isPeakTime(currentTime: time)) {
        // During peak times the arrivals are denser
        interarrivalTime = getPeakInterarrivalTime(rng: random);

        arrivalTime += interarrivalTime;
        peakInterarrivalTimes.add(interarrivalTime);
        _peakArrivalTimes.add(arrivalTime);
      } else {
        // During normal times the arrivals are more spread out
        interarrivalTime = getInterarrivalTime(rng: random);

        arrivalTime += interarrivalTime;
        normalInterarrivalTimes.add(interarrivalTime);
        _normalArrivalTimes.add(arrivalTime);
      }

      allInterarrivalTimes.add(interarrivalTime);
      _incrementCustomerPerHour(arrivalTime: arrivalTime);

      _allArrivalTimes.add(arrivalTime);

      time += interarrivalTime;
    }

    if (shouldPrintData) printData();
  }

  /// Clears and resets all lists and maps.
  void reset() {
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

  /// Generates an interarrival period between customers.
  ///
  /// The [randomNumber] for now represents the minimim possible value in seconds, it defaults to `30`.
  ///
  /// The [rng] if not `null` will be used instead of a new random number generator. Use for fine-tuning the system.
  Duration getInterarrivalTime({int? randomNumber, Random? rng}) {
    var numberOfSeconds = (rng ?? Random()).nextInt(150) + (randomNumber ?? 30);
    return Duration(seconds: numberOfSeconds);
  }

  /// Generates an interarrival period between customers.
  ///
  /// This gives a bit denser periods.
  ///
  /// The [randomNumber] for now represents the minimim possible value in seconds, it defaults to `30`.
  ///
  /// The [rng] if not `null` will be used instead of a new random number generator. Use for fine-tuning the system.
  Duration getPeakInterarrivalTime({int? randomNumber, Random? rng}) {
    var numberOfSeconds = (rng ?? Random()).nextInt(100) + (randomNumber ?? 30);
    return Duration(seconds: numberOfSeconds);
  }

  /// Increments counter for customers per hour map.
  void _incrementCustomerPerHour({required Duration arrivalTime}) {
    final hour = arrivalTime.inHours;

    var customerCount = customersPerHourCounter[hour] ?? 0;

    customerCount++;

    customersPerHourCounter[hour] = customerCount;
  }

  /// Formats and joins all arrival times to a [csv] ready format.
  ///
  /// If the [separator] isn't provided then a default comma (`,`) will be used.
  String getCsvArrivalTimes([String? separator]) {
    final _formattedArrivalTimes = _allArrivalTimes.map((e) => Helpers.durationToString(e)).toList();

    return _formattedArrivalTimes.join(separator ?? ',');
  }

  /// Formats and joins all arrival times to a [csv] ready format.
  ///
  /// If the [separator] isn't provided then a default comma (`,`) will be used.
  String getCsvArrivalTimesInSeconds([String? separator]) {
    return arrivalTimesInSeconds.join(separator ?? ',');
  }

  /// This returns a string in a [csv] ready form. <br>
  String toCsv() {
    return 'All arrival times,${getCsvArrivalTimes()}\n'
        'All arrival times in seconds,${getCsvArrivalTimesInSeconds()}\n'
        'Total number of arrivals,$numberOfArrivals\n,'
        'Number of normal arrivals,$numberOfNormalArrivals\n,'
        'Number of peak time arrivals,$numberOfPeakArrivals\n,';
  }

  /// Prints important data to the console.
  ///
  /// Used for testing and fine-tuning the system.
  void printData({bool printLists = false}) {
    print('Customers per hour distributions: ');

    for (var i = 8; i < 22; i++) {
      print('$i:00 - ${i + 1}:00 --> ${customersPerHourCounter[i]} customers');
    }

    print('---------------------------------------------------------------------------');

    print('Total number of arrivals: ');
    print(_allArrivalTimes.length);

    if (printLists) {
      print('Chronologically ordered interarrival times: ');
      print(allInterarrivalTimes.map((e) => Helpers.durationToString(e)).toList());

      print('Customer arrival times: ');
      print(_allArrivalTimes.map((e) => Helpers.durationToString(e)).toList());

      print('---------------------------------------------------------------------------');
    }

    print('Number of arrivals during normal hours: ');
    print(_normalArrivalTimes.length);

    if (printLists) {
      print('Chronologically ordered interarrival times during normal hours: ');
      print(normalInterarrivalTimes.map((e) => Helpers.durationToString(e)).toList());

      print('Customer arrival times during normal hours: ');
      print(_normalArrivalTimes.map((e) => Helpers.durationToString(e)).toList());

      print('---------------------------------------------------------------------------');
    }

    print('Number of arrivals during peak hours: ');
    print(_peakArrivalTimes.length);

    if (printLists) {
      print('Chronologically ordered interarrival times during peak hours: ');
      print(peakInterarrivalTimes.map((e) => Helpers.durationToString(e)).toList());

      print('Customer arrival times during peak hours: ');
      print(_peakArrivalTimes.map((e) => Helpers.durationToString(e)).toList());
    }

    print('---------------------------------------------------------------------------');
  }

  //
  //
  //
  //
  //
  //
  //
  //
  //
  //
  // -----------------------------------------------------------------------------------------------------------------------------

  // DEPRECATED METHODS BELOW
  // If the need arises to fine tune the interarrival time probabilities then go ahead and modify them.
  // Also a printing method is located here, but it seems like a headache to fix it. Leaving it here just in case.

  // -----------------------------------------------------------------------------------------------------------------------------
  //
  //
  //
  //
  //
  //

  @deprecated

  /// Prints statistics in a human-readable way.
  ///
  /// <b> TODO: Make another method that will save this information to a [.csv] file </b>
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

  @deprecated

  /// This is deprecated! Use [getInterarrivalTime] instead.
  ///
  /// Returns an [int] representing number of seconds between arrivals based on the [randomNumber] passed.
  int getInterarrivalTimeInSeconds(int randomNumber) {
    final Map<bool, int> interarrivalMap = {
      randomNumber < 5: 20,
      5 <= randomNumber && randomNumber < 20: 40,
      20 <= randomNumber && randomNumber < 40: 60,
      40 <= randomNumber && randomNumber < 60: 80,
      60 <= randomNumber && randomNumber < 80: 100,
      80 <= randomNumber && randomNumber < 95: 140,
      95 <= randomNumber: 180,
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

  @deprecated

  /// This is deprecated! Use [getPeakInterarrivalTime] instead.
  ///
  /// Returns an [int] representing number of seconds between arrivals based on the [randomNumber] passed.
  ///
  /// This method gives more probability for lower numbers to represent denser interarrival times.
  int getPeakInterarrivalTimeInSeconds(int randomNumber) {
    final Map<bool, int> peakInterarrivalMap = {
      randomNumber < 30: 30,
      30 <= randomNumber && randomNumber < 55: 60,
      55 <= randomNumber && randomNumber < 75: 100,
      75 <= randomNumber && randomNumber < 90: 120,
      90 <= randomNumber: 150,
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
}

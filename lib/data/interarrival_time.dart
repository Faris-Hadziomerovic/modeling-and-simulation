import 'dart:math';

import '../constants/arrival_constants.dart';

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

Map<String, List<int>> getArrivalData({bool printData = false}) {
  final random = Random();
  final allInterarrivalTimes = <int>[];
  final normalInterarrivalTimes = <int>[];
  final peakInterarrivalTimes = <int>[];

  final allArrivalTimes = <int>[];
  final normalArrivalTimes = <int>[];
  final peakArrivalTimes = <int>[];

  int interarrivalTime = 0;
  int arrivalTime = 0;

  // simulates arrivals of customers to the supermarket
  // this data will be used in the minute-to-minute simulation later
  do {
    //      12:00 - 13:00  -->  peak I                 17:30 - 20:30  -->  peak II
    if (240 <= arrivalTime && arrivalTime < 300 || 570 <= arrivalTime && arrivalTime < 750) {
      interarrivalTime = getPeakInterarrivalTime(random.nextInt(100));
      arrivalTime += interarrivalTime;
      peakInterarrivalTimes.add(interarrivalTime);
      peakArrivalTimes.add(arrivalTime);
    } else {
      interarrivalTime = getInterarrivalTime(random.nextInt(100));
      arrivalTime += interarrivalTime;
      normalInterarrivalTimes.add(interarrivalTime);
      normalArrivalTimes.add(arrivalTime);
    }

    allInterarrivalTimes.add(interarrivalTime);
    allArrivalTimes.add(arrivalTime);
  } while (allArrivalTimes.last < 830);

  if (printData) {
    printArrivalData(
      // allArrivalTimes: allArrivalTimes,
      // normalArrivalTimes: normalArrivalTimes,
      // peakArrivalTimes: peakArrivalTimes,
      allArrivalTimes: allArrivalTimes.map((e) => e + 480).toList(),
      normalArrivalTimes: normalArrivalTimes.map((e) => e + 480).toList(),
      peakArrivalTimes: peakArrivalTimes.map((e) => e + 480).toList(),
      allInterarrivalTimes: allInterarrivalTimes,
      normalInterarrivalTimes: normalInterarrivalTimes,
      peakInterarrivalTimes: peakInterarrivalTimes,
    );
  }

  final normalizedArrivalTimes = allArrivalTimes.map((e) => e + 480).toList();
  final normalizedNormalArrivalTimes = normalArrivalTimes.map((e) => e + 480).toList();
  final normalizedPeakArrivalTimes = peakArrivalTimes.map((e) => e + 480).toList();

  return {
    Arrival.allTimes: allArrivalTimes,
    Arrival.normalTimes: normalArrivalTimes,
    Arrival.peakTimes: peakArrivalTimes,
    Arrival.normalizedTimes: normalizedArrivalTimes,
    Arrival.normalizedNormalTimes: normalizedNormalArrivalTimes,
    Arrival.normalizedPeakTimes: normalizedPeakArrivalTimes,
    Arrival.allInterarrivalTimes: allInterarrivalTimes,
    Arrival.normalInterarrivalTimes: normalInterarrivalTimes,
    Arrival.peakInterarrivalTimes: peakInterarrivalTimes,
  };
}

String toPercentage(num total, num? part) {
  if (part == null) return '0 %';
  return '${(part / total * 100).toStringAsFixed(2)} %';
}

void printArrivalData({
  required List<int> allArrivalTimes,
  required List<int> allInterarrivalTimes,
  required List<int> normalArrivalTimes,
  required List<int> normalInterarrivalTimes,
  required List<int> peakArrivalTimes,
  required List<int> peakInterarrivalTimes,
}) {
  final arrivalsCount = allArrivalTimes.length;
  final normalArrivalsCount = normalArrivalTimes.length;
  final peakArrivalsCount = peakArrivalTimes.length;

  print('\n-----------------------------------------------------\n');

  print('Normal - total hours ratio:  10/14  \t --> \t ${toPercentage(14, 10)}');
  print('Peak - total hours ratio:     4/14  \t --> \t ${toPercentage(14, 4)}');
  print(
    'Normal - total hours arrival number ratio: $normalArrivalsCount/$arrivalsCount  \t --> \t ${toPercentage(arrivalsCount, normalArrivalsCount)}',
  );
  print(
    'Peak - total hours arrival number ratio:   $peakArrivalsCount/$arrivalsCount  \t --> \t ${toPercentage(arrivalsCount, peakArrivalsCount)}',
  );

  print('\n-----------------------------------------------------\n');

  print('Total interarrival time distributions: ');
  for (var i = 1; i <= 8; i++) {
    print(
      '$i minute: ${allCounter[i]}/$arrivalsCount  \t --> \t ${toPercentage(arrivalsCount, allCounter[i])}',
    );
  }

  print('\n-----------------------------------------------------\n');

  print('Normal interarrival time distributions: ');
  for (var i = 1; i <= 8; i++) {
    print(
      '$i minute: ${normalCounter[i]}/$normalArrivalsCount  \t --> \t ${toPercentage(normalArrivalsCount, normalCounter[i])}',
    );
  }

  print('\n-----------------------------------------------------\n');

  print('Peak interarrival time distributions: ');
  for (var i = 1; i <= 8; i++) {
    print(
      '$i minute: ${peakCounter[i]}/$peakArrivalsCount  \t --> \t ${toPercentage(peakArrivalsCount, peakCounter[i])}',
    );
  }

  print('\n-----------------------------------------------------\n');

  print('Total number of arrivals: ');
  print(allArrivalTimes.length);

  print('Chronologically ordered interarrival times: ');
  print(allInterarrivalTimes);

  print('Customer arrival times: ');
  print(allArrivalTimes);

  print('\n-----------------------------------------------------\n');

  print('Number of arrivals during normal hours: ');
  print(normalArrivalTimes.length);

  print('Chronologically ordered interarrival times during normal hours: ');
  print(normalInterarrivalTimes);

  print('Customer arrival times during normal hours: ');
  print(normalArrivalTimes);

  print('\n-----------------------------------------------------\n');

  print('Number of arrivals during peak hours: ');
  print(peakArrivalTimes.length);

  print('Chronologically ordered interarrival times during peak hours: ');
  print(peakInterarrivalTimes);

  print('Customer arrival times during peak hours: ');
  print(peakArrivalTimes);
}

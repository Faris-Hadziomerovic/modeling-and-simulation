import '../other/helpers.dart';

class ServiceTimeData {
  static Map<int, int> _serviceTimeDistributionMap = {
    1: 0,
    2: 0,
    3: 0,
    4: 0,
    5: 0,
    6: 0,
    7: 0,
    8: 0,
  };

  static Map<int, int> get serviceTimeDistributionMap => {..._serviceTimeDistributionMap};
  static int get serviceTimesGenerated {
    return _serviceTimeDistributionMap.entries.fold(0, (previousValue, mapEntry) => previousValue + mapEntry.value);
  }

  /// this is for Baker, the others will get a modifier (John +10, Able -10)
  static int getServiceTime(int randomNum) {
    final Map<bool, int> switchMap = {
      randomNum < 2: 1,
      2 <= randomNum && randomNum < 15: 2,
      15 <= randomNum && randomNum < 30: 3,
      30 <= randomNum && randomNum < 60: 4,
      60 <= randomNum && randomNum < 75: 5,
      75 <= randomNum && randomNum < 88: 6,
      88 <= randomNum && randomNum < 98: 7,
      98 <= randomNum: 8,
    };

    final result = switchMap[true] as int;

    // adding another tally for the result
    var count = _serviceTimeDistributionMap[result] as int;
    count++;
    _serviceTimeDistributionMap[result] = count;

    return result;
  }

  static void printDistributionData() {
    print('Service time distributions: ');
    final totalServiceTimes = serviceTimesGenerated;
    for (var i = 1; i <= 8; i++) {
      final percentage = Helpers.toPercentage(totalServiceTimes, _serviceTimeDistributionMap[i]);
      print('$i minute: ${_serviceTimeDistributionMap[i]}/$totalServiceTimes  \t --> \t $percentage');
    }
  }
}

// OLD MAP
// final Map<bool, int> switchMap = {
//   randomNum < 25: 1,
//   25 <= randomNum && randomNum < 47: 2,
//   47 <= randomNum && randomNum < 65: 3,
//   65 <= randomNum && randomNum < 79: 4,
//   79 <= randomNum && randomNum < 89: 5,
//   89 <= randomNum && randomNum < 95: 6,
//   95 <= randomNum && randomNum < 98: 7,
//   98 <= randomNum: 8,
// };
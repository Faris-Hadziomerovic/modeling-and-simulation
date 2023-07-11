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

  /// Gets the map of generated service time distributions. Used for statistics.
  static Map<int, int> get serviceTimeDistributionMap => {..._serviceTimeDistributionMap};

  /// Gets the total number of generated service times. Used for statistics.
  static int get totalServiceTimesGenerated {
    return _serviceTimeDistributionMap.entries.fold(0, (previousValue, mapEntry) => previousValue + mapEntry.value);
  }

  /// Generates a service time based on the passed <i>randomNum</i>.  <br>
  /// Expected range: <code> 0 - 100 </code> <br>
  static int getServiceTime(int randomNum) {
    // This base table is for Baker, the others should pass the speed bonus penalty modifier.
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

  /// Prints the service times distribution map in a human-readable format.
  static void printDistributionData() {
    print('Service time distributions: ');
    final totalServiceTimes = totalServiceTimesGenerated;
    for (var i = 1; i <= 8; i++) {
      final percentage = Helpers.toPercentage(totalServiceTimes, _serviceTimeDistributionMap[i]);
      print('$i minute: ${_serviceTimeDistributionMap[i]}/$totalServiceTimes  \t --> \t $percentage');
    }
  }
}

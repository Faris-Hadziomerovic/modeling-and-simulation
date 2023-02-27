Map<int, int> counter = {
  1: 0,
  2: 0,
  3: 0,
  4: 0,
  5: 0,
  6: 0,
  7: 0,
  8: 0,
};

// this is for Baker, the others will get a modifier (John +, Able -)
int getServiceTime(int randomNum) {
  final Map<bool, int> switchMap = {
    randomNum < 25: 1,
    25 <= randomNum && randomNum < 47: 2,
    47 <= randomNum && randomNum < 65: 3,
    65 <= randomNum && randomNum < 79: 4,
    79 <= randomNum && randomNum < 89: 5,
    89 <= randomNum && randomNum < 95: 6,
    95 <= randomNum && randomNum < 98: 7,
    98 <= randomNum: 8,
  };

  final result = switchMap[true] as int;

  // adding another tally for the result
  var count = counter[result] as int;
  count++;
  counter[result] = count;

  return result;
}

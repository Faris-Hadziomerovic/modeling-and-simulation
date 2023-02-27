import 'dart:math';

void temp() {
  // int crashCount = 0;
  int helpRequestCount = 0;
  int nothingCount = 0;
  int randomNumber = 0;

  for (var i = 0; i < 900; i++) {
    if (i % 4 != 0) continue;

    randomNumber = Random().nextInt(900);
    print(randomNumber);

    switch (getEvent(randomNumber)) {
      case 'Request help':
        helpRequestCount++;
        break;
      default:
        nothingCount++;
    }
  }

  // print('Crash: $crashCount/200');
  print('Request help: $helpRequestCount/900');
  print('Nothing: $nothingCount/900');
}

String getEvent(int random_number) {
  Map<bool, String> switchMap = {
    // 0 <= random_number && random_number <= 15: "Crash",
    0 <= random_number && random_number <= 2: "Request help",
    1 < random_number && random_number <= 900: "Nothing"
  };

  return switchMap[true]!;
}

import './data/interarrival_time.dart';
import './data/timed_events.dart';
import './data/workers.dart';
import './model/customer.dart';
import './model/queue.dart';
import './model/worker.dart';

void main() {
  final workers = Workers();

  final queue = CustomerQueue();

  final arrivalData = ArrivalData();

  final arrivalsMap = arrivalData.arrivalTimes.asMap().map(
        (key, value) => MapEntry(
          value,
          Customer(arrivalTime: value, ordinalNumber: key + 1),
        ),
      );

  eventLoop(
    workers: workers,
    queue: queue,
    arrivalsMap: arrivalsMap,
  );

  queue.printStatistics();
  workers.printStatistics();
}

void eventLoop({
  required Workers workers,
  required CustomerQueue queue,
  required Map<int, Customer> arrivalsMap,
  bool generateHelpEvent = false,
  bool generateCrashEvent = false,
}) {
  final John = workers.John;
  final Baker = workers.Baker;
  final Able = workers.Able;

  Customer? customer;

  //    8:00 - 22:00  |  480 - 1320
  for (var i = TimedEvents.openHours.startTime; i <= TimedEvents.openHours.endTime; i++) {
    workers.synchronizeTime(currentMinute: i);

    customer = arrivalsMap[i];

    if (customer != null) {
      // adds customer at the end of the queue
      queue.add(customer, currentMinute: i);
    }

    queue.recordQueueLength();

    if (Able.isWorking(i)) {
      doWork(
        worker: Able,
        currentMinute: i,
        queue: queue,
      );
    }

    if (Baker.isWorking(i)) {
      doWork(
        worker: Baker,
        currentMinute: i,
        queue: queue,
      );
    }

    if (John.isWorking(i)) {
      doWork(
        worker: John,
        currentMinute: i,
        queue: queue,
      );
    }
  }
}

void doWork({
  required Worker worker,
  required int currentMinute,
  required CustomerQueue queue,
}) {
  if (worker.isNotBusy) {
    if (queue.isNotEmpty) {
      worker.assignCustomer(
        currentMinute: currentMinute,
        printUpdate: true,
      );
      queue.remove(
        currentMinute: currentMinute,
        printUpdates: false,
      );
    } else {
      worker.incrementIdleTime();
    }
  } else {
    worker.incrementBusyTime();
  }
}


// opens:    8:00  |  480 |   0
// closes:  22:00  | 1320 | 840

// John works for   6 h  (8:00 - 14:00)   |  time per service (+3)  |
// Baker works for  8 h  (12:00 - 20:00)  |  time per service (0)   |
// Able works for   6 h  (16:00 - 22:00)  |  time per service (-3)  |

//    |       Time      |     Minute    |  Shifted Minutes  |
//    |   8:00 -  9:00  |   480 -  540  |       0 -  60     |      John starts here
//    |   9:00 - 10:00  |   540 -  600  |      60 - 120     |      
//    |  10:00 - 11:00  |   600 -  660  |     120 - 180     |      
//    |  11:00 - 12:00  |   660 -  720  |     180 - 240     |      
//    |  12:00 - 13:00  |   720 -  780  |     240 - 300     |      peak I | Baker starts here
//    |  13:00 - 14:00  |   780 -  840  |     300 - 360     |      John ends here
//    |  14:00 - 15:00  |   840 -  900  |     360 - 420     |      
//    |  15:00 - 16:00  |   900 -  960  |     420 - 480     |      
//    |  16:00 - 17:00  |   960 - 1020  |     480 - 540     |      Able starts here  
//    |  17:00 - 18:00  |  1020 - 1080  |     540 - 600     |    peak II starts (17:30 | 1050 | 570)
//    |  18:00 - 19:00  |  1080 - 1140  |     600 - 660     |      
//    |  19:00 - 20:00  |  1140 - 1200  |     660 - 720     |      Baker ends here
//    |  20:00 - 21:00  |  1200 - 1260  |     720 - 780     |      peak II ends (20:30 | 1230 | 750)
//    |  21:00 - 22:00  |  1260 - 1320  |     780 - 840     |      Able and the simulation ends


// John adds 3 to the random number before getting a service time to simulate him being slower.
// Baker does not have a speed bonus, he is the average.
// Able substracts 3 to the random number before getting a service time to simulate him being faster.

//    |  Service Time (minutes)  |  Probability  |  Cumulative  |      Range     |
//    |             1            |     0.25      |     0.25     |     0  -  24   |
//    |             2            |     0.22      |     0.47     |    25  -  46   |
//    |             3            |     0.18      |     0.65     |    47  -  64   |
//    |             4            |     0.14      |     0.79     |    65  -  78   |
//    |             5            |     0.10      |     0.89     |    79  -  88   |
//    |             6            |     0.06      |     0.95     |    89  -  94   |
//    |             7            |     0.03      |     0.98     |    95  -  97   |
//    |             8            |     0.02      |     1.00     |    98  - 100   |



// Interarrival times during normal hours:

//    |  Interarrival time (minutes)  |  Probability  |  Cumulative  |      Range     |
//    |             1                 |     0.03      |     0.03     |     0  -   2   |
//    |             2                 |     0.07      |     0.10     |     3  -   9   |
//    |             3                 |     0.11      |     0.21     |    10  -  20   |
//    |             4                 |     0.14      |     0.35     |    21  -  34   |
//    |             5                 |     0.15      |     0.50     |    35  -  49   |
//    |             6                 |     0.25      |     0.75     |    50  -  74   |
//    |             7                 |     0.15      |     0.90     |    75  -  89   |
//    |             8                 |     0.10      |     1.00     |    90  - 100   |


// Interarrival times during peak hours (12:00 - 13:00 | 17:30 - 20:30):

//     |  Interarrival time (minutes)  |  Probability  |  Cumulative  |      Range     |
//     |             1                 |     0.10      |     0.10     |     0  -   9   |
//     |             2                 |     0.15      |     0.25     |    10  -  25   |
//     |             3                 |     0.20      |     0.45     |    26  -  45   |
//     |             4                 |     0.20      |     0.65     |    46  -  65   |
//     |             5                 |     0.15      |     0.80     |    66  -  80   |
//     |             6                 |     0.10      |     0.90     |    81  -  90   |
//     |             7                 |     0.07      |     0.97     |    91  -  97   |
//     |             8                 |     0.03      |     1.00     |    98  - 100   |

// final Map<bool, int> interarrivalMap = {
//     randomNumber < 3                          : 1,
//     3 <= randomNumber && randomNumber < 10    : 2,
//     10 <= randomNumber && randomNumber < 21   : 3,
//     21 <= randomNumber && randomNumber < 35   : 4,
//     35 <= randomNumber && randomNumber < 50   : 5,
//     50 <= randomNumber && randomNumber < 75   : 6,
//     75 <= randomNumber && randomNumber < 90   : 7,
//     90 <= randomNumber                        : 8,
//   };


// final Map<bool, int> peakInterarrivalMap = {
//     randomNumber < 10                         : 1,
//     10 <=  randomNumber && randomNumber < 26  : 2,
//     26 <= randomNumber && randomNumber < 46   : 3,
//     46 <= randomNumber && randomNumber < 66   : 4,
//     66 <= randomNumber && randomNumber < 81   : 5,
//     81 <= randomNumber && randomNumber < 91   : 6,
//     91 <= randomNumber && randomNumber < 98   : 7,
//     98 <= randomNumber                        : 8,
//   };
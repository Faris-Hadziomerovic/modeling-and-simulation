import './data/interarrival_time.dart';
import './data/timed_events.dart';
import './data/workers.dart';
import './model/customer.dart';
import './model/queue.dart';
import './model/worker.dart';
import './data/service_time.dart';
import 'data/queues.dart';
import 'model/customer_v2.dart';

void main() {
  final workers = Workers();
  final queues = Queues();

  final queue = CustomerQueue();

  final johnQueue = queues.john;
  final bakerQueue = queues.baker;
  final ableQueue = queues.able;

  final arrivalData = ArrivalData(seed: 100);

  final arrivalsMap = arrivalData.arrivalTimes.asMap().map(
        (key, value) => MapEntry(
          value,
          Customer(arrivalTime: value, ordinalNumber: key + 1),
        ),
      );

  eventLoop(
    workers: workers,
    arrivalsMap: arrivalsMap,
    queue: queue,
  );

  eventLoopV2(
    workers: workers,
    arrivalsMap: arrivalsMap,
    johnQueue: johnQueue,
    bakerQueue: bakerQueue,
    ableQueue: ableQueue,
  );

  arrivalData.printArrivalData();
  ServiceTimeData.printDistributionData();
  queue.printStatistics();
  workers.printStatistics();
}

/// The main event loop of the simulation that runs a loop for every minute of the day and triggers necessary updates.
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

/// Removes a customer from the queue and assignes them to the worker if possible.
/// Updates worker's stats accordingly.
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
        printUpdates: true,
      );
    } else {
      worker.incrementIdleTime();
    }
  } else {
    worker.incrementBusyTime();
  }
}

/// The main event loop of the simulation that runs a loop for every second of the day and triggers necessary updates.
void eventLoopV2({
  required Workers workers,
  required CustomerQueue johnQueue,
  required CustomerQueue bakerQueue,
  required CustomerQueue ableQueue,
  required Map<int, Customer> arrivalsMap,
  bool generateHelpEvent = false,
  bool generateCrashEvent = false,
}) {
  final John = workers.John;
  final Baker = workers.Baker;
  final Able = workers.Able;

  Customer? customer;

  const oneSecond = Duration(seconds: 1);
  final startTime = Duration(minutes: TimedEvents.openHours.startTime);
  final endTime = Duration(minutes: TimedEvents.openHours.endTime);

  //    8:00 - 22:00
  for (var time = startTime; time <= endTime; time += oneSecond) {
    workers.synchronizeTime(currentMinute: time.inMinutes);

    customer = arrivalsMap[time];

    if (customer != null) {
      johnQueue.add(customer, currentMinute: time.inMinutes);
    }

    johnQueue.recordQueueLength();

    if (Able.isWorking(time.inMinutes)) {
      doWork(
        worker: Able,
        currentMinute: time.inMinutes,
        queue: johnQueue,
      );
    }

    if (Baker.isWorking(time.inMinutes)) {
      doWork(
        worker: Baker,
        currentMinute: time.inMinutes,
        queue: johnQueue,
      );
    }

    if (John.isWorking(time.inMinutes)) {
      doWork(
        worker: John,
        currentMinute: time.inMinutes,
        queue: johnQueue,
      );
    }
  }
}

/// Removes a customer from the queue and assignes them to the worker if possible.
/// Updates worker's stats accordingly.
void doWorkV2({
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
        printUpdates: true,
      );
    } else {
      worker.incrementIdleTime();
    }
  } else {
    worker.incrementBusyTime();
  }
}

/// Script for customer to decide what to do.
void decide({required CustomerV2 customer}) {}

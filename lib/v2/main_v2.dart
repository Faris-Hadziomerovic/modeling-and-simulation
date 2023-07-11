import 'dart:math';

import './data/interarrival_time_v2.dart';
import './data/service_time.dart';
import './data/workers_v2.dart';
import './model/customer_v2.dart';
import './model/queue_v2.dart';
import './queues_v2.dart';
import './worker_v2.dart';
import 'constants/general_constants.dart';
import 'constants/timed_events.dart';

void main() {
  // Create
  final workers = WorkersV2();
  final queues = QueuesV2();

  final arrivalData = ArrivalDataV2(seed: 100);

  final arrivalsMap = arrivalData.arrivalTimes.asMap().map(
        (key, value) => MapEntry(
          value.inSeconds,
          CustomerV2(
            // TODO: make this better somehow
            numberOfItemsInCart: Random().nextInt(50),
            arrivalTimeSecond: value.inSeconds,
            // TODO: assign randomly
            mood: 1.0,
            ordinalNumber: key + 1,
          ),
        ),
      );

  eventLoopV2(
    workers: workers,
    arrivalsMap: arrivalsMap,
    queues: queues,
  );

  arrivalData.printArrivalData();
  ServiceTimeData.printDistributionData();
  workers.printStatistics();
}

/// Removes a customer from the queue and assignes them to the worker if possible.
/// Updates worker's stats accordingly.
///
/// <b> TODO: modify to suit new assignment </b>
void doWork({
  required WorkerV2 worker,
  required Duration currentTime,
  required CustomerQueueV2 queue,
  required CustomerV2 customer,
}) {
  if (worker.isNotBusy) {
    if (queue.isNotEmpty) {
      worker.assignCustomer(
        currentTime: currentTime,
        customer: customer,
        printUpdate: true,
      );
      queue.remove(
        currentMinute: currentTime.inMinutes,
        printUpdates: true,
      );
    } else {
      worker.incrementIdleTime();
    }
  } else {
    worker.incrementBusyTime();
  }
}

// -------------------------------------------------------------------------------------------------------------------------------

// -------------------------------------------------------------------------------------------------------------------------------

// -------------------------------------------------------------------------------------------------------------------------------

/// The main event loop of the simulation that runs a loop for every second of the day and triggers necessary updates.
void eventLoopV2({
  required WorkersV2 workers,
  required QueuesV2 queues,
  required Map<int, CustomerV2> arrivalsMap,
  bool generateHelpEvent = false,
  bool generateCrashEvent = false,
}) {
  final john = workers.John;
  final baker = workers.Baker;
  final able = workers.Able;

  final johnQueue = queues.john;
  final bakerQueue = queues.baker;
  final ableQueue = queues.able;

  CustomerV2? customer;

  final startTime = TimedEvents.openHours.startTime;
  final endTime = TimedEvents.openHours.endTime;

  //    8:00 - 22:00
  for (var time = startTime; time <= endTime; time += Time.oneSecond) {
    workers.synchronizeTime(currentTime: time);

    customer = arrivalsMap[time];

    if (customer != null) {
      final decision = decide(
        customer: customer,
      );

      if (decision == Decision.johnQueue) {
        johnQueue.add(customer, currentMinute: time.inMinutes);
      } else if (decision == Decision.bakerQueue) {
        bakerQueue.add(customer, currentMinute: time.inMinutes);
      } else if (decision == Decision.ableQueue) {
        ableQueue.add(customer, currentMinute: time.inMinutes);
      } else {
        // leave queue
        print('The customer has fucking left! Way to go John!');

        continue;
      }
    }

    // johnQueue.recordQueueLength();

    ///  TODO: find a way to make sense of this!
    /// the customer needs to be assigned
    /// if there is no new customer then let them do the work
    /// should this all be in [WorkersV2.synchronizeTime]?
    ///

    if (able.isWorking(time)) {
      doWork(
        worker: able,
        currentTime: time,
        queue: johnQueue,
        customer: customer!,
      );
    }

    if (baker.isWorking(time)) {
      doWork(
        worker: baker,
        currentTime: time,
        queue: johnQueue,
        customer: customer!,
      );
    }

    if (john.isWorking(time)) {
      doWork(
        worker: john,
        currentTime: time,
        queue: johnQueue,
        customer: customer!,
      );
    }
  }
}

// -------------------------------------------------------------------------------------------------------------------------------

// Is this the right place for the methods below?
//
// This is just a sketch of what needs to be done.

// -------------------------------------------------------------------------------------------------------------------------------

/// Possible decisions for the customer.
enum Decision {
  leave,
  johnQueue,
  bakerQueue,
  ableQueue,
}

/// Script for customer to decide what to do.
Decision decide({required CustomerV2 customer}) {
  return Decision.leave;
}

double observeAndCalculateEstimateItemCountInQueue({
  required CustomerQueueV2 queue,
  CustomerV2? customer,
  // mayber for speed?
  WorkerV2? worker,
}) {
  // for each customer take item count and pass through obscure number function

  return 0.0;
}

int obscureItemCount({
  // the higher the number the worse the estimation should be
  required int actualItemCount,
  // how many places the customer is away from the one that counts,
  // the higher the number the worse the estimation should be
  required int customerPlacementFromEstimator,
  // the one who is estimating the count
  required CustomerV2 estimator,
}) {
  return actualItemCount;
}

Duration estimateTime({
  // the higher the number the worse the estimation should be
  required int estimatedItemCount,
  // the one who is estimating the time
  required CustomerV2 estimator,
  CustomerV2? worker,
}) {
  // take estimated item count
  //

  return Duration.zero;
}

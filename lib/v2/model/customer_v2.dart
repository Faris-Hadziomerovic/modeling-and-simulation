// Main part in program!
// TODO: Add observation of queue here
// TODO: Add decide method here

import 'dart:math';

import '../constants/service_time.dart';
import '../other/helpers.dart';
import './worker_v2.dart';
import './queue_v2.dart';

/// Everything should be in seconds or Duration (preferred).
///
/// **Now with items.**
///
/// The documentation of the properties should state what and how things play a part in the simulation.
///
/// TODO: Follow the TODOs and finish what they state.
class CustomerV2 {
  /// The number of items the customer wants to buy.
  ///
  /// It plays a factor in how much the customer is ready to wait to get served.
  ///
  /// Example: <br>
  /// If the customer has `1` or `2` (or something similar) then their [readyToWaitTime] will be shorter and they
  /// shouldn't want to stay in a queue for long, but if they range from `20` to `30` then they should have more patience.
  ///
  /// <br><b> TODO: Define how the number of items affects their ready-to-wait time. </b>
  final int numberOfItemsInCart;

  /// Range from `0` (very bad) to `2` (very good), more realistically ranges from `0.5` to `1.5`.
  ///
  /// Numbers below `1.0` should be very rare, as the customer has a [readyToWaitTime] before they come to decide.
  ///
  /// It plays a factor in how much the calculated estimate time until service can deviate from the
  /// [readyToWaitTime] until service.
  ///
  /// No matter what the mood is if the estimation is equal or less than the [readyToWaitTime] then the customer will stay,
  /// but they should search for the fastest route.
  ///
  /// Example: <br>
  /// If the mood is `1.5` then the customer should tolerate a `+50%` difference between the
  /// [initialReadyToWaitTime] and the estimated time when they get to decide (they can wait longer
  /// than they thought they would wait before they saw the queue).
  ///
  /// In the rare case the mood is below `1.0` then the customer will be annoyed and want a shorter
  /// waiting experience even if they didn't initially expect it.
  ///
  /// <br><b> TODO: Define how the mood affects their ready-to-wait time. <br>
  /// Should it take effect at the decision point to make it more realistic? <br>
  /// Should it be rare to have below `1.0`? Maybe make it just a factor in the [actualReadyToWaitTime]
  /// calculation and not a big deal? </b>
  final double mood;

  /// The chronological order of the customer in the day.
  ///
  /// Do we even need this? Maybe for logging.
  final int ordinalNumber;

  /// The time that the customer is initially ready to wait in a queue until they get served.
  ///
  /// This property is tied to and calculated from [numberOfItemsInCart]. <br>
  /// This property is independent of the [mood] of the customer.
  late final Duration initialReadyToWaitTime;

  /// The actual time that the customer is ready to wait in a queue until they get served.
  ///
  /// This should be a one-time calculated property that factors in the [initialReadyToWaitTime] and the [mood].
  late final Duration actualReadyToWaitTime;

  /// The time when the customer arrives at the decision point.
  final Duration arrivalTime;

  /// Should be set only once, when the customer arrives at the checkout.
  Duration? _serviceTime;

  /// The time how long the worker took to finish the customer's service.
  Duration? get serviceTime => _serviceTime;

  /// Should be set only once, when the customer arrives at the checkout.
  Duration? _queueExitTime;

  /// The time when the customer finally exits the waiting queue and starts being served by a worker.
  Duration? get queueExitTime => _queueExitTime;

  /// Ignore in logging!
  bool get hasExitedQueue => _queueExitTime != null;

  /// Ignore in logging!
  bool get hasNotExitedQueue => !hasExitedQueue;

  /// Should this be a one-time calculated field for later logging?
  /// <br><b> TODO: Define how the ready-to-wait time is calculated. </b>
  Duration get readyToWaitTime {
    // TODO: Define how the ready-to-wait time is calculated
    var _readyToWaitTime = initialReadyToWaitTime;

    return _readyToWaitTime;
  }

  CustomerV2({
    required this.numberOfItemsInCart,
    required this.mood,
    required this.arrivalTime,
    required this.ordinalNumber,
  }) {
    initialReadyToWaitTime = Duration(seconds: numberOfItemsInCart * ServiceTime.secondsPerItem * 4);

    // Can be also calculated at decision (with mood decreasing?)?
    actualReadyToWaitTime = Duration(seconds: (initialReadyToWaitTime.inSeconds * mood).round());
  }

  /// This method finishes the customer's process making them available for logging.
  ///
  /// Sets the customers queue exit time to [currentTime] and the service time to [serviceTime], this can be done only once.
  void exitQueue({
    required Duration currentTime,
    required Duration serviceTime,
  }) {
    if (currentTime < arrivalTime) throw Exception('Customer cannot leave before arrival.');

    if (hasExitedQueue) throw Exception('The customer already exited the queue.');

    _queueExitTime = currentTime;
    _serviceTime = serviceTime;
  }

  /// This method finishes the customer's process earlier by leaving the store without a service.
  ///
  /// It enables logging with a [_queueExitTime] and [_serviceTime] of [Duration.zero] (usually that's impossible).
  void rageQuit({required Duration currentTime}) {
    if (currentTime < arrivalTime) throw Exception('Customer cannot leave before arrival.');

    if (hasExitedQueue) throw Exception('The customer already exited the queue.');

    _queueExitTime = Duration.zero;
    _serviceTime = Duration.zero;
  }

  /// Returns the current or total waiting time of the customer in the queue.
  Duration getWaitingTime({Duration? currentTime}) {
    if (hasExitedQueue)
      return _queueExitTime! - arrivalTime;
    else if (currentTime != null)
      return currentTime - arrivalTime;
    else
      throw Exception('Customer is still waiting, but the current time is unknown.');
  }

  /// This returns a string in a [csv] ready form. <br>
  /// Should only be called after the customer finishes their process. <br>
  ///
  /// If the [hasRageQuitted] variable is `true` then the last two properties should be ignored as they are invalid.
  String toCsv() {
    if (serviceTime == null || queueExitTime == null) return 'Not completed';

    final hasRageQuitted = serviceTime == Duration.zero && queueExitTime == Duration.zero;

    return '$numberOfItemsInCart,'
        '$mood,'
        '$ordinalNumber,'
        '${Helpers.durationToString(initialReadyToWaitTime)},'
        '${Helpers.durationToString(actualReadyToWaitTime)},'
        '${Helpers.durationToString(arrivalTime)},'
        '${hasRageQuitted},'
        '${Helpers.durationToString(queueExitTime! - arrivalTime)},'
        '${Helpers.durationToString(serviceTime!)}\n';
  }

  @override
  String toString() {
    if (serviceTime == null || queueExitTime == null) return 'Not completed';

    final hasRageQuitted = serviceTime == Duration.zero && queueExitTime == Duration.zero;

    return 'Number of cart items: $numberOfItemsInCart \n'
        'Mood: $mood \n'
        'Ordinal number: $ordinalNumber \n'
        'Initial ready to wait time: ${Helpers.durationToString(initialReadyToWaitTime)} \n'
        'Initial ready to wait time: ${Helpers.durationToString(actualReadyToWaitTime)} \n'
        'Arrival time: ${Helpers.durationToString(arrivalTime)} \n'
        'Has rage quitted the queue: ${hasRageQuitted} \n'
        'Waiting time: ${Helpers.durationToString(queueExitTime! - arrivalTime)} \n'
        'Service time: ${Helpers.durationToString(serviceTime!)} \n';
  }

  /// Script for customer to decide what to do.
  Decision decide({
    required CustomerQueueV2 queue,
    WorkerV2? worker,
  }) {
    final estimatedItemCountInQueue = observeAndCalculateEstimateItemCountInQueue(queue: queue);

    final estimatedTimeUntilService = estimateTime(
      estimatedItemCount: estimatedItemCountInQueue,
      worker: worker,
    );

    // TODO: make a decision based on the estimated time,

    return Decision.leave;
  }

  /// Returns the total estimated item count in the observed queue.
  int observeAndCalculateEstimateItemCountInQueue({required CustomerQueueV2 queue}) {
    var totalNumberOfItemsCounted = 0;
    var placementAwayFromObserver = 0;

    for (var customer in queue.queueData.reversed) {
      totalNumberOfItemsCounted += obscureItemCount(
        actualItemCount: customer.numberOfItemsInCart,
        customerPlacementAwayFromObserver: placementAwayFromObserver,
      );

      placementAwayFromObserver++;
    }

    return totalNumberOfItemsCounted;
  }

  /// Simulates human inaccuracy.
  ///
  /// Should give a rough estimate of the actual item count deoending on how close the observed customer is
  /// and how many items they have in their cart.
  ///
  /// The higher the [actualItemCount] the less accurate the estimate should be. <br>
  /// The further the [customerPlacementAwayFromObserver] is, the less acurate the estimate should be.
  ///
  /// TODO: obscure the number with the gaussian thing GPT mentioned!!!
  int obscureItemCount({
    // the higher the number the worse the estimation should be
    required int actualItemCount,
    // how many places the customer is away from the one that counts,
    // the higher the number the worse the estimation should be
    required int customerPlacementAwayFromObserver,
  }) {
    // do calculations here

    // mood factor in all this?!?

    return actualItemCount;
  }

  /// Simulates human inaccuracy.
  ///
  /// Should give a rough estimate of the time it will take to service the observed customer
  /// and how many items they have in their cart.
  Duration estimateTime({
    required int estimatedItemCount,
    WorkerV2? worker,
  }) {
    final workerSpeedFactor = worker?.speedFactor ?? 1.0;

    // Should we add skill based estimation?
    final deviation = Random().nextDouble() * 3;

    final estimatedTimeInSeconds = (estimatedItemCount * deviation * ServiceTime.secondsPerItem * workerSpeedFactor).round();

    return Duration(seconds: estimatedTimeInSeconds);
  }
}

/// Possible decisions for the customer.
enum Decision {
  leave,
  johnQueue,
  bakerQueue,
  ableQueue,
}

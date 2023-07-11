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

  /// The time in seconds when the customer arrives at the decision point.
  final int arrivalTimeSecond;

  /// The time in seconds when the customer finally exits the waiting queue and starts being served by a worker.
  ///
  /// This property should be set only once.
  int? _queueExitTimeSecond;

  int? get queueExitTimeSecond => _queueExitTimeSecond;

  /// The time when the customer arrives at the decision point.
  Duration get arrivalTime => Duration(seconds: arrivalTimeSecond);

  /// The time when the customer finally exits the waiting queue and starts being served by a worker.
  Duration? get queueExitTime => hasNotExitedQueue ? null : Duration(seconds: _queueExitTimeSecond!);

  bool get hasExitedQueue => _queueExitTimeSecond != null;
  bool get hasNotExitedQueue => !hasExitedQueue;

  /// Should this be a one-time calculated field for later logging?
  /// <br><b> TODO: Define how the ready-to-wait time is calculated. </b>
  Duration get readyToWaitTime {
    // TODO: Define how the ready-to-wait time is calculated
    var _readyToWaitTime = initialReadyToWaitTime;

    return _readyToWaitTime;
  }

  /// This is `false` until the customer has left the store. <br>
  /// After the customer leaves nothing more should be operated on them except logging data.
  bool isComplete = false;

  CustomerV2({
    required this.numberOfItemsInCart,
    required this.mood,
    required this.arrivalTimeSecond,
    required this.ordinalNumber,
  });

  /// Sets the customers queue exit time to <i>currentMinute</i>, this can be done only once.
  /// Returns the customer's total waiting time in the queue
  int exitQueue(int currentMinute) {
    if (currentMinute < arrivalTimeSecond) throw Exception('Customer cannot leave before arrival.');

    if (hasNotExitedQueue)
      _queueExitTimeSecond = currentMinute;
    else
      throw Exception('The customer already exited the queue.');

    return getWaitingTime();
  }

  /// Completes the customers process. <br>
  /// Logs the time when the customer's service was completed
  /// Sets the customers queue exit time to <i>currentMinute</i>, this can be done only once.
  /// Returns the customer's total waiting time in the queue
  int complete(int currentSecond) {
    if (currentSecond < arrivalTimeSecond) throw Exception('Customer cannot leave before arrival.');

    if (hasNotExitedQueue)
      _queueExitTimeSecond = currentSecond;
    else
      throw Exception('The customer already exited the queue.');

    isComplete = true;

    return getWaitingTime();
  }

  void guard() => isComplete ? throw Exception('The customer process is completed. No further operations are allowed!') : null;

  int getWaitingTime({int? currentMinute}) {
    if (hasExitedQueue)
      return _queueExitTimeSecond! - arrivalTimeSecond;
    else if (currentMinute != null)
      return currentMinute - arrivalTimeSecond;
    else
      throw Exception('Customer is still waiting, but the current time is unknown.');
  }

  @override
  String toString() {
    return '''{
      Ordinal number: #$ordinalNumber, 
      Arrival time: $arrivalTimeSecond, 
      Queue exit time: ${hasExitedQueue ? _queueExitTimeSecond : 'unknown'}, 
      Waiting time: ${hasExitedQueue ? getWaitingTime() : 'unknown'}  \n}''';
  }
}

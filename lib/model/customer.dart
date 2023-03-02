class Customer {
  final int arrivalTime;
  final int ordinalNumber;
  int? _queueExitTime;

  int? get queueExitTime => _queueExitTime;
  bool get hasExitedQueue => _queueExitTime != null;
  bool get hasNotExitedQueue => !hasExitedQueue;
  int get shiftedArrivalTime => arrivalTime - 480;

  Customer({
    required this.arrivalTime,
    required this.ordinalNumber,
  });

  /// Sets the customers queue exit time to <i>currentMinute</i>, this can be done only once.
  /// Returns the customer's total waiting time in the queue
  int exitQueue(int currentMinute) {
    if (currentMinute < arrivalTime) throw Exception('Customer cannot leave before arrival.');

    if (hasNotExitedQueue)
      _queueExitTime = currentMinute;
    else
      throw Exception('The customer already exited the queue.');

    return getWaitingTime();
  }

  int getWaitingTime({int? currentMinute}) {
    if (hasExitedQueue)
      return _queueExitTime! - arrivalTime;
    else if (currentMinute != null)
      return currentMinute - arrivalTime;
    else
      throw Exception('Customer is still waiting, but the current time is unknown.');
  }

  @override
  String toString() {
    return '''{
      Ordinal number: #$ordinalNumber, 
      Arrival time: $arrivalTime, 
      Queue exit time: ${hasExitedQueue ? _queueExitTime : 'unknown'}, 
      Waiting time: ${hasExitedQueue ? getWaitingTime() : 'unknown'}  \n}''';
  }
}

// Seems unnecessary - ignore.

import '../model/queue_v2.dart';
import '../other/helpers.dart';

/// <b> TODO: Maybe every worker should be assigned a queue instead? </b>
class CustomerQueuesV2 {
  late final CustomerQueueV2 john;
  late final CustomerQueueV2 baker;
  late final CustomerQueueV2 able;

  CustomerQueuesV2({bool useModifiedVersion = false}) {
    john = CustomerQueueV2();

    baker = CustomerQueueV2();

    able = CustomerQueueV2();
  }

  void printStatistics({required Duration currentTime}) {
    print('------------------------------------------------');
    print('Time: ${Helpers.durationToString(currentTime)}');
    print('------------------------------------------------');

    john.printStatistics();
    baker.printStatistics();
    able.printStatistics();
  }
}

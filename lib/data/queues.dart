import '../model/queue.dart';

class Queues {
  late final CustomerQueue john;
  late final CustomerQueue baker;
  late final CustomerQueue able;

  Queues({bool useModifiedVersion = false}) {
    john = CustomerQueue();

    baker = CustomerQueue();

    able = CustomerQueue();
  }

  void printStatistics({required int currentMinute}) {
    print('------------------------------------------------');
    print('Time: $currentMinute minute.');
    print('------------------------------------------------');

    john.printStatistics();
    baker.printStatistics();
    able.printStatistics();
  }
}

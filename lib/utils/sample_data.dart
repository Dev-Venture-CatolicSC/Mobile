import '../models/activity_model.dart';
import '../models/enums.dart';
import '../models/user_model.dart';

class SampleData {
  static const demoUserId = 'demo-user-g4-n2-04';

  static UserModel demoUser() {
    return const UserModel(
      id: demoUserId,
      nome: 'Gabriel Tissi',
      points: 0,
      level: UserLevels.junior,
    );
  }

  static List<ActivityModel> demoActivities() {
    return const [
      ActivityModel(
        id: 'activity-firebase-batch',
        points: 50,
        level: UserLevels.junior,
        kind: ActivityKind.trueFalse,
        tree: ActivityTree.firebase,
      ),
      ActivityModel(
        id: 'activity-flutter-transaction',
        points: 80,
        level: UserLevels.junior,
        kind: ActivityKind.blocks,
        tree: ActivityTree.flutter,
      ),
      ActivityModel(
        id: 'activity-dart-transaction',
        points: 120,
        level: UserLevels.pleno,
        kind: ActivityKind.somatory,
        tree: ActivityTree.dart,
      ),
    ];
  }
}

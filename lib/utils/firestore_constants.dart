import '../models/enums.dart';

class FirestoreCollections {
  static const users = 'users';
  static const activities = 'activities';
  static const progress = 'progress';
  static const completedActivities = 'completedActivities';
  static const summary = 'summary';
}

UserLevels levelFromPoints(int points) {
  if (points >= 300) {
    return UserLevels.senior;
  }
  if (points >= 100) {
    return UserLevels.pleno;
  }
  return UserLevels.junior;
}

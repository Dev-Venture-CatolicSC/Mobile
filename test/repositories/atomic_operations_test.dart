import 'package:dev_venture/models/activity_model.dart';
import 'package:dev_venture/models/enums.dart';
import 'package:dev_venture/models/user_model.dart';
import 'package:dev_venture/repositories/activity_repository.dart';
import 'package:dev_venture/repositories/user_repository.dart';
import 'package:dev_venture/services/firestore_service.dart';
import 'package:dev_venture/utils/firestore_constants.dart';
import 'package:dev_venture/utils/firestore_operation_exception.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirestoreService firestoreService;
  late UserRepository userRepository;
  late ActivityRepository activityRepository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    firestoreService = FirestoreService(firestore: fakeFirestore);
    userRepository = UserRepository(firestoreService: firestoreService);
    activityRepository = ActivityRepository(firestoreService: firestoreService);
  });

  group('UserRepository · Batched Writes', () {
    test('createUserProfile grava perfil e progresso juntos', () async {
      const user = UserModel(id: 'user-1', nome: 'Gabriel');

      await userRepository.createUserProfile(user);

      final userDoc = await fakeFirestore
          .collection(FirestoreCollections.users)
          .doc('user-1')
          .get();
      final progressDoc = await fakeFirestore
          .collection(FirestoreCollections.users)
          .doc('user-1')
          .collection(FirestoreCollections.progress)
          .doc(FirestoreCollections.summary)
          .get();

      expect(userDoc.exists, isTrue);
      expect(userDoc.data()?['nome'], 'Gabriel');
      expect(progressDoc.exists, isTrue);
      expect(progressDoc.data()?['totalActivitiesCompleted'], 0);
    });
  });

  group('UserRepository · Transactions', () {
    test('completeActivity atualiza pontos, nível e histórico atomicamente', () async {
      const user = UserModel(id: 'user-1', nome: 'Gabriel', points: 90);
      const activity = ActivityModel(
        id: 'activity-1',
        points: 50,
        level: UserLevels.junior,
        kind: ActivityKind.trueFalse,
        tree: ActivityTree.firebase,
      );

      await userRepository.createUserProfile(user);

      final updatedUser = await userRepository.completeActivity(
        userId: 'user-1',
        activity: activity,
      );

      final userDoc = await fakeFirestore
          .collection(FirestoreCollections.users)
          .doc('user-1')
          .get();
      final completionDoc = await fakeFirestore
          .collection(FirestoreCollections.users)
          .doc('user-1')
          .collection(FirestoreCollections.completedActivities)
          .doc('activity-1')
          .get();
      final progressDoc = await fakeFirestore
          .collection(FirestoreCollections.users)
          .doc('user-1')
          .collection(FirestoreCollections.progress)
          .doc(FirestoreCollections.summary)
          .get();

      expect(updatedUser.points, 140);
      expect(updatedUser.level, UserLevels.pleno);
      expect(userDoc.data()?['points'], 140);
      expect(userDoc.data()?['level'], UserLevels.pleno.name);
      expect(completionDoc.exists, isTrue);
      expect(progressDoc.data()?['totalActivitiesCompleted'], 1);
    });

    test('completeActivity falha quando atividade já foi concluída', () async {
      const user = UserModel(id: 'user-1', nome: 'Gabriel');
      const activity = ActivityModel(
        id: 'activity-1',
        points: 50,
        level: UserLevels.junior,
        kind: ActivityKind.trueFalse,
        tree: ActivityTree.firebase,
      );

      await userRepository.createUserProfile(user);
      await userRepository.completeActivity(userId: 'user-1', activity: activity);

      expect(
        () => userRepository.completeActivity(userId: 'user-1', activity: activity),
        throwsA(isA<FirestoreOperationException>()),
      );
    });

    test('completeActivity falha quando usuário não existe', () async {
      const activity = ActivityModel(
        id: 'activity-1',
        points: 50,
        level: UserLevels.junior,
        kind: ActivityKind.trueFalse,
        tree: ActivityTree.firebase,
      );

      expect(
        () => userRepository.completeActivity(userId: 'missing', activity: activity),
        throwsA(isA<FirestoreOperationException>()),
      );
    });
  });

  group('ActivityRepository · Batched Writes', () {
    test('saveActivities grava catálogo completo', () async {
      final activities = [
        const ActivityModel(
          id: 'a1',
          points: 10,
          level: UserLevels.junior,
          kind: ActivityKind.blocks,
          tree: ActivityTree.dart,
        ),
        const ActivityModel(
          id: 'a2',
          points: 20,
          level: UserLevels.junior,
          kind: ActivityKind.trueFalse,
          tree: ActivityTree.flutter,
        ),
      ];

      await activityRepository.saveActivities(activities);

      final snapshot = await fakeFirestore
          .collection(FirestoreCollections.activities)
          .get();

      expect(snapshot.docs, hasLength(2));
    });

    test('deleteActivitiesWithUserCompletions remove catálogo e histórico', () async {
      const user = UserModel(id: 'user-1', nome: 'Gabriel');
      const activity = ActivityModel(
        id: 'activity-1',
        points: 50,
        level: UserLevels.junior,
        kind: ActivityKind.trueFalse,
        tree: ActivityTree.firebase,
      );

      await userRepository.createUserProfile(user);
      await activityRepository.saveActivities([activity]);
      await userRepository.completeActivity(userId: 'user-1', activity: activity);

      await activityRepository.deleteActivitiesWithUserCompletions(
        userId: 'user-1',
        activityIds: ['activity-1'],
      );

      final activityDoc = await fakeFirestore
          .collection(FirestoreCollections.activities)
          .doc('activity-1')
          .get();
      final completionDoc = await fakeFirestore
          .collection(FirestoreCollections.users)
          .doc('user-1')
          .collection(FirestoreCollections.completedActivities)
          .doc('activity-1')
          .get();

      expect(activityDoc.exists, isFalse);
      expect(completionDoc.exists, isFalse);
    });

    test('saveActivities exige ao menos uma atividade', () async {
      expect(
        () => activityRepository.saveActivities([]),
        throwsA(isA<FirestoreOperationException>()),
      );
    });
  });
}

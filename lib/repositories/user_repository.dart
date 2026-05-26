import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/activity_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../utils/firestore_constants.dart';
import '../utils/firestore_operation_exception.dart';

class UserRepository {
  UserRepository({FirestoreService? firestoreService})
    : _firestoreService = firestoreService ?? FirestoreService();

  final FirestoreService _firestoreService;

  Future<UserModel?> getUser(String userId) async {
    final snapshot = await _firestoreService.users.doc(userId).get();
    if (!snapshot.exists) {
      return null;
    }

    return UserModel.fromMap({...snapshot.data()!, 'id': userId});
  }

  Future<List<String>> getCompletedActivityIds(String userId) async {
    final snapshot = await _firestoreService.users
        .doc(userId)
        .collection(FirestoreCollections.completedActivities)
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

  /// Cria o perfil do usuário e o resumo de progresso em uma única operação.
  ///
  /// Usa [WriteBatch] porque os dados são independentes de leituras prévias:
  /// perfil e progresso inicial devem existir juntos ou não existir.
  Future<void> createUserProfile(UserModel user) async {
    await _firestoreService.runBatch((batch) {
      final userRef = _firestoreService.users.doc(user.id);

      batch.set(userRef, user.toMap());
      batch.set(_firestoreService.userProgressSummary(user.id), {
        'totalActivitiesCompleted': 0,
        'lastActivityAt': null,
      });
    });
  }

  /// Conclui uma atividade atualizando pontos, nível e histórico do usuário.
  ///
  /// Usa [Transaction] porque depende dos valores atuais do usuário e evita
  /// conclusões duplicadas da mesma atividade.
  Future<UserModel> completeActivity({
    required String userId,
    required ActivityModel activity,
  }) async {
    return _firestoreService.runTransaction((transaction) async {
      final userRef = _firestoreService.users.doc(userId);
      final userSnapshot = await transaction.get(userRef);

      if (!userSnapshot.exists) {
        throw FirestoreOperationException('Usuário não encontrado.');
      }

      final completionRef = _firestoreService.completedActivityRef(
        userId,
        activity.id,
      );
      final completionSnapshot = await transaction.get(completionRef);

      if (completionSnapshot.exists) {
        throw FirestoreOperationException('Atividade já concluída.');
      }

      final currentUser = UserModel.fromMap({
        ...userSnapshot.data()!,
        'id': userId,
      });
      final newPoints = currentUser.points + activity.points;
      final newLevel = levelFromPoints(newPoints);
      final progressRef = _firestoreService.userProgressSummary(userId);
      final progressSnapshot = await transaction.get(progressRef);
      final totalCompleted =
          ((progressSnapshot.data()?['totalActivitiesCompleted'] as num?)
              ?.toInt() ??
          0) +
          1;

      transaction.update(userRef, {
        'points': newPoints,
        'level': newLevel.name,
      });
      transaction.set(completionRef, {
        'activityId': activity.id,
        'pointsEarned': activity.points,
        'completedAt': FieldValue.serverTimestamp(),
      });
      transaction.set(progressRef, {
        'totalActivitiesCompleted': totalCompleted,
        'lastActivityAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return currentUser.copyWith(points: newPoints, level: newLevel);
    });
  }
}

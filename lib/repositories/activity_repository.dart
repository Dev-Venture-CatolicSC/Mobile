import '../models/activity_model.dart';
import '../services/firestore_service.dart';
import '../utils/firestore_operation_exception.dart';

class ActivityRepository {
  ActivityRepository({FirestoreService? firestoreService})
    : _firestoreService = firestoreService ?? FirestoreService();

  final FirestoreService _firestoreService;

  /// Persiste várias atividades de uma vez.
  ///
  /// Usa [WriteBatch] para garantir que o catálogo só seja atualizado por
  /// completo quando todas as atividades forem gravadas com sucesso.
  Future<void> saveActivities(List<ActivityModel> activities) async {
    if (activities.isEmpty) {
      throw FirestoreOperationException(
        'Informe ao menos uma atividade para salvar.',
      );
    }

    await _firestoreService.runBatch((batch) {
      for (final activity in activities) {
        batch.set(
          _firestoreService.activities.doc(activity.id),
          activity.toMap(),
        );
      }
    });
  }

  /// Remove atividades e registros de conclusão relacionados ao usuário.
  ///
  /// Usa [WriteBatch] para evitar catálogo parcialmente removido ou histórico
  /// órfão quando uma das exclusões falhar.
  Future<void> deleteActivitiesWithUserCompletions({
    required String userId,
    required List<String> activityIds,
  }) async {
    if (activityIds.isEmpty) {
      throw FirestoreOperationException(
        'Informe ao menos uma atividade para remover.',
      );
    }

    await _firestoreService.runBatch((batch) {
      for (final activityId in activityIds) {
        batch.delete(_firestoreService.activities.doc(activityId));
        batch.delete(
          _firestoreService.completedActivityRef(userId, activityId),
        );
      }
    });
  }
}

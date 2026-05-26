import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:dev_venture/repositories/offline_cache_repository.dart';
import 'package:dev_venture/services/connectivity_service.dart';

/// [G4-N2-01] Exemplo de repositório concreto para progresso do usuário.
///
/// Demonstra como subclasses de [OfflineCacheRepository] especializam o
/// acesso a uma coleção específica do Firestore, herdando automaticamente
/// a estratégia cache-first e a persistência offline.
///
/// Uso:
/// ```dart
/// final repo = UserProgressRepository(userId: 'uid-123');
///
/// // Leitura (cache-first):
/// final progress = await repo.fetchProgress();
///
/// // Stream em tempo real (emite do cache antes de ir ao servidor):
/// repo.watchProgress().listen((p) => print(p));
///
/// // Escrita (enfileirada offline, sincronizada quando conectar):
/// await repo.saveProgress({'xp': 150, 'level': 2});
/// ```
class UserProgressRepository extends OfflineCacheRepository {
  UserProgressRepository({
    required this.userId,
    ConnectivityService? connectivity,
  }) : super(
    collectionPath: 'user_progress',
    connectivity: connectivity,
  );

  final String userId;

  // ── Leitura ─────────────────────────────────────────────────────

  /// Busca o progresso do usuário (cache-first).
  Future<Map<String, dynamic>?> fetchProgress() {
    return fetchDocument(userId);
  }

  /// Stream do progresso — emite imediatamente do cache local.
  Stream<Map<String, dynamic>?> watchProgress() {
    return watchDocument(userId);
  }

  /// Busca histórico de atividades completadas, filtrado por [questId].
  Future<List<Map<String, dynamic>>> fetchCompletedActivities({
    String? questId,
  }) {
    return fetchCollection(
      queryBuilder: (col) {
        Query<Map<String, dynamic>> q = col
            .where('userId', isEqualTo: userId)
            .orderBy('completedAt', descending: true)
            .limit(50);

        if (questId != null) {
          q = q.where('questId', isEqualTo: questId);
        }

        return q;
      },
    );
  }

  // ── Escrita ─────────────────────────────────────────────────────

  /// Salva (merge) o progresso do usuário.
  ///
  /// Se offline, a escrita é enfileirada e sincronizada automaticamente.
  Future<void> saveProgress(Map<String, dynamic> progress) {
    return setDocument(userId, {
      ...progress,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Incrementa o XP do usuário atomicamente.
  Future<void> addXp(int amount) {
    return updateDocument(userId, {
      'xp': FieldValue.increment(amount),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
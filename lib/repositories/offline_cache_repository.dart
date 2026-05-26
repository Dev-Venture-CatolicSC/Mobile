import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:dev_venture/services/firestore_service.dart';
import 'package:dev_venture/services/connectivity_service.dart';

/// [G4-N2-01] Repositório base com estratégia de leitura cache-first.
///
/// Fornece métodos genéricos para leitura de documentos e coleções do
/// Firestore priorizando o cache local. Subclasses especializam o acesso
/// a coleções específicas (ex.: [UserProgressRepository]).
///
/// Estratégia adotada:
/// ```
/// 1. Tenta cache local (instantâneo, funciona offline).
/// 2. Se cache miss E online → busca no servidor.
/// 3. Se cache miss E offline → retorna null / lista vazia.
/// ```
///
/// Para escritas, usa persistência offline do Firestore:
/// operações pendentes são enfileiradas e sincronizadas quando
/// a conexão for restabelecida.
abstract class OfflineCacheRepository {
  OfflineCacheRepository({
    required this.collectionPath,
    ConnectivityService? connectivity,
  }) : _connectivity = connectivity ?? ConnectivityService();

  /// Caminho da coleção Firestore (ex.: `'users'`, `'quests'`).
  final String collectionPath;

  final ConnectivityService _connectivity;

  FirebaseFirestore get _db => FirestoreService.instance.db;

  // ── Leitura de documento único ──────────────────────────────────

  /// Busca um documento pelo [id] com estratégia cache-first.
  ///
  /// Retorna [null] se não encontrado em cache nem no servidor.
  Future<Map<String, dynamic>?> fetchDocument(String id) async {
    final ref = _db.collection(collectionPath).doc(id);

    // 1. Tenta cache.
    try {
      final cached = await ref.get(const GetOptions(source: Source.cache));
      if (cached.exists) {
        debugPrint('[$runtimeType] Cache hit: $collectionPath/$id');
        return cached.data();
      }
    } on FirebaseException catch (e) {
      _logCacheMiss(e, '$collectionPath/$id');
    }

    // 2. Cache miss: tenta servidor se online.
    final online = await _connectivity.isOnline();
    if (!online) {
      debugPrint('[$runtimeType] Offline e sem cache: $collectionPath/$id');
      return null;
    }

    try {
      final snap = await ref.get(const GetOptions(source: Source.server));
      return snap.exists ? snap.data() : null;
    } on FirebaseException catch (e) {
      debugPrint('[$runtimeType] Erro ao buscar servidor: $e');
      return null;
    }
  }

  // ── Leitura de coleção ──────────────────────────────────────────

  /// Busca todos os documentos da coleção com estratégia cache-first.
  ///
  /// [queryBuilder] permite encadear filtros/ordenações antes da execução.
  ///
  /// Exemplo:
  /// ```dart
  /// final docs = await fetchCollection(
  ///   queryBuilder: (q) => q.where('active', isEqualTo: true).limit(20),
  /// );
  /// ```
  Future<List<Map<String, dynamic>>> fetchCollection({
    Query<Map<String, dynamic>> Function(
        CollectionReference<Map<String, dynamic>>,
        )? queryBuilder,
  }) async {
    final baseQuery = _db.collection(collectionPath);
    final query = queryBuilder != null ? queryBuilder(baseQuery) : baseQuery;

    // 1. Tenta cache.
    try {
      final cached = await query.get(const GetOptions(source: Source.cache));
      if (cached.docs.isNotEmpty) {
        debugPrint(
          '[$runtimeType] Cache hit: $collectionPath (${cached.docs.length} docs)',
        );
        return cached.docs.map((d) => d.data()).toList();
      }
    } on FirebaseException catch (e) {
      _logCacheMiss(e, collectionPath);
    }

    // 2. Cache miss: tenta servidor se online.
    final online = await _connectivity.isOnline();
    if (!online) {
      debugPrint('[$runtimeType] Offline e sem cache: $collectionPath');
      return [];
    }

    try {
      final snap = await query.get(const GetOptions(source: Source.server));
      debugPrint(
        '[$runtimeType] Servidor: $collectionPath (${snap.docs.length} docs)',
      );
      return snap.docs.map((d) => d.data()).toList();
    } on FirebaseException catch (e) {
      debugPrint('[$runtimeType] Erro ao buscar servidor: $e');
      return [];
    }
  }

  // ── Stream com cache imediato ───────────────────────────────────

  /// Retorna um [Stream] de snapshots de um documento.
  ///
  /// O SDK do Firestore emite o snapshot do cache localmente antes de
  /// verificar o servidor, garantindo resposta instantânea mesmo offline.
  Stream<Map<String, dynamic>?> watchDocument(String id) {
    return _db
        .collection(collectionPath)
        .doc(id)
        .snapshots(includeMetadataChanges: false)
        .map((snap) => snap.exists ? snap.data() : null);
  }

  /// Retorna um [Stream] de snapshots da coleção.
  ///
  /// [queryBuilder] permite filtrar/ordenar a consulta.
  Stream<List<Map<String, dynamic>>> watchCollection({
    Query<Map<String, dynamic>> Function(
        CollectionReference<Map<String, dynamic>>,
        )? queryBuilder,
  }) {
    final baseQuery = _db.collection(collectionPath);
    final query = queryBuilder != null ? queryBuilder(baseQuery) : baseQuery;

    return query
        .snapshots(includeMetadataChanges: false)
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  // ── Escrita com persistência offline ───────────────────────────

  /// Salva (cria ou sobrescreve) um documento.
  ///
  /// Se offline, a operação é enfileirada e sincronizada automaticamente
  /// quando a conexão for restabelecida.
  Future<void> setDocument(
      String id,
      Map<String, dynamic> data, {
        bool merge = true,
      }) async {
    await _db
        .collection(collectionPath)
        .doc(id)
        .set(data, SetOptions(merge: merge));
    debugPrint('[$runtimeType] set: $collectionPath/$id (merge: $merge)');
  }

  /// Atualiza campos específicos de um documento.
  ///
  /// Se offline, a operação é enfileirada automaticamente.
  Future<void> updateDocument(String id, Map<String, dynamic> fields) async {
    await _db.collection(collectionPath).doc(id).update(fields);
    debugPrint('[$runtimeType] update: $collectionPath/$id');
  }

  /// Remove um documento.
  ///
  /// Se offline, a operação é enfileirada automaticamente.
  Future<void> deleteDocument(String id) async {
    await _db.collection(collectionPath).doc(id).delete();
    debugPrint('[$runtimeType] delete: $collectionPath/$id');
  }

  // ── Utilitários internos ────────────────────────────────────────

  void _logCacheMiss(FirebaseException e, String path) {
    // 'unavailable' é o código esperado para cache miss no SDK do Firestore.
    if (e.code != 'unavailable') {
      debugPrint('[$runtimeType] FirebaseException inesperada ($path): $e');
    }
  }
}
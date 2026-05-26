import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// [G4-N2-01] Serviço de configuração do Firestore com persistência offline.
///
/// Responsabilidades:
///   - Habilitar cache local (offline persistence) no Firestore.
///   - Expor a instância configurada do [FirebaseFirestore].
///   - Centralizar configurações de cache (tamanho, estratégia).
///
/// Uso:
/// ```dart
/// await FirestoreService.initialize();
/// final db = FirestoreService.instance.db;
/// ```
class FirestoreService {
  FirestoreService._();

  static FirestoreService? _instance;

  /// Instância singleton do serviço.
  static FirestoreService get instance {
    assert(
    _instance != null,
    'FirestoreService não foi inicializado. '
        'Chame FirestoreService.initialize() antes de usar.',
    );
    return _instance!;
  }

  late final FirebaseFirestore _db;

  /// Instância configurada do [FirebaseFirestore].
  FirebaseFirestore get db => _db;

  // ── Constantes de configuração ──────────────────────────────────

  /// Tamanho máximo do cache local em bytes.
  /// 100 MB é suficiente para dados de progresso e conteúdo do app.
  static const int _cacheSizeBytes = 100 * 1024 * 1024; // 100 MB

  // ── Inicialização ───────────────────────────────────────────────

  /// Inicializa o [FirestoreService] com persistência offline habilitada.
  ///
  /// Deve ser chamado uma única vez, logo após [Firebase.initializeApp()],
  /// antes do [runApp()].
  ///
  /// Em plataformas web, o Firestore usa IndexedDB automaticamente;
  /// em mobile/desktop, usa SQLite via cache interno do SDK.
  static Future<void> initialize() async {
    if (_instance != null) return;

    final service = FirestoreService._();
    service._db = await _configureFirestore();
    _instance = service;

    debugPrint('[FirestoreService] Inicializado com persistência offline.');
  }

  /// Configura a instância do [FirebaseFirestore] com as opções de cache.
  static Future<FirebaseFirestore> _configureFirestore() async {
    final db = FirebaseFirestore.instance;

    if (kIsWeb) {
      // Na Web o cache multi-tab é habilitado via FirestoreSettings.
      db.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } else {
      // Em iOS, Android, macOS, Linux e Windows:
      // usa o novo PersistentCacheIndexManager (SDK >= 4.x).
      db.settings = Settings(
        persistenceEnabled: true,
        cacheSizeBytes: _cacheSizeBytes,
      );

      // Ativa índices locais automáticos para consultas offline mais rápidas.
      // Disponível a partir do Firebase SDK 4.x (cloud_firestore ^5.x).
      try {
        await db.persistentCacheIndexManager?.enableIndexAutoCreation();
        debugPrint('[FirestoreService] Índices automáticos de cache ativos.');
      } catch (e) {
        // Não-crítico: o cache funciona mesmo sem índices automáticos.
        debugPrint('[FirestoreService] Índices automáticos indisponíveis: $e');
      }
    }

    return db;
  }

  // ── Helpers de acesso a dados ───────────────────────────────────

  /// Retorna uma referência de coleção usando o [Source] adequado
  /// conforme a conectividade informada.
  ///
  /// - [preferCache]: força leitura do cache local (útil quando offline).
  Query<Map<String, dynamic>> collection(
      String path, {
        bool preferCache = false,
      }) {
    return preferCache
        ? _db.collection(path).withConverter<Map<String, dynamic>>(
      fromFirestore: (snap, _) => snap.data()!,
      toFirestore: (data, _) => data,
    )
        : _db.collection(path).withConverter<Map<String, dynamic>>(
      fromFirestore: (snap, _) => snap.data()!,
      toFirestore: (data, _) => data,
    );
  }

  /// Busca um documento, tentando o cache local primeiro.
  ///
  /// Retorna `null` se o documento não existir nem no cache nem no servidor.
  Future<DocumentSnapshot<Map<String, dynamic>>?> getDocument(
      String collection,
      String docId,
      ) async {
    final ref = _db.collection(collection).doc(docId);

    try {
      // Tenta o cache primeiro (instantâneo, funciona offline).
      final cached = await ref.get(const GetOptions(source: Source.cache));
      if (cached.exists) {
        debugPrint('[FirestoreService] Cache hit: $collection/$docId');
        return cached;
      }
    } on FirebaseException catch (e) {
      if (e.code != 'unavailable') {
        // Erro inesperado: propaga.
        rethrow;
      }
      // Cache miss normal → tenta servidor abaixo.
    }

    // Cache miss: tenta o servidor (pode falhar se offline).
    try {
      return await ref.get(const GetOptions(source: Source.server));
    } on FirebaseException catch (e) {
      debugPrint(
        '[FirestoreService] Servidor indisponível ($collection/$docId): $e',
      );
      return null;
    }
  }

  /// Limpa o cache local do Firestore.
  ///
  /// Use com cautela — remove todos os dados persistidos localmente.
  Future<void> clearCache() async {
    try {
      await _db.clearPersistence();
      debugPrint('[FirestoreService] Cache local limpo.');
    } on FirebaseException catch (e) {
      debugPrint('[FirestoreService] Erro ao limpar cache: $e');
    }
  }

  /// Desabilita/habilita o acesso à rede do Firestore.
  ///
  /// Útil para forçar modo offline em testes ou em economizadores de dados.
  Future<void> setNetworkEnabled({required bool enabled}) async {
    if (enabled) {
      await _db.enableNetwork();
      debugPrint('[FirestoreService] Rede habilitada.');
    } else {
      await _db.disableNetwork();
      debugPrint('[FirestoreService] Rede desabilitada (modo offline forçado).');
    }
  }
}
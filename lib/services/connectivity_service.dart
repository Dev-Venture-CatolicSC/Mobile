import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// [G4-N2-01] Serviço de monitoramento de conectividade.
///
/// Detecta se o dispositivo possui conexão com a internet e notifica
/// os listeners quando o estado muda. Usado pelo [OfflineCacheRepository]
/// para decidir entre leitura de cache ou rede.
///
/// Não depende de pacote externo — usa [InternetAddress.lookup] para
/// verificação real de conectividade (evita falso-positivo de Wi-Fi sem
/// acesso à internet).
///
/// Uso:
/// ```dart
/// final connectivity = ConnectivityService();
/// connectivity.onStatusChange.listen((isOnline) { ... });
/// final online = await connectivity.isOnline();
/// ```
class ConnectivityService {
  ConnectivityService() {
    _startPolling();
  }

  // ── Estado interno ──────────────────────────────────────────────

  bool _lastStatus = true;
  Timer? _timer;

  final _controller = StreamController<bool>.broadcast();

  /// Stream que emite `true` quando online e `false` quando offline.
  Stream<bool> get onStatusChange => _controller.stream;

  // ── Intervalo de verificação ────────────────────────────────────

  /// Intervalo de polling de conectividade.
  static const Duration _pollInterval = Duration(seconds: 10);

  /// Host usado para verificar conectividade real (não apenas Wi-Fi ativo).
  static const String _checkHost = 'google.com';

  // ── API pública ─────────────────────────────────────────────────

  /// Verifica conectividade real com a internet de forma assíncrona.
  ///
  /// Em plataformas web ([kIsWeb]), retorna sempre `true` — o browser
  /// gerencia a conectividade internamente.
  Future<bool> isOnline() async {
    if (kIsWeb) return true;
    try {
      final result = await InternetAddress.lookup(_checkHost)
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    }
  }

  /// Libera recursos do serviço.
  void dispose() {
    _timer?.cancel();
    _controller.close();
  }

  // ── Polling interno ─────────────────────────────────────────────

  void _startPolling() {
    // Verificação imediata na inicialização.
    _check();

    _timer = Timer.periodic(_pollInterval, (_) => _check());
  }

  Future<void> _check() async {
    final online = await isOnline();
    if (online != _lastStatus) {
      _lastStatus = online;
      _controller.add(online);
      debugPrint(
        '[ConnectivityService] Status: ${online ? "ONLINE" : "OFFLINE"}',
      );
    }
  }
}
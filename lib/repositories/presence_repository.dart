import '../services/presence_service.dart';

/// Repositório para gerenciar a lógica de presença na camada de domínio.
/// Centraliza as chamadas de validação e registro.
class PresenceRepository {
  final PresenceService _presenceService = PresenceService();

  /// Tenta validar a senha informada e registrar a presença.
  /// Retorna um Future<void> que completa com sucesso ou lança erro.
  Future<void> registrarPresencaNaAula({
    required String aulaId,
    required String code,
  }) async {
    await _presenceService.validarSenhaERegistrarPresenca(
      aulaId: aulaId,
      code: code,
    );
  }
}

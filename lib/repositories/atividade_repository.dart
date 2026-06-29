import '../models/atividade_model.dart';
import '../services/atividade_service.dart';

class AtividadeRepository {
  final AtividadeService _service = AtividadeService();

  Future<AtividadeModel?> buscarAtividadeDoDia(String uid) {
    return _service.buscarAtividadeDoDia(uid);
  }

  Future<List<AtividadeModel>> buscarHistoricoPontuacao(String uid) {
    return _service.buscarHistoricoPontuacao(uid);
  }

  Future<void> concluirAtividade(String uid, String atividadeId, int pontos) {
    return _service.concluirAtividade(uid, atividadeId, pontos);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/atividade_model.dart';

class AtividadeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference _colecaoAtividades(String uid) {
    return _db.collection('usuarios').doc(uid).collection('atividades');
  }

  /// Busca a atividade marcada para o dia de hoje (se houver).
  Future<AtividadeModel?> buscarAtividadeDoDia(String uid) async {
    try {
      final hoje = DateTime.now();
      final inicioDoDia = DateTime(hoje.year, hoje.month, hoje.day);
      final fimDoDia = inicioDoDia.add(const Duration(days: 1));

      final snapshot = await _colecaoAtividades(uid)
          .where(
            'data',
            isGreaterThanOrEqualTo: Timestamp.fromDate(inicioDoDia),
          )
          .where('data', isLessThan: Timestamp.fromDate(fimDoDia))
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return AtividadeModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      throw Exception('Não foi possível carregar a atividade do dia.');
    }
  }

  /// Busca o histórico de atividades já concluídas, da mais recente para a mais antiga.
  Future<List<AtividadeModel>> buscarHistoricoPontuacao(String uid) async {
    try {
      final snapshot = await _colecaoAtividades(uid)
          .where('concluida', isEqualTo: true)
          .orderBy('data', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AtividadeModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Não foi possível carregar o histórico de pontuação.');
    }
  }

  /// Marca uma atividade como concluída e registra os pontos ganhos.
  Future<void> concluirAtividade(
    String uid,
    String atividadeId,
    int pontos,
  ) async {
    try {
      await _colecaoAtividades(
        uid,
      ).doc(atividadeId).update({'concluida': true, 'pontosGanhos': pontos});
    } catch (e) {
      throw Exception('Não foi possível concluir a atividade.');
    }
  }
}

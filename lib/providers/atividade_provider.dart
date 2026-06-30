import 'package:flutter/foundation.dart';
import '../models/atividade_model.dart';
import '../repositories/atividade_repository.dart';

class AtividadeProvider extends ChangeNotifier {
  final AtividadeRepository _repository = AtividadeRepository();

  AtividadeModel? _atividadeDoDia;
  List<AtividadeModel> _historico = [];
  bool _carregando = false;
  String? _erro;

  AtividadeModel? get atividadeDoDia => _atividadeDoDia;
  List<AtividadeModel> get historico => _historico;
  bool get carregando => _carregando;
  String? get erro => _erro;

  int get pontuacaoTotal =>
      _historico.fold(0, (soma, atividade) => soma + atividade.pontosGanhos);

  Future<void> carregarDados(String uid) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _atividadeDoDia = await _repository.buscarAtividadeDoDia(uid);
      _historico = await _repository.buscarHistoricoPontuacao(uid);
    } catch (e) {
      _erro = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> concluirAtividade(
    String uid,
    String atividadeId,
    int pontos,
  ) async {
    try {
      await _repository.concluirAtividade(uid, atividadeId, pontos);
      await carregarDados(uid);
    } catch (e) {
      _erro = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }
}

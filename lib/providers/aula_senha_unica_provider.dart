import 'package:dev_venture/models/aula_senha_unica.dart';
import 'package:dev_venture/repositories/aula_senha_unica_repository.dart';
import 'package:dev_venture/services/aula_senha_unica_service.dart';
import 'package:flutter/foundation.dart';

class AulaSenhaUnicaProvider extends ChangeNotifier {
  final AulaSenhaUnicaRepository _repository = AulaSenhaUnicaRepository();

  AulaSenhaUnica? _senhaAtual;
  bool _carregando = false;
  String? _erro;

  AulaSenhaUnica? get senhaAtual => _senhaAtual;
  bool get carregando => _carregando;
  String? get erro => _erro;
  bool get possuiSenha => _senhaAtual != null;

  Future<bool> gerarSenhaUnica({
    required String aulaId,
    required String alunoId,
    Duration validade = const Duration(minutes: 15),
  }) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _senhaAtual = await _repository.gerarSenhaUnica(
        aulaId: aulaId,
        alunoId: alunoId,
        validade: validade,
      );
      return true;
    } catch (e) {
      _erro = _tratarErro(e);
      return false;
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<bool> validarSenhaUnica({
    required String aulaId,
    required String alunoId,
    required String senha,
  }) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      await _repository.validarSenhaUnica(
        aulaId: aulaId,
        alunoId: alunoId,
        senha: senha,
      );
      return true;
    } catch (e) {
      _erro = _tratarErro(e);
      return false;
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  void limparErro() {
    _erro = null;
    notifyListeners();
  }

  String _tratarErro(Object erro) {
    if (erro is SenhaUnicaException) {
      return erro.message;
    }

    return erro.toString().replaceFirst('Exception: ', '');
  }
}

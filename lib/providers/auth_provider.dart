import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  UserModel? _usuario;
  bool _carregando = false;
  String? _erro;

  StreamSubscription<UserModel?>? _assinaturaAuth;

  UserModel? get usuario => _usuario;
  bool get carregando => _carregando;
  String? get erro => _erro;
  bool get autenticado => _usuario != null;

  AuthProvider() {
    // Sincroniza o estado local com a sessão real do Firebase.
    // Garante que _usuario sempre reflita a fonte da verdade —
    // mesmo em expiração de token ou logout disparado fora deste fluxo.
    _usuario = _repository.usuarioAtual;
    _assinaturaAuth = _repository.usuario.listen((usuario) {
      _usuario = usuario;
      notifyListeners();
    });
  }

  Future<bool> login(String email, String senha) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _usuario = await _repository.fazerLogin(email, senha);
      return true;
    } catch (e) {
      _erro = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<bool> cadastrar(String nome, String email, String senha) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _usuario = await _repository.cadastrar(nome, email, senha);
      return true;
    } catch (e) {
      _erro = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _carregando = true;
    notifyListeners();

    try {
      await _repository.logout();
    } catch (e) {
      _erro = e.toString().replaceFirst('Exception: ', '');
    } finally {
      // Limpa todo o estado sensível — sem resíduo da sessão anterior.
      _usuario = null;
      _erro = null;
      _carregando = false;
      notifyListeners();
    }
  }

  void limparErro() {
    _erro = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _assinaturaAuth?.cancel();
    super.dispose();
  }
}

import 'package:flutter/foundation.dart';
import '../models/auth_flow_model.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

enum LoginStatus { success, otpRequired, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  UserModel? _usuario;
  OtpChallenge? _otpChallenge;
  bool _carregando = false;
  String? _erro;

  UserModel? get usuario => _usuario;
  OtpChallenge? get otpChallenge => _otpChallenge;
  bool get carregando => _carregando;
  String? get erro => _erro;
  bool get autenticado => _usuario != null;

  Future<LoginStatus> login(String email, String senha) async {
    _carregando = true;
    _erro = null;
    _otpChallenge = null;
    notifyListeners();

    try {
      final result = await _repository.login(email, senha);
      if (result.requiresOtp) {
        _otpChallenge = result.otpChallenge;
        return LoginStatus.otpRequired;
      }

      _usuario = result.user;
      return LoginStatus.success;
    } catch (e) {
      _erro = e.toString().replaceFirst('Exception: ', '');
      return LoginStatus.error;
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<bool> validarOtp(String otpCode) async {
    if (_otpChallenge == null) {
      _erro = 'Desafio OTP inválido. Faça login novamente.';
      notifyListeners();
      return false;
    }

    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _usuario = await _repository.validarOtp(_otpChallenge!, otpCode);
      _otpChallenge = null;
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

  void limparErro() {
    _erro = null;
    notifyListeners();
  }
}

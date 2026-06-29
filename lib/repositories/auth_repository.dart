import '../models/auth_flow_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService = AuthService();

  Future<LoginFlowResult> login(String email, String senha) async {
    try {
      final user = await _authService.fazerLogin(email, senha);
      if (user == null) {
        throw Exception('Falha ao autenticar usuário.');
      }
      return LoginFlowResult.authenticated(UserModel.fromFirebaseUser(user));
    } on OtpRequiredException catch (e) {
      final challenge = await _authService.enviarCodigoOtp(e.resolver);
      return LoginFlowResult.otpRequired(challenge);
    }
  }

  Future<UserModel> validarOtp(OtpChallenge challenge, String otpCode) async {
    final user = await _authService.validarOtp(challenge, otpCode);
    if (user == null) throw Exception('Falha ao validar OTP.');
    return UserModel.fromFirebaseUser(user);
  }

  Future<UserModel> cadastrar(String nome, String email, String senha) async {
    final user = await _authService.cadastrar(nome, email, senha);
    if (user == null) throw Exception('Falha ao criar conta. Tente novamente.');
    return UserModel.fromFirebaseUser(user);
  }
}

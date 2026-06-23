import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService = AuthService();

  /// Emite o [UserModel] da sessão atual a cada mudança de autenticação
  /// (login, logout, expiração de token). Emite null quando deslogado.
  Stream<UserModel?> get usuario => _authService.mudancasDeAutenticacao
      .map((user) => user == null ? null : UserModel.fromFirebaseUser(user));

  /// Usuário autenticado no momento, ou null.
  UserModel? get usuarioAtual {
    final user = _authService.usuarioAtual;
    return user == null ? null : UserModel.fromFirebaseUser(user);
  }

  Future<UserModel> fazerLogin(String email, String senha) async {
    final user = await _authService.fazerLogin(email, senha);
    if (user == null) throw Exception('Falha ao entrar. Tente novamente.');
    return UserModel.fromFirebaseUser(user);
  }

  Future<UserModel> cadastrar(String nome, String email, String senha) async {
    final user = await _authService.cadastrar(nome, email, senha);
    if (user == null) throw Exception('Falha ao criar conta. Tente novamente.');
    return UserModel.fromFirebaseUser(user);
  }

  Future<void> logout() => _authService.logout();
}

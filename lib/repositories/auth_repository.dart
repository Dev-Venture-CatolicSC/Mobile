import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService = AuthService();

  Future<UserModel> cadastrar(String nome, String email, String senha) async {
    final user = await _authService.cadastrar(nome, email, senha);
    if (user == null) throw Exception('Falha ao criar conta. Tente novamente.');
    return UserModel.fromFirebaseUser(user);
  }
}

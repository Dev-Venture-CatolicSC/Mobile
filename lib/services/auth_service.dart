import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sua função de Login
  Future<User?> fazerLogin(String email, String password) async {
    try {
      if (email.trim().isEmpty || password.trim().isEmpty) {
        throw Exception("E-mail e senha são obrigatórios.");
      }

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_tratarErroFirebase(e.code));
    } catch (e) {
      throw Exception("Erro interno. Tente novamente.");
    }
  }

  Future<User?> cadastrar(String nome, String email, String senha) async {
    try {
      if (nome.trim().isEmpty || email.trim().isEmpty || senha.trim().isEmpty) {
        throw Exception("Nome, e-mail e senha são obrigatórios.");
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: senha.trim(),
      );

      await userCredential.user?.updateDisplayName(nome.trim());
      await userCredential.user?.reload();

      return _auth.currentUser;
    } on FirebaseAuthException catch (e) {
      throw Exception(_tratarErroFirebase(e.code));
    } catch (e) {
      throw Exception("Erro interno. Tente novamente.");
    }
  }

  String _tratarErroFirebase(String errorCode) {
    switch (errorCode) {
      case 'invalid-email': return 'Formato de e-mail inválido.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential': return 'E-mail ou senha incorretos.';
      case 'too-many-requests': return 'Muitas tentativas. Bloqueado temporariamente.';
      case 'email-already-in-use': return 'Este e-mail já está cadastrado.';
      case 'weak-password': return 'A senha deve ter pelo menos 6 caracteres.';
      case 'operation-not-allowed': return 'Cadastro por e-mail desativado. Contate o suporte.';
      default: return 'Erro de autenticação: $errorCode';
    }
  }
}
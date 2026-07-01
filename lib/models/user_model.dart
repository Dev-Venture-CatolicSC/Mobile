import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String id;
  final String nome;
  final String email;
  final DateTime criadoEm;
  final int pontos;

  UserModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.criadoEm,
    this.pontos = 0,
  });

  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      id: user.uid,
      nome: user.displayName ?? '',
      email: user.email ?? '',
      criadoEm: user.metadata.creationTime ?? DateTime.now(),
      pontos: 0,
    );
  }

    Future<void> addPoints({required bool isRight}) async {
    if (!isRight) return;
    final userRef = FirebaseFirestore.instance.collection('users').doc(id);
    try {
      await userRef.update({
        'pontos': FieldValue.increment(1),
      });
    } catch (e) {
      print('Erro ao atualizar pontos: $e');
      rethrow;
    }
  }

}

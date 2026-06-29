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
}

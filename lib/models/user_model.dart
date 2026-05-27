import 'package:firebase_auth/firebase_auth.dart';
import 'enums.dart';

class UserModel {
  final String id;
  final String nome;
  final String email;
  final DateTime criadoEm;
  final UserLevels level;
  final int points;
  final UserRoles role;

  UserModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.criadoEm,
    this.level = UserLevels.junior,
    this.points = 0,
    this.role = UserRoles.student,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'criadoEm': criadoEm.toIso8601String(),
      'level': level.name,
      'points': points,
      'role': role.name,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      criadoEm: map['criadoEm'] != null 
          ? DateTime.parse(map['criadoEm']) 
          : DateTime.now(),
      level: UserLevels.values.firstWhere(
            (e) => e.name == map['level'] || e.name == map['nivel'],
        orElse: () => UserLevels.junior,
      ),
      points: map['points']?.toInt() ?? 0,
      role: UserRoles.values.firstWhere(
            (e) => e.name == map['role'],
        orElse: () => UserRoles.student,
      ),
    );
  }

  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      id: user.uid,
      nome: user.displayName ?? '',
      email: user.email ?? '',
      criadoEm: user.metadata.creationTime ?? DateTime.now(),
    );
  }
}

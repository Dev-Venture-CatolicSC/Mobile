import 'enums.dart';

class UserModel {
  final String id;
  final String nome;
  final UserLevels level;
  final int points;
  final UserRoles role;

  UserModel({
    required this.id,
    required this.nome,
    this.level = UserLevels.junior,
    this.points = 0,
    this.role = UserRoles.student,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'level': level.name,
      'points': points,
      'role': role.name,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      level: UserLevels.values.firstWhere(
            (e) => e.name == map['nivel'],
        orElse: () => UserLevels.junior,
      ),
      points: map['points']?.toInt() ?? 0,
      role: UserRoles.values.firstWhere(
            (e) => e.name == map['role'],
        orElse: () => UserRoles.student,
      ),
    );
  }
}
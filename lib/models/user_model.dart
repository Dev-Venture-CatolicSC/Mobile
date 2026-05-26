import 'enums.dart';

class UserModel {
  final String id;
  final String nome;
  final UserLevels level;
  final int points;
  final UserRoles role;

  const UserModel({
    required this.id,
    required this.nome,
    this.level = UserLevels.junior,
    this.points = 0,
    this.role = UserRoles.student,
  });

  UserModel copyWith({
    String? id,
    String? nome,
    UserLevels? level,
    int? points,
    UserRoles? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      level: level ?? this.level,
      points: points ?? this.points,
      role: role ?? this.role,
    );
  }

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
        (level) => level.name == map['level'],
        orElse: () => UserLevels.junior,
      ),
      points: (map['points'] as num?)?.toInt() ?? 0,
      role: UserRoles.values.firstWhere(
        (role) => role.name == map['role'],
        orElse: () => UserRoles.student,
      ),
    );
  }
}

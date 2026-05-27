import 'enums.dart';

class ActivityModel {
  final String id;
  final int points;
  final UserLevels level;
  final ActivityKind kind;
  final ActivityTree tree;

  ActivityModel({
    required this.id,
    required this.points,
    required this.level,
    required this.kind,
    required this.tree,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'points': points,
      'level': level.name,
      'kind': kind.name,
      'tree': tree.name,
    };
  }

  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      id: map['id'] ?? '',
      points: map['points']?.toInt() ?? 0,
      level: UserLevels.values.firstWhere(
            (e) => e.name == map['level'],
        orElse: () => UserLevels.junior,
      ),
      kind: ActivityKind.values.firstWhere(
            (e) => e.name == map['kind'],
        orElse: () => ActivityKind.blocks,
      ),
      tree: ActivityTree.values.firstWhere(
            (e) => e.name == map['tree'],
        orElse: () => ActivityTree.dart,
      ),
    );
  }
}
 import 'package:uuid/uuid.dart';

class PendingRecord {
  final String id;
  final String type; // 'presence', 'score', 'activity_answer'
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int attempts;
  final DateTime? nextRetryAt;

  PendingRecord({
    String? id,
    required this.type,
    required this.payload,
    DateTime? createdAt,
    this.attempts = 0,
    this.nextRetryAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  PendingRecord copyWith({
    int? attempts,
    DateTime? nextRetryAt,
  }) {
    return PendingRecord(
      id: id,
      type: type,
      payload: payload,
      createdAt: createdAt,
      attempts: attempts ?? this.attempts,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'payload': payload,
        'createdAt': createdAt.toIso8601String(),
        'attempts': attempts,
        'nextRetryAt': nextRetryAt?.toIso8601String(),
      };

  factory PendingRecord.fromJson(Map<String, dynamic> json) => PendingRecord(
        id: json['id'],
        type: json['type'],
        payload: Map<String, dynamic>.from(json['payload']),
        createdAt: DateTime.parse(json['createdAt']),
        attempts: json['attempts'] ?? 0,
        nextRetryAt: json['nextRetryAt'] != null
            ? DateTime.parse(json['nextRetryAt'])
            : null,
      );
}

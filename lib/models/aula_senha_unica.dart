import 'package:cloud_firestore/cloud_firestore.dart';

class AulaSenhaUnica {
  const AulaSenhaUnica({
    required this.senha,
    required this.aulaId,
    required this.alunoId,
    required this.expiresAt,
    required this.usedBy,
  });

  final String senha;
  final String aulaId;
  final String alunoId;
  final DateTime expiresAt;
  final String usedBy;

  bool get estaExpirada => !expiresAt.isAfter(DateTime.now());
  bool get jaFoiUsada => usedBy.isNotEmpty;

  Map<String, Object?> toFirestore() {
    return {
      'senha': senha,
      'aulaId': aulaId,
      'alunoId': alunoId,
      'expiresAt': Timestamp.fromDate(expiresAt),
      'usedBy': usedBy,
    };
  }

  factory AulaSenhaUnica.fromFirestore({
    required String senha,
    required Map<String, Object?> data,
  }) {
    final expiresAt = _dateFromFirestore(data['expiresAt']);

    if (expiresAt == null) {
      throw const FormatException('Campo expiresAt ausente ou invalido.');
    }

    return AulaSenhaUnica(
      senha: senha,
      aulaId: data['aulaId'] as String? ?? '',
      alunoId: data['alunoId'] as String? ?? '',
      expiresAt: expiresAt,
      usedBy: data['usedBy'] as String? ?? '',
    );
  }

  static DateTime? _dateFromFirestore(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }
}


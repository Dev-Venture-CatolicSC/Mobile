import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dev_venture/models/aula_senha_unica.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AulaSenhaUnica serializa campos obrigatorios do Firestore', () {
    final expiresAt = DateTime(2026, 5, 26, 21);
    final senha = AulaSenhaUnica(
      senha: 'ABC12345',
      aulaId: 'aula-1',
      alunoId: 'aluno-1',
      expiresAt: expiresAt,
      usedBy: '',
    );

    final json = senha.toFirestore();

    expect(json['senha'], 'ABC12345');
    expect(json['aulaId'], 'aula-1');
    expect(json['alunoId'], 'aluno-1');
    expect(json['expiresAt'], isA<Timestamp>());
    expect(json['usedBy'], '');
  });

  test('AulaSenhaUnica le campos vindos do Firestore', () {
    final expiresAt = DateTime(2026, 5, 26, 21);

    final senha = AulaSenhaUnica.fromFirestore(
      senha: 'ABC12345',
      data: {
        'aulaId': 'aula-1',
        'alunoId': 'aluno-1',
        'expiresAt': Timestamp.fromDate(expiresAt),
        'usedBy': '',
      },
    );

    expect(senha.senha, 'ABC12345');
    expect(senha.aulaId, 'aula-1');
    expect(senha.alunoId, 'aluno-1');
    expect(senha.expiresAt, expiresAt);
    expect(senha.usedBy, '');
  });
}
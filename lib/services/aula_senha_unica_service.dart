import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dev_venture/models/aula_senha_unica.dart';

enum SenhaUnicaErro {
  parametrosInvalidos,
  naoEncontrada,
  expirada,
  alunoNaoAutorizado,
  jaUtilizada,
  falhaAoGerar,
}

class SenhaUnicaException implements Exception {
  const SenhaUnicaException(this.erro, this.message);

  final SenhaUnicaErro erro;
  final String message;

  @override
  String toString() => 'SenhaUnicaException($erro): $message';
}

class AulaSenhaUnicaService {
  AulaSenhaUnicaService({
    FirebaseFirestore? firestore,
    Random? random,
    DateTime Function()? now,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _random = random ?? Random.secure(),
       _now = now ?? DateTime.now;

  static const _alfabeto = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  static const _tentativasMaximas = 12;

  final FirebaseFirestore _firestore;
  final Random _random;
  final DateTime Function() _now;

  Future<AulaSenhaUnica> gerarSenhaUnica({
    required String aulaId,
    required String alunoId,
    Duration validade = const Duration(minutes: 15),
    int tamanho = 8,
  }) async {
    _validarParametros(aulaId: aulaId, alunoId: alunoId);

    if (validade <= Duration.zero || tamanho < 6) {
      throw const SenhaUnicaException(
        SenhaUnicaErro.parametrosInvalidos,
        'A validade deve ser positiva e a senha deve ter ao menos 6 caracteres.',
      );
    }

    final aulaNormalizada = aulaId.trim();
    final alunoNormalizado = alunoId.trim();

    return _firestore.runTransaction((transaction) async {
      final alunoRef = _senhaPorAlunoRef(aulaNormalizada, alunoNormalizado);
      final alunoSnapshot = await transaction.get(alunoRef);
      final senhaExistente = alunoSnapshot.data()?['senha'] as String?;
      final expiresAtExistente = _dateFromFirestore(
        alunoSnapshot.data()?['expiresAt'],
      );

      if (senhaExistente != null &&
          senhaExistente.isNotEmpty &&
          expiresAtExistente != null &&
          expiresAtExistente.isAfter(_now())) {
        final senhaSnapshot = await transaction.get(
          _senhaRef(aulaNormalizada, senhaExistente),
        );

        if (senhaSnapshot.exists && senhaSnapshot.data()?['usedBy'] == '') {
          return AulaSenhaUnica.fromFirestore(
            senha: senhaExistente,
            data: senhaSnapshot.data()!,
          );
        }
      }

      final expiresAt = _now().add(validade);

      for (var tentativa = 0; tentativa < _tentativasMaximas; tentativa++) {
        final senha = _gerarCodigo(tamanho);
        final senhaRef = _senhaRef(aulaNormalizada, senha);
        final senhaSnapshot = await transaction.get(senhaRef);

        if (senhaSnapshot.exists) {
          continue;
        }

        final senhaUnica = AulaSenhaUnica(
          senha: senha,
          aulaId: aulaNormalizada,
          alunoId: alunoNormalizado,
          expiresAt: expiresAt,
          usedBy: '',
        );

        transaction.set(senhaRef, {
          ...senhaUnica.toFirestore(),
          'createdAt': FieldValue.serverTimestamp(),
        });
        transaction.set(alunoRef, {
          'senha': senha,
          'expiresAt': Timestamp.fromDate(expiresAt),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        return senhaUnica;
      }

      throw const SenhaUnicaException(
        SenhaUnicaErro.falhaAoGerar,
        'Nao foi possivel gerar uma senha unica para esta aula.',
      );
    });
  }

  Future<void> validarSenhaUnica({
    required String aulaId,
    required String alunoId,
    required String senha,
  }) async {
    _validarParametros(aulaId: aulaId, alunoId: alunoId);

    final senhaNormalizada = senha.trim().toUpperCase();

    if (senhaNormalizada.isEmpty) {
      throw const SenhaUnicaException(
        SenhaUnicaErro.parametrosInvalidos,
        'A senha informada e obrigatoria.',
      );
    }

    final aulaNormalizada = aulaId.trim();
    final alunoNormalizado = alunoId.trim();

    await _firestore.runTransaction((transaction) async {
      final senhaRef = _senhaRef(aulaNormalizada, senhaNormalizada);
      final senhaSnapshot = await transaction.get(senhaRef);

      if (!senhaSnapshot.exists) {
        throw const SenhaUnicaException(
          SenhaUnicaErro.naoEncontrada,
          'Senha nao encontrada para esta aula.',
        );
      }

      final data = senhaSnapshot.data()!;
      final expiresAt = _dateFromFirestore(data['expiresAt']);

      if (expiresAt == null || !expiresAt.isAfter(_now())) {
        throw const SenhaUnicaException(
          SenhaUnicaErro.expirada,
          'Senha expirada.',
        );
      }

      if (data['alunoId'] != alunoNormalizado) {
        throw const SenhaUnicaException(
          SenhaUnicaErro.alunoNaoAutorizado,
          'Esta senha pertence a outro aluno.',
        );
      }

      final usedBy = data['usedBy'] as String? ?? '';

      if (usedBy.isNotEmpty) {
        throw const SenhaUnicaException(
          SenhaUnicaErro.jaUtilizada,
          'Esta senha ja foi utilizada.',
        );
      }

      transaction.update(senhaRef, {
        'usedBy': alunoNormalizado,
        'usedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  DocumentReference<Map<String, dynamic>> _senhaRef(
    String aulaId,
    String senha,
  ) {
    return _firestore
        .collection('aulas')
        .doc(aulaId)
        .collection('senhasUnicas')
        .doc(senha);
  }

  DocumentReference<Map<String, dynamic>> _senhaPorAlunoRef(
    String aulaId,
    String alunoId,
  ) {
    return _firestore
        .collection('aulas')
        .doc(aulaId)
        .collection('senhasPorAluno')
        .doc(alunoId);
  }

  String _gerarCodigo(int tamanho) {
    return List.generate(
      tamanho,
      (_) => _alfabeto[_random.nextInt(_alfabeto.length)],
    ).join();
  }

  void _validarParametros({required String aulaId, required String alunoId}) {
    if (aulaId.trim().isEmpty || alunoId.trim().isEmpty) {
      throw const SenhaUnicaException(
        SenhaUnicaErro.parametrosInvalidos,
        'A aula e o aluno sao obrigatorios.',
      );
    }
  }

  DateTime? _dateFromFirestore(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }
}

// Mantem o nome pedido no card [G1-N2-05] para facilitar a integracao.
// ignore: non_constant_identifier_names
Future<AulaSenhaUnica> GerarSenhaUnica({
  required String aulaId,
  required String alunoId,
  Duration validade = const Duration(minutes: 15),
  int tamanho = 8,
  FirebaseFirestore? firestore,
}) {
  return AulaSenhaUnicaService(firestore: firestore).gerarSenhaUnica(
    aulaId: aulaId,
    alunoId: alunoId,
    validade: validade,
    tamanho: tamanho,
  );
}

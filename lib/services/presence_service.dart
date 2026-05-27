import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Serviço responsável pela gestão de presença e validação de códigos de aula.
/// Implementa a tarefa [G1-N2-06].
class PresenceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Valida a senha da aula e registra a presença do aluno logado.
  /// 
  /// Retorna [true] em caso de sucesso ou lança uma [Exception] com a mensagem de erro.
  Future<bool> validarSenhaERegistrarPresenca(String code) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado. Faça login para continuar.');
      }

      final alunoId = user.uid;

      // 1. Buscar a sessão de aula pelo código informado
      // Estamos assumindo a coleção 'class_sessions' como padrão.
      final querySnapshot = await _firestore
          .collection('class_sessions')
          .where('code', isEqualTo: code.trim())
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Código de aula inválido ou não encontrado.');
      }

      final sessionDoc = querySnapshot.docs.first;
      final sessionData = sessionDoc.data();
      final sessionId = sessionDoc.id;

      // 2. Validar expiração (expiresAt)
      if (sessionData.containsKey('expiresAt')) {
        final Timestamp expiresAt = sessionData['expiresAt'];
        if (expiresAt.toDate().isBefore(DateTime.now())) {
          throw Exception('Este código de aula já expirou.');
        }
      }

      // 3. Validar se a aula está ativa (isActive)
      if (sessionData.containsKey('isActive') && sessionData['isActive'] == false) {
        throw Exception('Esta sessão de aula está desativada.');
      }

      // 4. Verificar se o aluno já registrou presença nesta aula (Impedir reuso/duplicidade)
      // O campo usedBy pode ser uma lista de IDs de alunos.
      final List<dynamic> usedBy = sessionData['usedBy'] ?? [];
      if (usedBy.contains(alunoId)) {
        throw Exception('Sua presença já foi registrada para esta aula.');
      }

      // 5. Registro de Presença - Operação Atômica (Transaction)
      // Usamos transaction para garantir que o registro e a atualização do usedBy ocorram juntos.
      await _firestore.runTransaction((transaction) async {
        // Atualiza a lista de quem usou o código na sessão
        transaction.update(sessionDoc.reference, {
          'usedBy': FieldValue.arrayUnion([alunoId]),
        });

        // Cria o registro oficial na coleção de presenças (histórico)
        final presenceRef = _firestore.collection('presences').doc();
        transaction.set(presenceRef, {
          'alunoId': alunoId,
          'alunoNome': user.displayName ?? 'Aluno',
          'sessionId': sessionId,
          'aulaCode': code.trim(),
          'dataRegistro': FieldValue.serverTimestamp(),
        });
      });

      return true;
    } on FirebaseException catch (e) {
      throw Exception('Erro no banco de dados: ${e.message}');
    } catch (e) {
      // Re-lança a exceção para ser tratada pela UI
      rethrow;
    }
  }
}

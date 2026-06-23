import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'aula_senha_unica_service.dart';

/// Serviço responsável pela gestão de presença e validação de códigos de aula.
/// Implementa a tarefa [G1-N2-06], agora integrado com o serviço de senha do Gustavo [G1-N2-05].
class PresenceService {
  final AulaSenhaUnicaService _aulaSenhaUnicaService = AulaSenhaUnicaService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Valida a senha da aula e registra a presença do aluno logado.
  /// 
  /// Retorna [true] em caso de sucesso ou lança uma [Exception] com a mensagem de erro.
  Future<bool> validarSenhaERegistrarPresenca({
    required String aulaId,
    required String code,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado. Faça login para continuar.');
      }

      final alunoId = user.uid;

      // 1. Validar a Senha Única usando o serviço do Gustavo
      // Este método já realiza todas as validações de expiração, dono da senha e reuso.
      await _aulaSenhaUnicaService.validarSenhaUnica(
        aulaId: aulaId,
        alunoId: alunoId,
        senha: code,
      );

      // 2. Registro de Presença oficial na coleção de presenças
      // Após a validação atômica da senha, criamos o log de presença para a Guilda 2/4.
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      
      await firestore.collection('presences').add({
        'alunoId': alunoId,
        'alunoNome': user.displayName ?? 'Aluno',
        'aulaId': aulaId,
        'aulaCode': code.trim().toUpperCase(),
        'dataRegistro': FieldValue.serverTimestamp(),
      });

      return true;
    } on SenhaUnicaException catch (e) {
      // Traduz as exceções técnicas do serviço de senha para mensagens amigáveis à UI
      throw Exception(_traduzirErroSenha(e));
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erro inesperado ao registrar presença: $e');
    }
  }

  String _traduzirErroSenha(SenhaUnicaException e) {
    switch (e.erro) {
      case SenhaUnicaErro.naoEncontrada:
        return 'Código de aula inválido.';
      case SenhaUnicaErro.expirada:
        return 'Este código de aula já expirou.';
      case SenhaUnicaErro.alunoNaoAutorizado:
        return 'Este código pertence a outro aluno.';
      case SenhaUnicaErro.jaUtilizada:
        return 'Você já utilizou este código para registrar presença.';
      case SenhaUnicaErro.parametrosInvalidos:
        return 'Dados da aula ou código inválidos.';
      default:
        return 'Falha ao validar código: ${e.message}';
    }
  }
}

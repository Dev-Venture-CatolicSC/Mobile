import 'package:dev_venture/models/aula_senha_unica.dart';
import 'package:dev_venture/services/aula_senha_unica_service.dart';

class AulaSenhaUnicaRepository {
  final AulaSenhaUnicaService _service = AulaSenhaUnicaService();

  Future<AulaSenhaUnica> gerarSenhaUnica({
    required String aulaId,
    required String alunoId,
    Duration validade = const Duration(minutes: 15),
    int tamanho = 8,
  }) {
    return _service.gerarSenhaUnica(
      aulaId: aulaId,
      alunoId: alunoId,
      validade: validade,
      tamanho: tamanho,
    );
  }

  Future<void> validarSenhaUnica({
    required String aulaId,
    required String alunoId,
    required String senha,
  }) {
    return _service.validarSenhaUnica(
      aulaId: aulaId,
      alunoId: alunoId,
      senha: senha,
    );
  }
}
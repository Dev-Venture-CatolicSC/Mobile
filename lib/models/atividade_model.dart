import 'package:cloud_firestore/cloud_firestore.dart';

class AtividadeModel {
  final String id;
  final String titulo;
  final String descricao;
  final DateTime data;
  final bool concluida;
  final int pontos;
  final int pontosGanhos;

  AtividadeModel({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.data,
    required this.concluida,
    required this.pontos,
    this.pontosGanhos = 0,
  });

  factory AtividadeModel.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return AtividadeModel(
      id: doc.id,
      titulo: map['titulo'] ?? '',
      descricao: map['descricao'] ?? '',
      data: (map['data'] as Timestamp?)?.toDate() ?? DateTime.now(),
      concluida: map['concluida'] ?? false,
      pontos: map['pontos'] ?? 0,
      pontosGanhos: map['pontosGanhos'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'data': Timestamp.fromDate(data),
      'concluida': concluida,
      'pontos': pontos,
      'pontosGanhos': pontosGanhos,
    };
  }
}

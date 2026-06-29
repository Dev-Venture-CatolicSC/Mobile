import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<bool> submitAnswer({
    required String studentId,
    required String activityId,
    required bool isRight,
    required int pointsToAward,
  }) async {
    if (studentId.isEmpty) {
      throw Exception("Erro: Sessão de aluno não ativa ou inválida.");
    }

    try {
      bool leveledUp = false;

      await _db.runTransaction((transaction) async {
        final answerRef = _db.collection('answers').doc();

        transaction.set(answerRef, {
          'studentId': studentId,
          'activityId': activityId,
          'isRight': isRight,
          'timestamp': FieldValue.serverTimestamp(),
        });

        if (isRight) {
          final studentRef = _db.collection('students').doc(studentId);
          final studentSnapshot = await transaction.get(studentRef);

          if (!studentSnapshot.exists) {
            throw Exception("Aluno não encontrado no banco de dados!");
          }

          final int currentPoints = studentSnapshot.get('points') ?? 0;
          final int currentLevel = studentSnapshot.get('level') ?? 1;

          final int newPoints = currentPoints + pointsToAward;
          int newLevel = currentLevel;

          final int pointsRequiredForNextLevel = _calculatePointsForNextLevel(
            currentLevel,
          );

          if (newPoints >= pointsRequiredForNextLevel) {
            newLevel++;
            leveledUp = true;
          }

          transaction.update(studentRef, {
            'points': newPoints,
            'level': newLevel,
          });
        }
      });

      return leveledUp;
    } catch (e) {
      print("Erro crítico ao processar resposta: $e");
      rethrow;
    }
  }

  int _calculatePointsForNextLevel(int currentLevel) {
    return currentLevel * 100;
  }
}

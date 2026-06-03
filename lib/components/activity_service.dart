import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> submitAnswer({
    required String studentId,
    required String activityId,
    required bool isRight,
    required int pointsToAward,
  }) async {
    try {
      await _db.collection('answers').add({
        'studentId': studentId,
        'activityId': activityId,
        'isRight': isRight,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (isRight) {
        await _addPointsAndLevelUp(studentId, pointsToAward);
      }
    } catch (e) {
      print("Erro ao salvar a resposta: $e");
      rethrow;
    }
  }

  Future<void> _addPointsAndLevelUp(String studentId, int pointsToAdd) async {
    DocumentReference studentRef = _db.collection('students').doc(studentId);

    await _db.runTransaction((transaction) async {
      DocumentSnapshot studentSnapshot = await transaction.get(studentRef);

      if (!studentSnapshot.exists) {
        throw Exception("Aluno não encontrado no banco de dados!");
      }

      int currentPoints = studentSnapshot.get('points') ?? 0;
      int currentLevel = studentSnapshot.get('level') ?? 1;

      int newPoints = currentPoints + pointsToAdd;
      int newLevel = currentLevel;

      int pointsRequiredForNextLevel = currentLevel * 100;

      if (newPoints >= pointsRequiredForNextLevel) {
        newLevel++;
      }

      transaction.update(studentRef, {'points': newPoints, 'level': newLevel});
    });
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<bool> submitAnswer({
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
        return await _addPointsAndLevelUp(studentId, pointsToAward);
      }

      return false;
    } catch (e) {
      print("Erro crítico ao salvar a resposta: $e");
      rethrow;
    }
  }

  Future<bool> _addPointsAndLevelUp(String studentId, int pointsToAdd) async {
    final DocumentReference studentRef = _db
        .collection('students')
        .doc(studentId);
    bool leveledUp = false;

    await _db.runTransaction((transaction) async {
      final DocumentSnapshot studentSnapshot = await transaction.get(
        studentRef,
      );

      if (!studentSnapshot.exists) {
        throw Exception("Aluno não encontrado no banco de dados!");
      }

      final int currentPoints = studentSnapshot.get('points') ?? 0;
      final int currentLevel = studentSnapshot.get('level') ?? 1;

      final int newPoints = currentPoints + pointsToAdd;
      int newLevel = currentLevel;

      final int pointsRequiredForNextLevel = _calculatePointsForNextLevel(
        currentLevel,
      );

      if (newPoints >= pointsRequiredForNextLevel) {
        newLevel++;
        leveledUp = true;
      }

      transaction.update(studentRef, {'points': newPoints, 'level': newLevel});
    });

    return leveledUp;
  }

  int _calculatePointsForNextLevel(int currentLevel) {
    return currentLevel * 100;
  }
}

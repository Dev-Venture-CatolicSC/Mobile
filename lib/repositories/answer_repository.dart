import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/answer_model.dart';

class AnswerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to save the answer document to Firestore
  Future<void> saveAnswer(AnswerModel answer) async {
    try {
      // Accesses the 'answers' collection and adds the mapped document data
      await _firestore.collection('answers').add(answer.toMap());
    } catch (e) {
      print("Error saving answer to repository: $e");
      rethrow;
    }
  }
}
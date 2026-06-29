import 'package:cloud_firestore/cloud_firestore.dart';

class AnswerModel {
  final String id;
  final String activityId;
  final String userId;
  final DateTime dateOfResponse;
  final bool isRight;

  AnswerModel({
    required this.id,
    required this.activityId,
    required this.userId,
    required this.dateOfResponse,
    required this.isRight,
  });

  // Convert a Dart Object into a Map to send to Firestore
  Map<String, dynamic> toMap() {
    return {
      'activityId': activityId,
      'userId': userId,
      // Converts DateTime to Firestore Timestamp format
      'dateOfResponse': Timestamp.fromDate(dateOfResponse), 
      'isRight': isRight,
    };
  }

  // Create a Dart Object out of a Firestore Document Snapshot
  factory AnswerModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AnswerModel(
      id: doc.id,
      activityId: data['activityId'] ?? '',
      userId: data['userId'] ?? '',
      dateOfResponse: (data['dateOfResponse'] as Timestamp).toDate(),
      isRight: data['isRight'] ?? false,
    );
  }
}
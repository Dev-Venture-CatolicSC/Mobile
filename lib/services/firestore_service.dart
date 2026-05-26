import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/firestore_constants.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get users =>
      _firestore.collection(FirestoreCollections.users);

  CollectionReference<Map<String, dynamic>> get activities =>
      _firestore.collection(FirestoreCollections.activities);

  DocumentReference<Map<String, dynamic>> userProgressSummary(String userId) {
    return users
        .doc(userId)
        .collection(FirestoreCollections.progress)
        .doc(FirestoreCollections.summary);
  }

  DocumentReference<Map<String, dynamic>> completedActivityRef(
    String userId,
    String activityId,
  ) {
    return users
        .doc(userId)
        .collection(FirestoreCollections.completedActivities)
        .doc(activityId);
  }

  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) action,
  ) {
    return _firestore.runTransaction(action);
  }

  Future<void> runBatch(void Function(WriteBatch batch) action) async {
    final batch = _firestore.batch();
    action(batch);
    await batch.commit();
  }
}

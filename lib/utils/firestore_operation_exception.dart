class FirestoreOperationException implements Exception {
  FirestoreOperationException(this.message);

  final String message;

  @override
  String toString() => message;
}

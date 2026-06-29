import 'package:dev_venture/offline/models/pending_record.dart';
import 'package:dev_venture/offline/storage/local_queue_storage.dart';

class RetryQueue {
  final LocalQueueStorage _storage;

  static const int _maxAttempts = 5;
  static const List<Duration> _backoffDelays = [
    Duration(minutes: 1),
    Duration(minutes: 2),
    Duration(minutes: 4),
    Duration(minutes: 8),
    Duration(minutes: 16),
  ];

  RetryQueue(this._storage);

  Future<void> enqueue(PendingRecord record) async {
    await _storage.save(record);
  }

  Future<List<PendingRecord>> getPending() async {
    final all = await _storage.getAll();
    final now = DateTime.now();
    return all.where((r) {
      if (r.attempts >= _maxAttempts) return false;
      if (r.nextRetryAt != null && r.nextRetryAt!.isAfter(now)) return false;
      return true;
    }).toList();
  }

  Future<void> markSuccess(String id) async {
    await _storage.delete(id);
  }

  Future<void> markFailure(PendingRecord record) async {
    final nextAttempt = record.attempts + 1;
    if (nextAttempt >= _maxAttempts) {
      await _storage.delete(record.id);
      return;
    }
    final updated = record.copyWith(
      attempts: nextAttempt,
      nextRetryAt: DateTime.now().add(_backoffDelays[nextAttempt]),
    );
    await _storage.update(updated);
  }

  Future<void> process(
    Future<void> Function(PendingRecord record) sender,
  ) async {
    final pending = await getPending();
    for (final record in pending) {
      try {
        await sender(record);
        await markSuccess(record.id);
      } catch (_) {
        await markFailure(record);
      }
    }
  }
}
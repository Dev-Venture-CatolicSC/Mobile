import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dev_venture/offline/services/retry_queue.dart';
import 'package:dev_venture/offline/models/pending_record.dart';

class ConnectivityWatcher {
  final RetryQueue _retryQueue;
  final Future<void> Function(PendingRecord record) _sender;
  StreamSubscription? _subscription;

  ConnectivityWatcher({
    required RetryQueue retryQueue,
    required Future<void> Function(PendingRecord record) sender,
  })  : _retryQueue = retryQueue,
        _sender = sender;

  void start() {
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      final isOnline = results.any((r) => r != ConnectivityResult.none);
      if (isOnline) {
        _retryQueue.process(_sender);
      }
    });
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
  }
}
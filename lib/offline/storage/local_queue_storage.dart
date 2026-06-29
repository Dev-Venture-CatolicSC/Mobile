import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dev_venture/offline/models/pending_record.dart';

class LocalQueueStorage {
  static const String _boxName = 'pending_records';
  late Box _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  Future<void> save(PendingRecord record) async {
    await _box.put(record.id, jsonEncode(record.toJson()));
  }

  Future<List<PendingRecord>> getAll() async {
    return _box.values
        .map((e) => PendingRecord.fromJson(jsonDecode(e)))
        .toList();
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> update(PendingRecord record) async {
    await save(record);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}
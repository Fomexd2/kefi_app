import 'package:hive_flutter/hive_flutter.dart';
import '../models/kefir_batch.dart';

class StorageService {
  static const _boxName = 'batches';

  static Box<KefirBatch> get _box => Hive.box<KefirBatch>(_boxName);

  // ── Inicialización ────────────────────────────────────────────
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(KefirBatchAdapter());
    await Hive.openBox<KefirBatch>(_boxName);
  }

  // ── Lote activo ───────────────────────────────────────────────
  static KefirBatch? getActiveBatch() {
    try {
      return _box.values.firstWhere((b) => b.isActive);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveBatch(KefirBatch batch) async {
    await _box.put(batch.id, batch);
  }

  static Future<void> completeBatch(String id) async {
    final batch = _box.get(id);
    if (batch == null) return;
    final completed = batch.copyWith(
      isActive: false,
      endTime: DateTime.now(),
    );
    await _box.put(id, completed);
  }

  static Future<void> updateBatch(KefirBatch batch) async {
    await _box.put(batch.id, batch);
  }

  static Future<void> deleteBatch(String id) async {
    await _box.delete(id);
  }

  // ── Historial ─────────────────────────────────────────────────
  static List<KefirBatch> getHistory({int limit = 50}) {
    final all = _box.values.where((b) => !b.isActive).toList();
    all.sort((a, b) => b.startTime.compareTo(a.startTime));
    return all.take(limit).toList();
  }
}

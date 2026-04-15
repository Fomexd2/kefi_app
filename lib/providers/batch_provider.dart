import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/kefir_batch.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

// ── Tick cada segundo (solo cuando hay lote activo) ────────────────────────

final tickProvider = StreamProvider<DateTime>((ref) {
  final batch = ref.watch(activeBatchProvider);
  if (batch == null) return Stream.empty();
  return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
});

// ── Lote activo ────────────────────────────────────────────────────────────

final activeBatchProvider =
    StateNotifierProvider<ActiveBatchNotifier, KefirBatch?>(
  (ref) => ActiveBatchNotifier(),
);

class ActiveBatchNotifier extends StateNotifier<KefirBatch?> {
  ActiveBatchNotifier() : super(StorageService.getActiveBatch());

  /// Crea e inicia un nuevo lote.
  Future<void> start(KefirBatch batch) async {
    await StorageService.saveBatch(batch);
    await NotificationService.instance.scheduleBatch(batch);
    state = batch;
  }

  /// Marca el lote activo como completado.
  Future<void> complete() async {
    if (state == null) return;
    await StorageService.completeBatch(state!.id);
    await NotificationService.instance.cancelBatch(state!.id);
    state = null;
  }

  /// Cambia la ubicación y temperatura del lote (recalcula todo).
  Future<void> changeConditions({
    required StorageLocation location,
    required TempPreset preset,
    double? customTempC,
  }) async {
    if (state == null) return;
    final updated = state!.copyWith(
      location: location,
      tempPreset: preset,
      customTempC: customTempC,
    );
    await StorageService.updateBatch(updated);
    await NotificationService.instance.scheduleBatch(updated);
    state = updated;
  }
}

// ── Historial ──────────────────────────────────────────────────────────────

final historyProvider = Provider<List<KefirBatch>>((ref) {
  // Se refresca cada vez que activeBatchProvider cambia (completar un lote).
  ref.watch(activeBatchProvider);
  return StorageService.getHistory();
});

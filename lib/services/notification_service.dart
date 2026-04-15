import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/kefir_batch.dart';

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  // ── Inicialización ────────────────────────────────────────────
  Future<void> init() async {
    tz_data.initializeTimeZones();

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(iOS: iosSettings);
    await _plugin.initialize(settings);
  }

  // ── Programar notificaciones para un lote ─────────────────────
  Future<void> scheduleBatch(KefirBatch batch) async {
    await cancelBatch(batch.id);

    final totalMinutes = batch.estimatedHours * 60;
    final start = batch.startTime;

    final notifications = [
      (
        pct: 0.85,
        title: 'Tu kefir está casi listo 🥛',
        body: 'Prepárate para colarlo',
      ),
      (
        pct: 1.00,
        title: '¡Tu kefir está listo! ✅',
        body: 'Hora de colarlo — ${batch.grainsGrams.toInt()}g / ${batch.milkMl.toInt()}ml',
      ),
      (
        pct: 1.15,
        title: '⚠️ Posible sobre-fermentación',
        body: 'Actúa pronto antes de que se separe demasiado',
      ),
    ];

    for (int i = 0; i < notifications.length; i++) {
      final n = notifications[i];
      final fireAt = start.add(
        Duration(minutes: (totalMinutes * n.pct).round()),
      );

      if (fireAt.isAfter(DateTime.now())) {
        await _plugin.zonedSchedule(
          _id(batch.id, i),
          n.title,
          n.body,
          tz.TZDateTime.from(fireAt, tz.local),
          NotificationDetails(
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              interruptionLevel: i == 2
                  ? InterruptionLevel.timeSensitive
                  : InterruptionLevel.active,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }

  Future<void> cancelBatch(String batchId) async {
    for (int i = 0; i < 3; i++) {
      await _plugin.cancel(_id(batchId, i));
    }
  }

  // Genera un ID de notificación único y estable por lote + índice
  int _id(String batchId, int index) =>
      (batchId.hashCode.abs() % 9000) + index;
}

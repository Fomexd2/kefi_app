import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/kefir_batch.dart';
import '../models/ferment_stage.dart';
import '../providers/batch_provider.dart';
import '../theme/kefi_theme.dart';
import '../widgets/glass_card.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: KefiTheme.backgroundGradient,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 24, 16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Historial',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${history.length} lote${history.length != 1 ? 's' : ''}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // Lista
                Expanded(
                  child: history.isEmpty
                      ? _EmptyHistory()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                          itemCount: history.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, i) =>
                              _BatchHistoryCard(batch: history[i]),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Estado vacío ───────────────────────────────────────────────────────────

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📋', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          const Text(
            'Sin historial aún',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Los lotes completados\naparecerán aquí',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tarjeta de lote histórico ─────────────────────────────────────────────

class _BatchHistoryCard extends StatelessWidget {
  final KefirBatch batch;
  const _BatchHistoryCard({required this.batch});

  @override
  Widget build(BuildContext context) {
    // Calcular estado al colar basado en el progreso real
    final realDuration = batch.endTime != null
        ? batch.endTime!.difference(batch.startTime)
        : batch.elapsed;
    final realProgress =
        realDuration.inSeconds / (batch.estimatedHours * 3600);
    final finalStage = FermentStageX.fromProgress(realProgress);

    final startFmt = DateFormat("d MMM, HH:mm", 'es').format(batch.startTime);
    final durationStr = _formatDuration(realDuration);

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila superior: fecha + badge de estado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                startFmt,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              _StageBadge(stage: finalStage),
            ],
          ),

          const SizedBox(height: 12),

          // Datos del lote
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _Chip('⚗️', '${batch.grainsGrams.toInt()}g / ${batch.milkMl.toInt()}ml'),
              _Chip('📊', '${batch.ratioPer100ml.toStringAsFixed(1)} g/100ml'),
              _Chip('⏱️', durationStr),
              _Chip(
                batch.location == StorageLocation.fridge ? '🧊' : '🌡️',
                batch.tempPreset.label.split(' ').first,
              ),
            ],
          ),

          // Notas
          if (batch.notes != null && batch.notes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Divider(color: Colors.white.withOpacity(0.1), height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('📝 ', style: TextStyle(fontSize: 13)),
                Expanded(
                  child: Text(
                    batch.notes!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.65),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inHours >= 24) {
      return '${d.inDays}d ${d.inHours.remainder(24)}h';
    }
    return '${d.inHours}h ${d.inMinutes.remainder(60)}min';
  }
}

class _StageBadge extends StatelessWidget {
  final FermentStage stage;
  const _StageBadge({required this.stage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: stage.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: stage.color.withOpacity(0.5), width: 1),
      ),
      child: Text(
        '${stage.emoji} ${stage.label}',
        style: TextStyle(
          color: stage.color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String icon;
  final String value;
  const _Chip(this.icon, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white.withOpacity(0.75),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

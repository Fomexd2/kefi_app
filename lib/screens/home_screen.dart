import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/kefir_batch.dart';
import '../models/ferment_stage.dart';
import '../providers/batch_provider.dart';
import '../theme/kefi_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/status_ring.dart';
import '../widgets/timer_display.dart';
import '../widgets/location_toggle.dart';
import '../widgets/temp_preset_selector.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batch = ref.watch(activeBatchProvider);
    // Suscribirse al tick para rebuilds cada segundo
    ref.watch(tickProvider);

    return Scaffold(
      body: Stack(
        children: [
          // ── Fondo degradado ──────────────────────────────────
          const _Background(),
          // ── Contenido ────────────────────────────────────────
          SafeArea(
            child: batch == null
                ? _EmptyState(onNewBatch: () => context.push('/new-batch'))
                : _ActiveBatch(batch: batch),
          ),
        ],
      ),
    );
  }
}

// ── Fondo con blobs decorativos ────────────────────────────────────────────

class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: KefiTheme.backgroundGradient,
      ),
      child: Stack(
        children: [
          // Blob superior derecha
          Positioned(
            top: -60,
            right: -60,
            child: _Blob(size: 260, color: KefiTheme.kPurple.withOpacity(0.45)),
          ),
          // Blob centro izquierda
          Positioned(
            top: MediaQuery.sizeOf(context).height * 0.35,
            left: -80,
            child: _Blob(size: 200, color: KefiTheme.kPrimary.withOpacity(0.35)),
          ),
          // Blob inferior
          Positioned(
            bottom: -80,
            right: 40,
            child: _Blob(size: 220, color: Colors.white.withOpacity(0.07)),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: const SizedBox.expand(),
      ),
    );
  }
}

// ── Estado vacío ───────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onNewBatch;
  const _EmptyState({required this.onNewBatch});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'kefi',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
              ),
              IconButton(
                onPressed: () => context.push('/history'),
                icon: const Icon(Icons.history_rounded, color: Colors.white),
              ),
            ],
          ),
        ),
        const Spacer(),
        // Ilustración central
        const Text('🥛', style: TextStyle(fontSize: 80)),
        const SizedBox(height: 20),
        Text(
          'Sin lote activo',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Inicia un nuevo lote para comenzar\nel seguimiento de tu kefir',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
        ),
        const Spacer(),
        // Botón principal
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
          child: _PrimaryButton(
            label: 'Nuevo lote',
            icon: Icons.add_rounded,
            onTap: onNewBatch,
          ),
        ),
      ],
    );
  }
}

// ── Lote activo ────────────────────────────────────────────────────────────

class _ActiveBatch extends ConsumerWidget {
  final KefirBatch batch;
  const _ActiveBatch({required this.batch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stage = batch.stage;
    final elapsed = batch.elapsed;
    final estimated = Duration(hours: batch.estimatedHours);
    final remaining = estimated - elapsed;
    final isReady = stage == FermentStage.ready || stage == FermentStage.over;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'kefi',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Row(
                  children: [
                    _LocationBadge(batch: batch),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => context.push('/history'),
                      icon: const Icon(Icons.history_rounded,
                          color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── StatusRing ──────────────────────────────────────
          const SizedBox(height: 12),
          StatusRing(
            progress: batch.progress,
            stage: stage,
            timeLabel: _formatTimer(elapsed),
            stageLabel: stage.label,
            size: 240,
          ),

          // ── Tiempo restante ──────────────────────────────────
          const SizedBox(height: 8),
          if (!isReady)
            Text(
              'faltan ${_formatRemaining(remaining.isNegative ? Duration.zero : remaining)}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.65),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          if (isReady)
            Text(
              stage.hint,
              style: TextStyle(
                color: stage.color,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),

          const SizedBox(height: 20),

          // ── Info card ────────────────────────────────────────
          GlassCard(
            child: Column(
              children: [
                _InfoRow(
                  icon: '⚗️',
                  label: 'Lote',
                  value:
                      '${batch.grainsGrams.toInt()}g granos / ${batch.milkMl.toInt()}ml leche',
                ),
                const _Divider(),
                _InfoRow(
                  icon: '📊',
                  label: 'Ratio',
                  value:
                      '${batch.ratioPer100ml.toStringAsFixed(1)} g/100ml — ${batch.ratioQuality}',
                ),
                const _Divider(),
                _InfoRow(
                  icon: '🕐',
                  label: 'Listo aprox.',
                  value: _formatReadyAt(batch.estimatedReadyAt),
                ),
                if (batch.notes != null && batch.notes!.isNotEmpty) ...[
                  const _Divider(),
                  _InfoRow(
                    icon: '📝',
                    label: 'Notas',
                    value: batch.notes!,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Botón cambiar condiciones ─────────────────────────
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cambiar condiciones',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                _ConditionsEditor(batch: batch),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Botón colar ───────────────────────────────────────
          _PrimaryButton(
            label: isReady ? '¡Colar ahora! 🥛' : 'Colar antes de tiempo',
            icon: Icons.check_circle_outline_rounded,
            highlighted: isReady,
            onTap: () => _confirmComplete(context, ref),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _confirmComplete(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _CompleteSheet(
        onConfirm: () {
          ref.read(activeBatchProvider.notifier).complete();
          Navigator.pop(context);
        },
      ),
    );
  }

  String _formatTimer(Duration d) {
    if (d.inHours >= 24) {
      return '${d.inDays}d ${d.inHours.remainder(24).toString().padLeft(2, '0')}h';
    }
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _formatRemaining(Duration d) {
    if (d.inHours >= 24) return '${d.inDays}d ${d.inHours.remainder(24)}h';
    if (d.inHours >= 1) return '${d.inHours}h ${d.inMinutes.remainder(60)}min';
    return '${d.inMinutes}min';
  }

  String _formatReadyAt(DateTime dt) {
    final now = DateTime.now();
    final diff = dt.difference(now);
    if (diff.isNegative) return 'ya pasó el tiempo estimado';
    final fmt = DateFormat('EEE d MMM, HH:mm', 'es');
    return fmt.format(dt);
  }
}

// ── Editor de condiciones en home ─────────────────────────────────────────

class _ConditionsEditor extends ConsumerStatefulWidget {
  final KefirBatch batch;
  const _ConditionsEditor({required this.batch});

  @override
  ConsumerState<_ConditionsEditor> createState() => _ConditionsEditorState();
}

class _ConditionsEditorState extends ConsumerState<_ConditionsEditor> {
  late StorageLocation _location;
  late TempPreset _preset;

  @override
  void initState() {
    super.initState();
    _location = widget.batch.location;
    _preset = widget.batch.tempPreset;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LocationToggle(
          selected: _location,
          onChanged: (l) {
            setState(() {
              _location = l;
              if (l == StorageLocation.fridge) {
                _preset = TempPreset.fridge;
              } else if (_preset == TempPreset.fridge) {
                _preset = TempPreset.ideal;
              }
            });
            _save();
          },
        ),
        if (_location == StorageLocation.ambient) ...[
          const SizedBox(height: 12),
          TempPresetSelector(
            selected: _preset,
            onChanged: (p) {
              setState(() => _preset = p);
              _save();
            },
          ),
        ],
      ],
    );
  }

  void _save() {
    ref.read(activeBatchProvider.notifier).changeConditions(
          location: _location,
          preset: _location == StorageLocation.fridge
              ? TempPreset.fridge
              : _preset,
        );
  }
}

// ── Badge de ubicación ─────────────────────────────────────────────────────

class _LocationBadge extends StatelessWidget {
  final KefirBatch batch;
  const _LocationBadge({required this.batch});

  @override
  Widget build(BuildContext context) {
    final isFridge = batch.location == StorageLocation.fridge;
    final color = isFridge ? KefiTheme.kFridge : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Text(
        '${batch.tempPreset.emoji} ${isFridge ? 'Refri' : batch.tempPreset.label.split(' ').first}',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ── Sheet de confirmación de colado ───────────────────────────────────────

class _CompleteSheet extends StatelessWidget {
  final VoidCallback onConfirm;
  const _CompleteSheet({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B3FA8), Color(0xFF4B4FC4)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🥛', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text(
            '¿Listo para colar?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'El lote se marcará como completado\ny pasará al historial.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PrimaryButton(
                  label: 'Colar',
                  icon: Icons.check_rounded,
                  highlighted: true,
                  onTap: onConfirm,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Helpers UI ─────────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool highlighted;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.highlighted = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: highlighted
                ? Colors.white.withOpacity(0.92)
                : Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(highlighted ? 0 : 0.3),
              width: 1,
            ),
            boxShadow: highlighted
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: highlighted ? KefiTheme.kPrimary : Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: highlighted ? KefiTheme.kPrimary : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Divider(
          height: 1,
          color: Colors.white.withOpacity(0.12),
        ),
      );
}

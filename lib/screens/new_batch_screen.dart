import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/kefir_batch.dart';
import '../providers/batch_provider.dart';
import '../services/ferment_calculator.dart';
import '../theme/kefi_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/ratio_indicator.dart';
import '../widgets/location_toggle.dart';
import '../widgets/temp_preset_selector.dart';

class NewBatchScreen extends ConsumerStatefulWidget {
  const NewBatchScreen({super.key});

  @override
  ConsumerState<NewBatchScreen> createState() => _NewBatchScreenState();
}

class _NewBatchScreenState extends ConsumerState<NewBatchScreen> {
  // ── Paso ──────────────────────────────────────────────────────
  int _step = 0; // 0 = cantidades, 1 = condiciones

  // ── Cantidades ────────────────────────────────────────────────
  final _grainsCtrl = TextEditingController(text: '20');
  final _milkCtrl   = TextEditingController(text: '500');

  // ── Condiciones ───────────────────────────────────────────────
  StorageLocation _location = StorageLocation.ambient;
  TempPreset      _preset   = TempPreset.ideal;
  double?         _customC;

  // ── Notas ─────────────────────────────────────────────────────
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _grainsCtrl.dispose();
    _milkCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── Valores actuales ──────────────────────────────────────────
  double get _grains => double.tryParse(_grainsCtrl.text) ?? 20;
  double get _milk   => double.tryParse(_milkCtrl.text)  ?? 500;

  TempPreset get _effectivePreset =>
      _location == StorageLocation.fridge ? TempPreset.fridge : _preset;

  int get _estimatedHours => FermentCalculator.estimateFromParams(
        grainsGrams: _grains,
        milkMl: _milk,
        preset: _effectivePreset,
        customTempC: _customC,
      );

  DateTime get _readyAt =>
      DateTime.now().add(Duration(hours: _estimatedHours));

  // ── Acciones ──────────────────────────────────────────────────
  void _next() {
    if (_grains <= 0 || _milk <= 0) return;
    setState(() => _step = 1);
  }

  Future<void> _start() async {
    final batch = KefirBatch(
      id: const Uuid().v4(),
      startTime: DateTime.now(),
      grainsGrams: _grains,
      milkMl: _milk,
      location: _location,
      tempPreset: _effectivePreset,
      customTempC: _customC,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    await ref.read(activeBatchProvider.notifier).start(batch);
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo
          Container(
            decoration: const BoxDecoration(
              gradient: KefiTheme.backgroundGradient,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                _Header(
                  step: _step,
                  onBack: _step == 0
                      ? () => context.pop()
                      : () => setState(() => _step = 0),
                ),
                // Contenido del paso
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) => SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.15, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      )),
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: _step == 0
                        ? _StepCantidades(
                            key: const ValueKey(0),
                            grainsCtrl: _grainsCtrl,
                            milkCtrl: _milkCtrl,
                            onNext: _next,
                          )
                        : _StepCondiciones(
                            key: const ValueKey(1),
                            location: _location,
                            preset: _preset,
                            customC: _customC,
                            estimatedHours: _estimatedHours,
                            readyAt: _readyAt,
                            notesCtrl: _notesCtrl,
                            onLocationChanged: (l) => setState(() {
                              _location = l;
                              if (l == StorageLocation.fridge) {
                                _preset = TempPreset.fridge;
                              }
                            }),
                            onPresetChanged: (p) =>
                                setState(() => _preset = p),
                            onStart: _start,
                          ),
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

// ── Header con indicador de paso ──────────────────────────────────────────

class _Header extends StatelessWidget {
  final int step;
  final VoidCallback onBack;

  const _Header({required this.step, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white),
          ),
          const SizedBox(width: 4),
          Text(
            step == 0 ? 'Nuevo lote' : 'Condiciones',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          // Indicador de paso
          Row(
            children: List.generate(2, (i) {
              return Container(
                margin: const EdgeInsets.only(left: 6),
                width: i == step ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == step
                      ? Colors.white
                      : Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Paso 1: Cantidades ─────────────────────────────────────────────────────

class _StepCantidades extends StatefulWidget {
  final TextEditingController grainsCtrl;
  final TextEditingController milkCtrl;
  final VoidCallback onNext;

  const _StepCantidades({
    super.key,
    required this.grainsCtrl,
    required this.milkCtrl,
    required this.onNext,
  });

  @override
  State<_StepCantidades> createState() => _StepCantidadesState();
}

class _StepCantidadesState extends State<_StepCantidades> {
  @override
  void initState() {
    super.initState();
    widget.grainsCtrl.addListener(() => setState(() {}));
    widget.milkCtrl.addListener(() => setState(() {}));
  }

  double get _grains => double.tryParse(widget.grainsCtrl.text) ?? 0;
  double get _milk   => double.tryParse(widget.milkCtrl.text) ?? 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Cuánto kefir\nvas a hacer?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  height: 1.2,
                ),
          ),
          const SizedBox(height: 24),

          // Inputs
          GlassCard(
            child: Column(
              children: [
                _NumberInput(
                  label: 'Granos de kefir',
                  unit: 'g',
                  controller: widget.grainsCtrl,
                  hint: 'ej. 20',
                  icon: '🌱',
                ),
                Divider(
                  color: Colors.white.withOpacity(0.12),
                  height: 24,
                ),
                _NumberInput(
                  label: 'Leche',
                  unit: 'ml',
                  controller: widget.milkCtrl,
                  hint: 'ej. 500',
                  icon: '🥛',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Ratio indicator
          if (_milk > 0)
            GlassCard(
              child: RatioIndicator(
                grainsGrams: _grains,
                milkMl: _milk,
              ),
            ),

          const SizedBox(height: 16),

          // Tips card
          GlassCard(
            opacity: 0.08,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Proporciones recomendadas',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                _Tip('Para empezar: 20g granos / 500ml leche (1:25)'),
                _Tip('Ratio ideal: 1g de granos por cada 30–50ml de leche'),
                _Tip('Más granos = más rápido y más ácido'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Botón siguiente
          _NextButton(
            label: 'Siguiente: condiciones →',
            enabled: _grains > 0 && _milk > 0,
            onTap: widget.onNext,
          ),
        ],
      ),
    );
  }
}

// ── Paso 2: Condiciones ────────────────────────────────────────────────────

class _StepCondiciones extends StatelessWidget {
  final StorageLocation location;
  final TempPreset preset;
  final double? customC;
  final int estimatedHours;
  final DateTime readyAt;
  final TextEditingController notesCtrl;
  final ValueChanged<StorageLocation> onLocationChanged;
  final ValueChanged<TempPreset> onPresetChanged;
  final VoidCallback onStart;

  const _StepCondiciones({
    super.key,
    required this.location,
    required this.preset,
    required this.customC,
    required this.estimatedHours,
    required this.readyAt,
    required this.notesCtrl,
    required this.onLocationChanged,
    required this.onPresetChanged,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final isFridge = location == StorageLocation.fridge;
    final fmt = DateFormat("EEE d MMM 'a las' HH:mm", 'es');
    final readyStr = estimatedHours > 48
        ? 'en ~${(estimatedHours / 24).toStringAsFixed(1)} días'
        : 'en ~${estimatedHours}h';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Dónde está\ntu kefir?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  height: 1.2,
                ),
          ),
          const SizedBox(height: 24),

          // Toggle ubicación
          GlassCard(
            child: LocationToggle(
              selected: location,
              onChanged: onLocationChanged,
            ),
          ),

          // Si está en refri, info
          if (isFridge) ...[
            const SizedBox(height: 16),
            GlassCard(
              tint: KefiTheme.kFridge,
              opacity: 0.12,
              child: Row(
                children: [
                  const Text('🧊', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Fermentación lenta en frío',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ideal para controlar el ciclo y pausar.\nSabor más ácido/láctico, menos gas.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Si está a temperatura ambiente, selector de preset
          if (!isFridge) ...[
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Temperatura ambiente',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TempPresetSelector(
                    selected: preset,
                    onChanged: onPresetChanged,
                  ),
                ],
              ),
            ),
          ],

          // Preview estimado
          const SizedBox(height: 16),
          GlassCard(
            tint: KefiTheme.kReady,
            opacity: 0.10,
            child: Row(
              children: [
                const Text('⏱️', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estimado: listo $readyStr',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      fmt.format(readyAt),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Notas
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notas (opcional)',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'ej. Leche entera, segunda fermentación...',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Botón iniciar
          _NextButton(
            label: '🥛  Iniciar lote',
            enabled: true,
            onTap: onStart,
          ),
        ],
      ),
    );
  }
}

// ── Widgets auxiliares ─────────────────────────────────────────────────────

class _NumberInput extends StatelessWidget {
  final String label;
  final String unit;
  final String hint;
  final String icon;
  final TextEditingController controller;

  const _NumberInput({
    required this.label,
    required this.unit,
    required this.hint,
    required this.icon,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                ],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 22,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  suffixText: unit,
                  suffixStyle: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NextButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _NextButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: enabled
                ? Colors.white.withOpacity(0.92)
                : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: enabled
                  ? KefiTheme.kPrimary
                  : Colors.white.withOpacity(0.4),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  final String text;
  const _Tip(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('·  ', style: TextStyle(color: Colors.white.withOpacity(0.5))),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.65),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

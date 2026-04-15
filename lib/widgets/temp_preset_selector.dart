import 'package:flutter/material.dart';
import '../models/kefir_batch.dart';
import '../theme/kefi_theme.dart';

/// Chips seleccionables para el preset de temperatura ambiente.
class TempPresetSelector extends StatelessWidget {
  final TempPreset selected;
  final ValueChanged<TempPreset> onChanged;
  /// Si true, muestra solo los presets de temperatura ambiente (excluye fridge).
  final bool excludeFridge;

  const TempPresetSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.excludeFridge = true,
  });

  @override
  Widget build(BuildContext context) {
    final presets = TempPreset.values
        .where((p) => excludeFridge ? p != TempPreset.fridge : true)
        .toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: presets.map((p) {
        final isSelected = p == selected;
        return GestureDetector(
          onTap: () => onChanged(p),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withOpacity(0.25)
                  : Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Colors.white.withOpacity(0.6)
                    : Colors.white.withOpacity(0.18),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(p.emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  p.label,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withOpacity(0.6),
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

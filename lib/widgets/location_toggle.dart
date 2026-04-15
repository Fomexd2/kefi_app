import 'package:flutter/material.dart';
import '../models/kefir_batch.dart';
import '../theme/kefi_theme.dart';

/// Toggle de dos opciones: Temperatura ambiente vs Refrigerador.
class LocationToggle extends StatelessWidget {
  final StorageLocation selected;
  final ValueChanged<StorageLocation> onChanged;

  const LocationToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Tile(
          icon: '🌡️',
          label: 'Ambiente',
          isSelected: selected == StorageLocation.ambient,
          onTap: () => onChanged(StorageLocation.ambient),
        ),
        const SizedBox(width: 12),
        _Tile(
          icon: '🧊',
          label: 'Refrigerador',
          isSelected: selected == StorageLocation.fridge,
          tintColor: KefiTheme.kFridge,
          onTap: () => onChanged(StorageLocation.fridge),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  final String icon;
  final String label;
  final bool isSelected;
  final Color? tintColor;
  final VoidCallback onTap;

  const _Tile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.tintColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = tintColor ?? Colors.white;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withOpacity(0.20)
                : Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? color.withOpacity(0.55)
                  : Colors.white.withOpacity(0.15),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withOpacity(0.55),
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

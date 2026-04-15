import 'package:flutter/material.dart';
import '../services/ferment_calculator.dart';
import '../theme/kefi_theme.dart';

/// Barra visual que muestra el ratio granos/leche y su calidad.
/// La zona verde (ideal) está entre 3–5 g por 100 ml.
class RatioIndicator extends StatelessWidget {
  final double grainsGrams;
  final double milkMl;

  const RatioIndicator({
    super.key,
    required this.grainsGrams,
    required this.milkMl,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = milkMl > 0 ? grainsGrams / (milkMl / 100) : 0.0;
    final quality = FermentCalculator.ratioQuality(ratio);
    final position = (ratio / 12.0).clamp(0.0, 1.0);

    final qualityColor = switch (quality) {
      'Ideal'        => KefiTheme.kReady,
      'Intenso'      => KefiTheme.kAlmost,
      'Muy intenso'  => KefiTheme.kOver,
      _              => KefiTheme.kStarting,  // Muy suave
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ratio: ${ratio.toStringAsFixed(1)} g/100ml',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: qualityColor.withOpacity(0.25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: qualityColor.withOpacity(0.6),
                  width: 1,
                ),
              ),
              child: Text(
                quality,
                style: TextStyle(
                  color: qualityColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Barra con zonas de color
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 8,
            child: Stack(
              children: [
                // Fondo degradado: suave → ideal → intenso
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF9E9EBD), // muy suave — gris
                        Color(0xFF66BB6A), // ideal — verde
                        Color(0xFFFF9800), // intenso — naranja
                        Color(0xFFEF5350), // muy intenso — rojo
                      ],
                      stops: [0.0, 0.33, 0.66, 1.0],
                    ),
                  ),
                ),
                // Indicador de posición
                Positioned(
                  left: (position * (MediaQuery.sizeOf(context).width - 80))
                      .clamp(0, double.infinity),
                  child: Container(
                    width: 14,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Suave',
              style: TextStyle(
                color: Colors.white.withOpacity(0.55),
                fontSize: 10,
              ),
            ),
            Text(
              'Ideal',
              style: TextStyle(
                color: KefiTheme.kReady.withOpacity(0.85),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Intenso',
              style: TextStyle(
                color: Colors.white.withOpacity(0.55),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

import '../models/kefir_batch.dart';

/// Motor de cálculo de tiempo de fermentación basado en:
///   - Ratio granos / leche (g por 100 ml)
///   - Temperatura / ambiente (TempPreset o °C exactos)
///
/// Fuente científica:
///   1g/50ml (~2 g/100ml) → ~28h base a 22°C
///   1g/30ml (~3.3g/100ml) → ~24h base
///   1g/15ml (~6.7g/100ml) → ~18h base
///   1g/10ml (~10g/100ml)  → ~13h base
abstract class FermentCalculator {
  // ── Tiempo base en horas a 22°C ───────────────────────────────
  static double _baseHours(double gPer100ml) {
    // Interpolación lineal: ratio 2 → 28h, ratio 10 → 13h
    // pendiente = (28 - 13) / (2 - 10) = -1.875
    final hours = 28.0 - (gPer100ml - 2.0) * 1.875;
    return hours.clamp(8.0, 40.0);
  }

  // ── Multiplicador de temperatura ──────────────────────────────
  static double _multiplier(TempPreset preset, double? customC) {
    if (customC != null) {
      // Cálculo continuo: a 22°C = 1.0, a 10°C ~ 2.2, a 28°C ~ 0.7
      final m = 22.0 / customC.clamp(4.0, 35.0);
      return m.clamp(0.5, 8.0);
    }
    return preset.multiplier;
  }

  // ── API pública ───────────────────────────────────────────────

  /// Horas estimadas para un lote dado.
  static int estimateHours(KefirBatch batch) {
    final base = _baseHours(batch.ratioPer100ml);
    final mult = _multiplier(batch.tempPreset, batch.customTempC);
    return (base * mult).round().clamp(6, 200);
  }

  /// Horas estimadas directamente desde parámetros (para preview en tiempo real).
  static int estimateFromParams({
    required double grainsGrams,
    required double milkMl,
    required TempPreset preset,
    double? customTempC,
  }) {
    if (milkMl <= 0) return 24;
    final ratio = grainsGrams / (milkMl / 100);
    final base = _baseHours(ratio);
    final mult = _multiplier(preset, customTempC);
    return (base * mult).round().clamp(6, 200);
  }

  /// Consejo de texto para el formulario.
  static String advice({
    required double grainsGrams,
    required double milkMl,
    required TempPreset preset,
  }) {
    if (milkMl <= 0) return '';
    final ratio = grainsGrams / (milkMl / 100);
    final hours = estimateFromParams(
      grainsGrams: grainsGrams,
      milkMl: milkMl,
      preset: preset,
    );

    if (preset == TempPreset.fridge) {
      final days = (hours / 24).toStringAsFixed(1);
      return 'Fermentación lenta en frío — ~$days días';
    }
    if (ratio > 8) return 'Ratio alto: kefir intenso y rápido — ~${hours}h';
    if (ratio < 2.5) return 'Ratio bajo: kefir suave y cremoso — ~${hours}h';
    return 'Ratio equilibrado — listo en ~${hours}h';
  }

  /// Calidad textual del ratio.
  static String ratioQuality(double gPer100ml) {
    if (gPer100ml < 2.0) return 'Muy suave';
    if (gPer100ml < 4.5) return 'Ideal';
    if (gPer100ml < 8.0) return 'Intenso';
    return 'Muy intenso';
  }
}

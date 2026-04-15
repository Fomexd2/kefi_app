import 'package:flutter/material.dart';
import '../theme/kefi_theme.dart';

enum FermentStage { starting, fermenting, almost, ready, over }

extension FermentStageX on FermentStage {
  /// Calcula la etapa a partir del progreso (0.0 = inicio, 1.0 = tiempo estimado)
  static FermentStage fromProgress(double progress) {
    if (progress < 0.25) return FermentStage.starting;
    if (progress < 0.65) return FermentStage.fermenting;
    if (progress < 0.88) return FermentStage.almost;
    if (progress < 1.10) return FermentStage.ready;
    return FermentStage.over;
  }

  Color get color => switch (this) {
        FermentStage.starting  => KefiTheme.kStarting,
        FermentStage.fermenting => KefiTheme.kFerment,
        FermentStage.almost    => KefiTheme.kAlmost,
        FermentStage.ready     => KefiTheme.kReady,
        FermentStage.over      => KefiTheme.kOver,
      };

  String get label => switch (this) {
        FermentStage.starting  => 'Iniciando',
        FermentStage.fermenting => 'Fermentando',
        FermentStage.almost    => 'Casi listo',
        FermentStage.ready     => '¡Listo para colar!',
        FermentStage.over      => 'Sobre-fermentado',
      };

  String get emoji => switch (this) {
        FermentStage.starting  => '😴',
        FermentStage.fermenting => '🫧',
        FermentStage.almost    => '⏳',
        FermentStage.ready     => '✅',
        FermentStage.over      => '⚠️',
      };

  String get hint => switch (this) {
        FermentStage.starting  => 'Las bacterias están despertando',
        FermentStage.fermenting => 'Burbujas y espesamiento activo',
        FermentStage.almost    => 'Leve separación visible, prepárate',
        FermentStage.ready     => 'Textura yogur líquido, sabor balanceado',
        FermentStage.over      => 'Suero separado, sabor muy ácido — actúa ya',
      };
}

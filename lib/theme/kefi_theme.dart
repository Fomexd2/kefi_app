import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class KefiTheme {
  // ── Colores base ──────────────────────────────────────────────
  static const kPrimary    = Color(0xFF4B4FC4);
  static const kPrimaryDark = Color(0xFF3B3FA8);
  static const kPurple     = Color(0xFF6B4FC4);
  static const kBackground = Color(0xFFFFFFFF);
  static const kSurface    = Color(0xFFF0F0FA);
  static const kText       = Color(0xFF1A1A2E);
  static const kTextLight  = Color(0xFF6B6B8A);

  // ── Estados de fermentación ───────────────────────────────────
  static const kStarting  = Color(0xFF9E9EBD);   // gris azulado
  static const kFerment   = Color(0xFFFFCA28);   // amarillo cálido
  static const kAlmost    = Color(0xFFFF9800);   // naranja
  static const kReady     = Color(0xFF66BB6A);   // verde
  static const kOver      = Color(0xFFEF5350);   // rojo

  // ── Ambiente ──────────────────────────────────────────────────
  static const kFridge    = Color(0xFF90CAF9);   // azul frío

  // ── Gradiente de fondo de la app ──────────────────────────────
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2E3199),   // azul profundo
      Color(0xFF4B4FC4),   // kefi blue
      Color(0xFF6B4FC4),   // morado kefi
    ],
    stops: [0.0, 0.55, 1.0],
  );

  // ── Glass card helper ─────────────────────────────────────────
  static BoxDecoration glassDecoration({
    double opacity = 0.15,
    double radius = 24,
    Color? tint,
  }) =>
      BoxDecoration(
        color: (tint ?? Colors.white).withOpacity(opacity),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: Colors.white.withOpacity(0.28),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      );

  // ── Tema Material ─────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimary,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.nunitoTextTheme().copyWith(
          displayLarge: GoogleFonts.nunito(
            fontSize: 56,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
          headlineMedium: GoogleFonts.nunito(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          titleLarge: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          bodyLarge: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          bodyMedium: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(0.85),
          ),
          labelLarge: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        scaffoldBackgroundColor: kBackground,
      );
}

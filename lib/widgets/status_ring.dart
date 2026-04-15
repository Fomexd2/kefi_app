import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/ferment_stage.dart';
import '../theme/kefi_theme.dart';

/// Anillo circular de progreso con gradiente y glow según el estado del kefir.
class StatusRing extends StatelessWidget {
  final double progress;      // 0.0 → 1.5+
  final FermentStage stage;
  final String timeLabel;     // HH:MM:SS o D:HH:MM
  final String stageLabel;
  final double size;

  const StatusRing({
    super.key,
    required this.progress,
    required this.stage,
    required this.timeLabel,
    required this.stageLabel,
    this.size = 240,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow difuso detrás del anillo
          _GlowCircle(color: stage.color, size: size),
          // Anillo de progreso
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: progress,
              stageColor: stage.color,
            ),
          ),
          // Contenido central
          _CenterContent(
            timeLabel: timeLabel,
            stageLabel: stageLabel,
            emoji: stage.emoji,
            stageColor: stage.color,
          ),
        ],
      ),
    );
  }
}

// ── Glow detrás del anillo ─────────────────────────────────────────────────

class _GlowCircle extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowCircle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * 0.78,
      height: size * 0.78,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.30),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
    );
  }
}

// ── Pintor del anillo ──────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final double progress;
  final Color stageColor;

  const _RingPainter({required this.progress, required this.stageColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 16;
    const stroke = 14.0;
    const startAngle = -pi / 2;
    final sweep = (2 * pi * progress.clamp(0.0, 1.12));

    // ── Track (fondo del anillo)
    final trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // ── Arco de progreso con gradiente
    if (sweep > 0.01) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final gradientPaint = Paint()
        ..shader = SweepGradient(
          startAngle: startAngle,
          endAngle: startAngle + sweep,
          colors: [
            stageColor.withOpacity(0.5),
            stageColor,
            stageColor.withOpacity(0.9),
          ],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(rect)
        ..strokeWidth = stroke
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle, sweep, false, gradientPaint);

      // ── Punto brillante al final del arco
      final tipAngle = startAngle + sweep;
      final tipX = center.dx + radius * cos(tipAngle);
      final tipY = center.dy + radius * sin(tipAngle);
      final tipPaint = Paint()
        ..color = Colors.white.withOpacity(0.9)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(Offset(tipX, tipY), stroke / 2 + 1, tipPaint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.stageColor != stageColor;
}

// ── Contenido central ──────────────────────────────────────────────────────

class _CenterContent extends StatelessWidget {
  final String timeLabel;
  final String stageLabel;
  final String emoji;
  final Color stageColor;

  const _CenterContent({
    required this.timeLabel,
    required this.stageLabel,
    required this.emoji,
    required this.stageColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Text(
          timeLabel,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: stageColor.withOpacity(0.25),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: stageColor.withOpacity(0.5), width: 1),
          ),
          child: Text(
            stageLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: stageColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

/// Muestra el tiempo transcurrido. Formatea como HH:MM:SS para fermentaciones
/// cortas, o D días HH:MM para fermentaciones largas (refri).
class TimerDisplay extends StatelessWidget {
  final Duration elapsed;
  final Duration? remaining;
  final bool compact;

  const TimerDisplay({
    super.key,
    required this.elapsed,
    this.remaining,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Text(
        _formatCompact(elapsed),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      );
    }

    return Column(
      children: [
        // Tiempo transcurrido
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              _formatMain(elapsed),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 44,
                fontWeight: FontWeight.w800,
                letterSpacing: -2,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            if (elapsed.inHours < 24)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  _unitLabel(elapsed),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        if (remaining != null && remaining!.isNegative == false)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'faltan ${_formatRemaining(remaining!)}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.65),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  // ── Formateo ───────────────────────────────────────────────────

  String _formatMain(Duration d) {
    if (d.inHours >= 24) {
      final days = d.inDays;
      final hours = d.inHours.remainder(24);
      return '${days}d ${hours.toString().padLeft(2, '0')}h';
    }
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _formatCompact(Duration d) {
    if (d.inHours >= 24) {
      return '${d.inDays}d ${d.inHours.remainder(24)}h';
    }
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _unitLabel(Duration d) =>
      d.inHours >= 1 ? 'h' : 'min';

  String _formatRemaining(Duration d) {
    if (d.inHours >= 24) return '${d.inDays}d ${d.inHours.remainder(24)}h';
    if (d.inHours >= 1) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}min';
    }
    return '${d.inMinutes}min';
  }
}

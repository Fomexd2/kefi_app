import 'dart:ui';
import 'package:flutter/material.dart';

/// Contenedor con efecto glassmorphism iOS.
/// Usa BackdropFilter blur + fondo semi-transparente + borde blanco sutil.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final double blur;
  final double opacity;
  final Color? tint;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 24,
    this.blur = 20,
    this.opacity = 0.15,
    this.tint,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: (tint ?? Colors.white).withOpacity(opacity),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: Colors.white.withOpacity(0.28),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}

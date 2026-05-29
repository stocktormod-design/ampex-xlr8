import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

class AmpexBackdrop extends StatelessWidget {
  const AmpexBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: AppColors.background, child: child);
  }
}

/// Mørkt dashboard-kort med subtil kant.
class AmpexGlass extends StatelessWidget {
  const AmpexGlass({
    super.key,
    required this.child,
    this.borderRadius = AppRadius.sectionBorder,
    this.color = AppColors.surface,
    this.border = true,
    this.elevated = false,
    this.gradient,
    this.blur = 0.0,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final Color color;
  final bool border;
  final bool elevated;
  final Gradient? gradient;
  final double blur;

  @override
  Widget build(BuildContext context) {
    final useGradient = gradient ?? (elevated ? AppColors.cardGradient : null);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: useGradient == null ? color : null,
        gradient: useGradient,
        borderRadius: borderRadius,
        border: border ? Border.all(color: AppColors.border, width: 1) : null,
        boxShadow: elevated
            ? const [
                BoxShadow(
                  color: Color(0x30000000),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: ClipRRect(borderRadius: borderRadius, child: child),
    );
  }
}

class AmpexBarBlur extends StatelessWidget {
  const AmpexBarBlur({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: child,
      ),
    );
  }
}

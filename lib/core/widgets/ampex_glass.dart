import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// Gradient-bakteppe med myke fargede «blobs».
///
/// Dette er flaten alt glass legger seg oppå – gir dybde og den
/// Spotify-aktige følelsen. Brukes som rot på hver skjerm.
class AmpexBackdrop extends StatelessWidget {
  const AmpexBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.backdropGradient),
      child: Stack(
        children: [
          // Fargede blobs som glasset blurrer.
          Positioned(
            top: -120,
            right: -80,
            child: _Blob(color: AppColors.blobBlue, size: 320),
          ),
          Positioned(
            top: 180,
            left: -110,
            child: _Blob(color: AppColors.blobViolet, size: 280),
          ),
          Positioned(
            bottom: -100,
            right: -60,
            child: _Blob(color: AppColors.blobCyan, size: 300),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

/// Frostet glassflate – halvgjennomsiktig + blur + hårfin lyskant.
///
/// Den ene byggeklossen for kort, seksjoner, barer. Samme uttrykk overalt.
class AmpexGlass extends StatelessWidget {
  const AmpexGlass({
    super.key,
    required this.child,
    this.borderRadius = AppRadius.sectionBorder,
    this.color = AppColors.glassSurface,
    this.blur = 24,
    this.border = true,
    this.shadow = true,
    this.clip = true,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final Color color;
  final double blur;
  final bool border;
  final bool shadow;
  final bool clip;

  @override
  Widget build(BuildContext context) {
    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        border: border
            ? Border.all(color: AppColors.glassBorder, width: 1)
            : null,
      ),
      child: child,
    );

    final blurred = clip
        ? ClipRRect(
            borderRadius: borderRadius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: content,
            ),
          )
        : content;

    if (!shadow) return blurred;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: blurred,
    );
  }
}

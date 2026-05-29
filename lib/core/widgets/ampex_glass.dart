import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// En helt ren bakgrunn, droppet farge-blobs. Ekte Spotify-clean.
/// 
/// Brukes på start/login for en veldig myk gradient mot sort.
class AmpexBackdrop extends StatelessWidget {
  const AmpexBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.background), // Helt clean svart
      child: child,
    );
  }
}

/// Frostet glassflate – tilpasset dark mode.
class AmpexGlass extends StatelessWidget {
  const AmpexGlass({
    super.key,
    required this.child,
    this.borderRadius = AppRadius.sectionBorder,
    this.color = AppColors.glassSurface,
    this.blur = 30, // Høyere blur i dark mode
    this.border = false, // Drop borders for et renere uttrykk
    this.shadow = false, // Drop skygger i mørkt tema (gir ikke mening på svart bakgrunn)
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
            ? Border.all(color: AppColors.glassBorder, width: 0.5)
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

    return blurred; // Ingen skygge i mørk modus
  }
}

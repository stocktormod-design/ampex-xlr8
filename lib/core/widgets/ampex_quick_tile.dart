import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import 'ampex_glass.dart';

/// Hurtigkort på frostet glass med farget ikon-«chip».
class AmpexQuickTile extends StatelessWidget {
  const AmpexQuickTile({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = color;
    return AmpexGlass(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.sectionBorder,
          splashColor: AppColors.pressed,
          highlightColor: AppColors.pressed,
          child: SizedBox(
            height: 104,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHighlight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 18, color: iconColor),
                  ),
                  Text(label, style: AppTypography.headline),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

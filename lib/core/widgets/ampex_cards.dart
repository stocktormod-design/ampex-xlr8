import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import 'ampex_glass.dart';

/// Inline nøkkeltall til hero-kortet («Hva jobber jeg med i dag?»).
class AmpexKpi extends StatelessWidget {
  const AmpexKpi({
    super.key,
    required this.value,
    required this.label,
    this.valueColor = AppColors.label,
    this.onTap,
  });

  final String value;
  final String label;
  final Color valueColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTypography.title1.copyWith(
            color: valueColor,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.labelSecondary,
            letterSpacing: 0,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );

    if (onTap == null) return content;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.chip),
      hoverColor: AppColors.hover,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: content,
      ),
    );
  }
}

/// Modulkort på dashboardet. Aktive moduler har accent-ikon; [coming]
/// markerer ikke-bygde moduler med dempet uttrykk + «Kommer»-badge.
class AmpexModuleTile extends StatefulWidget {
  const AmpexModuleTile({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    this.onTap,
    this.coming = false,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool coming;

  @override
  State<AmpexModuleTile> createState() => _AmpexModuleTileState();
}

class _AmpexModuleTileState extends State<AmpexModuleTile> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _isPressed ? 0.98 : (_isHovered ? 1.02 : 1.0);

    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _ModuleChip(icon: widget.icon, active: !widget.coming),
              const Spacer(),
              if (widget.coming) const _ComingBadge(),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: AppTypography.headline,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  widget.subtitle!,
                  style: AppTypography.footnote,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ],
      ),
    );

    if (widget.coming) {
      return Opacity(opacity: 0.4, child: AmpexGlass(child: content));
    }

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      child: AmpexGlass(
        elevated: true,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onHover: (hovering) => setState(() => _isHovered = hovering),
            borderRadius: AppRadius.sectionBorder,
            splashColor: AppColors.pressed,
            highlightColor: AppColors.pressed,
            hoverColor: AppColors.hover,
            child: content,
          ),
        ),
      ),
    );
  }
}

class _ModuleChip extends StatelessWidget {
  const _ModuleChip({required this.icon, required this.active});

  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? AppColors.accentSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: 22,
        color: active ? AppColors.accent : AppColors.labelTertiary,
      ),
    );
  }
}

class _ComingBadge extends StatelessWidget {
  const _ComingBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.separator, width: 1),
      ),
      child: Text(
        'Kommer',
        style: AppTypography.caption.copyWith(
          color: AppColors.labelTertiary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

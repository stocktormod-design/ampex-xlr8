import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../platform/app_product.dart';
import '../theme/app_colors.dart';

/// iPhone-ramme på web/desktop når [AmpexProduct.mobile] simuleres.
///
/// Native iOS/Android bruker ekte skjermbredde — ingen ramme.
class MobilePreviewFrame extends StatelessWidget {
  const MobilePreviewFrame({
    super.key,
    required this.child,
    this.enabled = true,
  });

  final Widget child;
  final bool enabled;

  /// iPhone 15 Pro logisk bredde (pt).
  static const double phoneWidth = 390;

  /// Referansehøyde; skaleres ned hvis vinduet er lavere.
  static const double phoneHeight = 844;

  static bool get available => kIsWeb || kDebugMode;

  /// Ramme når Mobile-produkt kjøres utenfor ekte telefon.
  static bool shouldSimulate(AmpexProduct product) =>
      product == AmpexProduct.mobile &&
      !AmpexProductResolver.isNativeMobile &&
      available;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    final window = MediaQuery.sizeOf(context);
    final maxH = window.height - 48;
    final frameH = phoneHeight.clamp(600.0, maxH);
    final frameW = phoneWidth;

    final media = MediaQuery.of(context).copyWith(
      size: Size(frameW, frameH - _chromeHeight),
      padding: const EdgeInsets.only(top: 12),
      viewPadding: EdgeInsets.zero,
      viewInsets: EdgeInsets.zero,
    );

    return ColoredBox(
      color: const Color(0xFF1A1D24),
      child: Center(
        child: Container(
          width: frameW,
          height: frameH,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(44),
            border: Border.all(color: AppColors.border, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 48,
                offset: Offset(0, 16),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: MediaQuery(
            data: media,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 120,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHighlight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                Expanded(child: child),
                Container(
                  width: 134,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: AppColors.labelTertiary.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const double _chromeHeight = 10 + 28 + 10 + 5;
}

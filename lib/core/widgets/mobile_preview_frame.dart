import 'package:flutter/material.dart';

import '../platform/app_product.dart';
import '../theme/app_colors.dart';

/// iPhone-bredde (390pt) når Ampex Mobile kjøres på web/desktop.
///
/// På ekte iOS/Android: ingen ramme — full skjerm.
class MobilePreviewFrame extends StatelessWidget {
  const MobilePreviewFrame({
    super.key,
    required this.child,
  });

  final Widget child;

  static const double phoneWidth = 390;
  static const double phoneHeight = 844;

  /// Alltid simuler på ikke-native når produktet er Mobile.
  static bool shouldSimulate(AmpexProduct product) =>
      product == AmpexProduct.mobile && !AmpexProductResolver.isNativeMobile;

  @override
  Widget build(BuildContext context) {
    final window = MediaQuery.sizeOf(context);
    final frameH = phoneHeight.clamp(520.0, window.height - 40);
    final innerH = frameH;

    final phoneMedia = MediaQuery.of(context).copyWith(
      size: Size(phoneWidth, innerH),
      padding: EdgeInsets.zero,
      viewPadding: EdgeInsets.zero,
      viewInsets: EdgeInsets.zero,
    );

    return ColoredBox(
      color: const Color(0xFF12151C),
      child: Align(
        alignment: Alignment.center,
        child: Container(
          width: phoneWidth,
          height: frameH,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: AppColors.border, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x80000000),
                blurRadius: 40,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: MediaQuery(
            data: phoneMedia,
            child: child,
          ),
        ),
      ),
    );
  }
}

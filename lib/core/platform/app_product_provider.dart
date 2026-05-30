import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/mobile_preview_frame.dart';
import 'app_product.dart';

/// Tving Mobile/Desktop i dev. `null` = automatisk etter vindusbredde.
final devProductOverrideProvider = StateProvider<AmpexProduct?>((ref) => null);

final _viewportSizeProvider = StateProvider<Size>((ref) => const Size(1280, 800));

final appProductProvider = Provider<AmpexProduct>((ref) {
  final override = ref.watch(devProductOverrideProvider);
  if (override != null) return override;
  final size = ref.watch(_viewportSizeProvider);
  return AmpexProductResolver.resolve(size.width);
});

class AmpexProductScope extends InheritedWidget {
  const AmpexProductScope({
    super.key,
    required this.product,
    required super.child,
  });

  final AmpexProduct product;

  static AmpexProduct of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AmpexProductScope>();
    if (scope != null) return scope.product;
    return AmpexProductResolver.resolve(MediaQuery.sizeOf(context).width);
  }

  @override
  bool updateShouldNotify(AmpexProductScope oldWidget) =>
      product != oldWidget.product;
}

extension AmpexProductContext on BuildContext {
  AmpexProduct get ampexProduct => AmpexProductScope.of(this);

  bool get isAmpexMobile => ampexProduct == AmpexProduct.mobile;

  bool get isAmpexDesktop => ampexProduct == AmpexProduct.desktop;

  /// Mobile på web/desktop (iPhone-ramme), ikke ekte telefon.
  bool get isSimulatedAmpexMobile =>
      isAmpexMobile && !AmpexProductResolver.isNativeMobile;
}

class AmpexProductBinder extends ConsumerWidget {
  const AmpexProductBinder({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final windowSize = MediaQuery.sizeOf(context);
    final notifier = ref.read(_viewportSizeProvider.notifier);
    final product = ref.watch(appProductProvider);
    final simulatePhone = MobilePreviewFrame.shouldSimulate(product);

    final viewportSize = simulatePhone
        ? const Size(
            MobilePreviewFrame.phoneWidth,
            MobilePreviewFrame.phoneHeight,
          )
        : windowSize;

    if (ref.read(_viewportSizeProvider) != viewportSize) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.state = viewportSize;
      });
    }

    Widget app = child;
    if (simulatePhone) {
      app = MobilePreviewFrame(child: child);
    }

    return AmpexProductScope(
      product: product,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          app,
          if (!AmpexProductResolver.isNativeMobile)
            Positioned(
              top: 8,
              left: 0,
              right: 0,
              child: Center(child: _DevProductBar(product: product)),
            ),
        ],
      ),
    );
  }
}

class _DevProductBar extends ConsumerWidget {
  const _DevProductBar({required this.product});

  final AmpexProduct product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final override = ref.watch(devProductOverrideProvider);

    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(24),
      color: const Color(0xF0111827),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _chip(
              ref,
              label: 'Auto',
              selected: override == null,
              onTap: () =>
                  ref.read(devProductOverrideProvider.notifier).state = null,
            ),
            _chip(
              ref,
              label: 'Mobile',
              selected: override == AmpexProduct.mobile,
              onTap: () => ref.read(devProductOverrideProvider.notifier).state =
                  AmpexProduct.mobile,
            ),
            _chip(
              ref,
              label: 'Desktop',
              selected: override == AmpexProduct.desktop,
              onTap: () => ref.read(devProductOverrideProvider.notifier).state =
                  AmpexProduct.desktop,
            ),
            const SizedBox(width: 8),
            Text(
              MobilePreviewFrame.shouldSimulate(product)
                  ? '390×844'
                  : 'Aktiv: ${product == AmpexProduct.mobile ? 'Mobile' : 'Desktop'}',
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(
    WidgetRef ref, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: selected ? const Color(0xFF2563EB) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF9CA3AF),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

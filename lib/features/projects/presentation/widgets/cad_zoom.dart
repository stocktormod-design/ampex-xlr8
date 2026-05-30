import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfx/pdfx.dart';

/// Zoom på PDF (trackpad: pinch eller ⌘/Ctrl + scroll mot markør).
class CadZoom {
  static void applyFactor(
    PdfControllerPinch controller,
    Offset focal,
    double factor,
  ) {
    if (factor <= 0 || factor.isNaN) return;
    final current = controller.zoomRatio;
    if (current <= 0) return;
    final target = (current * factor).clamp(0.15, 40.0);
    final scale = target / current;
    zoomAt(controller, focal, scale);
  }

  static void zoomAt(
    PdfControllerPinch controller,
    Offset focal,
    double scale,
  ) {
    if (scale <= 0 || scale.isNaN) return;
    // ignore: deprecated_member_use
    final matrix = Matrix4.copy(controller.value);
    final inverse = Matrix4.inverted(matrix);
    final before = MatrixUtils.transformPoint(inverse, focal);
    // ignore: deprecated_member_use
    matrix.scale(scale, scale, 1);
    final after = MatrixUtils.transformPoint(Matrix4.inverted(matrix), focal);
    // ignore: deprecated_member_use
    matrix.translate(before.dx - after.dx, before.dy - after.dy);
    controller.value = matrix;
  }

  static void handlePointerSignal(
    PdfControllerPinch controller,
    PointerSignalEvent event,
    Offset focal,
  ) {
    if (event is PointerScaleEvent) {
      zoomAt(controller, focal, event.scale);
      return;
    }
    if (event is PointerScrollEvent) {
      final dy = event.scrollDelta.dy;
      if (dy == 0) return;
      final meta = HardwareKeyboard.instance.isMetaPressed;
      final ctrl = HardwareKeyboard.instance.isControlPressed;
      final alt = HardwareKeyboard.instance.isAltPressed;
      if (meta || ctrl || alt) {
        applyFactor(controller, focal, dy > 0 ? 0.92 : 1.08);
        return;
      }
      if (event.kind == PointerDeviceKind.trackpad &&
          event.scrollDelta.distance < 120) {
        applyFactor(controller, focal, dy > 0 ? 0.94 : 1.06);
      }
    }
  }
}

/// Fanger pinch / scroll og zoomer mot [focal] (sist kjente markørposisjon).
class CadZoomSurface extends StatefulWidget {
  const CadZoomSurface({
    super.key,
    required this.controller,
    required this.child,
  });

  final PdfControllerPinch controller;
  final Widget child;

  @override
  State<CadZoomSurface> createState() => _CadZoomSurfaceState();
}

class _CadZoomSurfaceState extends State<CadZoomSurface> {
  Offset _focal = Offset.zero;
  bool _hasFocal = false;

  void _track(PointerEvent e) {
    _focal = e.localPosition;
    _hasFocal = true;
  }

  Offset get _zoomPoint =>
      _hasFocal ? _focal : _fallbackCenter(context);

  static Offset _fallbackCenter(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Offset(size.width * 0.5, size.height * 0.45);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerHover: _track,
      onPointerMove: _track,
      onPointerDown: _track,
      onPointerSignal: (e) {
        final focal = e is PointerScrollEvent || e is PointerScaleEvent
            ? e.localPosition
            : _zoomPoint;
        CadZoom.handlePointerSignal(widget.controller, e, focal);
      },
      child: widget.child,
    );
  }
}

/// Eksponerer siste markørposisjon for zoom-knapper i topplinjen.
mixin CadZoomFocalMixin<T extends StatefulWidget> on State<T> {
  Offset zoomFocal = Offset.zero;
  bool hasZoomFocal = false;

  void trackZoomFocal(PointerEvent e) {
    zoomFocal = e.localPosition;
    hasZoomFocal = true;
  }

  Offset zoomPoint(BuildContext context) {
    if (hasZoomFocal) return zoomFocal;
    final size = MediaQuery.sizeOf(context);
    return Offset(size.width * 0.5, size.height * 0.45);
  }
}

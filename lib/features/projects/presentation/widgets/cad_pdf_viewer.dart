import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// PDF på mørk blueprint-flate med rutenett rundt arket.
class CadPdfViewer extends StatelessWidget {
  const CadPdfViewer({
    super.key,
    required this.controller,
    this.showGrid = true,
    this.onPageChanged,
    this.onDocumentLoaded,
  });

  final PdfControllerPinch controller;
  final bool showGrid;
  final ValueChanged<int>? onPageChanged;
  final void Function(PdfDocument document)? onDocumentLoaded;

  static const _canvas = Color(0xFF0E1118);
  static const _pagePaper = Color(0xFFF4F4F0);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _canvas,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (showGrid) const CustomPaint(painter: _BlueprintGridPainter()),
          PdfViewPinch(
            controller: controller,
            padding: 0,
            minScale: 0.2,
            maxScale: 32,
            scrollDirection: Axis.vertical,
            onPageChanged: onPageChanged,
            onDocumentLoaded: onDocumentLoaded,
            backgroundDecoration: const BoxDecoration(
              color: _pagePaper,
              boxShadow: [
                BoxShadow(
                  color: Color(0x90000000),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
              options: const DefaultBuilderOptions(),
              documentLoaderBuilder: (_) => const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.accent,
                ),
              ),
              pageLoaderBuilder: (_) => const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.accent,
                ),
              ),
              errorBuilder: (_, error) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    error.toString(),
                    style: AppTypography.callout,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Blågrått blueprint-rutenett (synlig rundt PDF-arket).
class _BlueprintGridPainter extends CustomPainter {
  const _BlueprintGridPainter();

  static const _minor = Color(0xFF1A2840);
  static const _major = Color(0xFF243A5C);
  static const _accent = Color(0xFF2A4A6E);

  @override
  void paint(Canvas canvas, Size size) {
    const step = 24.0;
    final minor = Paint()
      ..color = _minor
      ..strokeWidth = 1;
    final major = Paint()
      ..color = _major
      ..strokeWidth = 1;
    final bold = Paint()
      ..color = _accent
      ..strokeWidth = 1.2;

    for (var x = 0.0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), minor);
    }
    for (var y = 0.0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), minor);
    }
    for (var x = 0.0; x <= size.width; x += step * 4) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), major);
    }
    for (var y = 0.0; y <= size.height; y += step * 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), major);
    }
    for (var x = 0.0; x <= size.width; x += step * 16) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), bold);
    }
    for (var y = 0.0; y <= size.height; y += step * 16) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), bold);
    }
  }

  @override
  bool shouldRepaint(covariant _BlueprintGridPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

import '../../domain/drawing_markup.dart';

/// Konverterer mellom skjermkoordinater og normaliserte PDF-punkter.
class MarkupCoordinateMapper {
  MarkupCoordinateMapper(this.controller);

  final PdfControllerPinch controller;

  MarkupNorm? screenToNorm(Offset screenLocal) {
    try {
      final inverse = Matrix4.inverted(controller.value);
      final doc = MatrixUtils.transformPoint(inverse, screenLocal);
      final page = controller.page;
      final rect = controller.getPageRect(page);
      if (rect == null || rect.width <= 0 || rect.height <= 0) return null;
      if (!rect.contains(doc)) return null;
      return MarkupNorm(
        page: page,
        x: ((doc.dx - rect.left) / rect.width).clamp(0.0, 1.0),
        y: ((doc.dy - rect.top) / rect.height).clamp(0.0, 1.0),
      );
    } catch (_) {
      return null;
    }
  }

  Offset? normToScreen(MarkupNorm norm) {
    if (norm.page != controller.page) return null;
    final rect = controller.getPageRect(norm.page);
    if (rect == null) return null;
    final doc = Offset(
      rect.left + norm.x * rect.width,
      rect.top + norm.y * rect.height,
    );
    return MatrixUtils.transformPoint(controller.value, doc);
  }

  Offset resolveNorm(MarkupElement el, DrawingMarkupDocument doc) {
    return switch (el) {
      MarkupDetector d => d.norm.asOffset,
      MarkupPoint p => p.norm.asOffset,
      MarkupText t => Offset(t.x, t.y),
      MarkupLine l => lineEndpoint(l, true, doc),
      MarkupRoom r => r.vertices.isNotEmpty
          ? r.vertices.first.asOffset
          : Offset.zero,
    };
  }

  Offset lineEndpoint(MarkupLine line, bool start, DrawingMarkupDocument doc) {
    if (start) {
      if (line.startId != null) {
        final el = doc.elements.where((e) => e.id == line.startId).firstOrNull;
        if (el is MarkupDetector) return el.norm.asOffset;
        if (el is MarkupPoint) return el.norm.asOffset;
      }
      return Offset(line.startX ?? 0, line.startY ?? 0);
    }
    if (line.endId != null) {
      final el = doc.elements.where((e) => e.id == line.endId).firstOrNull;
      if (el is MarkupDetector) return el.norm.asOffset;
      if (el is MarkupPoint) return el.norm.asOffset;
    }
    return Offset(line.endX ?? 0, line.endY ?? 0);
  }
}

import 'dart:ui';

import '../domain/drawing_markup.dart';

/// Trefferområde for markering på tegning.
class MarkupHitTest {
  static MarkupRoom? roomAt(
    DrawingMarkupDocument doc,
    int page,
    MarkupNorm norm, {
    double edgeThreshold = 0.04,
  }) {
    MarkupRoom? best;
    var bestDist = double.infinity;
    for (final el in doc.elements) {
      if (el is! MarkupRoom || el.page != page) continue;
      if (_pointInPolygon(norm.asOffset, el.vertices)) return el;
      final d = _distanceToPolygon(norm.asOffset, el.vertices);
      if (d < edgeThreshold && d < bestDist) {
        bestDist = d;
        best = el;
      }
    }
    return best;
  }

  static MarkupDetector? detectorAt(
    DrawingMarkupDocument doc,
    int page,
    MarkupNorm norm, {
    double threshold = 0.035,
  }) {
    MarkupDetector? best;
    var bestDist = threshold;
    for (final el in doc.elements) {
      if (el is! MarkupDetector || el.page != page) continue;
      final d = (Offset(el.x, el.y) - norm.asOffset).distance;
      if (d < bestDist) {
        bestDist = d;
        best = el;
      }
    }
    return best;
  }

  static MarkupElement? elementAt(
    DrawingMarkupDocument doc,
    int page,
    MarkupNorm norm,
  ) {
    final det = detectorAt(doc, page, norm);
    if (det != null) return det;
    final room = roomAt(doc, page, norm);
    if (room != null) return room;
    for (final el in doc.elements) {
      if (el.page != page) continue;
      if (el is MarkupPoint) {
        if ((Offset(el.x, el.y) - norm.asOffset).distance < 0.025) return el;
      }
      if (el is MarkupText) {
        if ((Offset(el.x, el.y) - norm.asOffset).distance < 0.03) return el;
      }
    }
    return null;
  }

  static bool _pointInPolygon(Offset p, List<MarkupNorm> vertices) {
    if (vertices.length < 3) return false;
    var inside = false;
    for (var i = 0, j = vertices.length - 1; i < vertices.length; j = i++) {
      final xi = vertices[i].x;
      final yi = vertices[i].y;
      final xj = vertices[j].x;
      final yj = vertices[j].y;
      final intersect = ((yi > p.dy) != (yj > p.dy)) &&
          (p.dx < (xj - xi) * (p.dy - yi) / (yj - yi + 1e-12) + xi);
      if (intersect) inside = !inside;
    }
    return inside;
  }

  static double _distanceToPolygon(Offset p, List<MarkupNorm> vertices) {
    if (vertices.isEmpty) return double.infinity;
    var min = double.infinity;
    for (var i = 0; i < vertices.length; i++) {
      final a = vertices[i].asOffset;
      final b = vertices[(i + 1) % vertices.length].asOffset;
      min = min < _distToSegment(p, a, b) ? min : _distToSegment(p, a, b);
    }
    return min;
  }

  static double _distToSegment(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final t = ((p - a).dx * ab.dx + (p - a).dy * ab.dy) /
        (ab.dx * ab.dx + ab.dy * ab.dy + 1e-12);
    final clamped = t.clamp(0.0, 1.0);
    final proj = Offset(a.dx + ab.dx * clamped, a.dy + ab.dy * clamped);
    return (p - proj).distance;
  }
}

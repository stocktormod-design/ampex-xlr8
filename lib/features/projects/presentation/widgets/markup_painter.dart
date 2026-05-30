import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/drawing_markup.dart';
import '../markup_providers.dart';
import 'markup_coordinate_mapper.dart';

class MarkupPainter extends CustomPainter {
  MarkupPainter({
    required this.controller,
    required this.mapper,
    required this.document,
    required this.currentPage,
    this.chain,
    this.chainPreview,
    this.roomDraft,
    this.roomPreviewCorner,
    this.selectedIds = const {},
  });

  final PdfControllerPinch controller;
  final MarkupCoordinateMapper mapper;
  final DrawingMarkupDocument document;
  final int currentPage;
  final MarkupChainDraft? chain;
  final MarkupNorm? chainPreview;
  final List<Offset>? roomDraft;
  final Offset? roomPreviewCorner;
  final Set<String> selectedIds;

  @override
  void paint(Canvas canvas, Size size) {
    for (final el in document.elements) {
      if (el.page != currentPage) continue;
      final selected = selectedIds.contains(el.id);
      if (selected) _paintSelectionHalo(canvas, el);
      switch (el) {
        case MarkupDetector d:
          _paintDetector(canvas, d);
        case MarkupPoint p:
          _paintPoint(canvas, p);
        case MarkupLine l:
          _paintLine(canvas, l);
        case MarkupText t:
          _paintText(canvas, t);
        case MarkupRoom r:
          _paintRoom(canvas, r);
      }
    }

    _paintChainPreview(canvas);

    if (roomDraft != null && roomDraft!.isNotEmpty) {
      final points = roomDraft!.map(_normToScreen).whereType<Offset>().toList();
      if (roomPreviewCorner != null) {
        final p = _normToScreen(roomPreviewCorner!);
        if (p != null) points.add(p);
      }
      if (points.length >= 2) {
        final path = Path()..moveTo(points.first.dx, points.first.dy);
        for (var i = 1; i < points.length; i++) {
          path.lineTo(points[i].dx, points[i].dy);
        }
        canvas.drawPath(
          path,
          Paint()
            ..color = const Color(0xFF34D399).withValues(alpha: 0.35)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }
  }

  void _paintSelectionHalo(Canvas canvas, MarkupElement el) {
    final c = switch (el) {
      MarkupDetector d => _normToScreen(d.norm.asOffset),
      MarkupPoint p => _normToScreen(p.norm.asOffset),
      MarkupText t => _normToScreen(Offset(t.x, t.y)),
      MarkupRoom r => _normToScreen(r.vertices.first.asOffset),
      MarkupLine l => _normToScreen(mapper.lineEndpoint(l, true, document)),
    };
    if (c == null) return;
    canvas.drawCircle(
      c,
      14,
      Paint()
        ..color = AppColors.accent.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _paintChainPreview(Canvas canvas) {
    if (chain == null || chain!.nodes.isEmpty) return;
    final notifier = _ChainOffsetResolver(document);
    final points = <Offset>[];
    for (final n in chain!.nodes) {
      final o = notifier.offsetFor(n);
      final s = _normToScreen(o);
      if (s != null) points.add(s);
    }
    if (chainPreview != null) {
      final s = _normToScreen(chainPreview!.asOffset);
      if (s != null) points.add(s);
    }
    if (points.length < 2) {
      if (points.length == 1) {
        canvas.drawCircle(
          points.first,
          6,
          Paint()..color = AppColors.accent.withValues(alpha: 0.5),
        );
      }
      return;
    }
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.accent.withValues(alpha: 0.85)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );
  }

  static const _detectorRadius = 8.0;

  void _paintDetector(Canvas canvas, MarkupDetector d) {
    final c = _normToScreen(d.norm.asOffset);
    if (c == null) return;
    final r = _detectorRadius;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = const Color(0xFFE85D04).withValues(alpha: 0.35)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = const Color(0xFFE85D04)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(
      c,
      2.5,
      Paint()..color = const Color(0xFFE85D04),
    );
    if (d.label != null && d.label!.isNotEmpty) {
      _drawLabel(canvas, c + Offset(r + 4, -6), d.label!);
    }
  }

  void _paintPoint(Canvas canvas, MarkupPoint p) {
    final c = _normToScreen(p.norm.asOffset);
    if (c == null) return;
    final r = Rect.fromCenter(center: c, width: 10, height: 10);
    canvas.drawRect(r, Paint()..color = AppColors.accent);
    canvas.drawRect(
      r.inflate(1),
      Paint()
        ..color = AppColors.onAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _paintLine(Canvas canvas, MarkupLine l) {
    final a = _normToScreen(mapper.lineEndpoint(l, true, document));
    final b = _normToScreen(mapper.lineEndpoint(l, false, document));
    if (a == null || b == null) return;
    final attached = l.startId != null || l.endId != null;
    canvas.drawLine(
      a,
      b,
      Paint()
        ..color = attached ? AppColors.accent : AppColors.labelSecondary
        ..strokeWidth = attached ? 2.5 : 1.5
        ..style = PaintingStyle.stroke,
    );
  }

  void _paintText(Canvas canvas, MarkupText t) {
    final c = _normToScreen(Offset(t.x, t.y));
    if (c == null) return;
    _drawLabel(canvas, c, t.text);
  }

  void _paintRoom(Canvas canvas, MarkupRoom r) {
    final points =
        r.vertices.map((v) => _normToScreen(v.asOffset)).whereType<Offset>().toList();
    if (points.length < 3) return;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();

    final hasStatus = r.status.sokkelMontert ||
        r.status.detektorMontert ||
        r.status.serienummer != null;
    final fillAlpha = hasStatus ? 0.22 : 0.12;

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF34D399).withValues(alpha: fillAlpha)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF34D399)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    if (r.name != null && r.name!.isNotEmpty && points.isNotEmpty) {
      _drawLabel(canvas, points.first + const Offset(4, -14), r.name!);
    }
    if (points.isNotEmpty) {
      final c = _centroid(points);
      final lines = <String>[];
      if (r.name != null && r.name!.isNotEmpty) lines.add(r.name!);
      lines.add(
        'S${r.progress.sterkstrom}% · Sv${r.progress.svakstrom}% · A${r.progress.automasjon}% · B${r.progress.brann}%',
      );
      _drawLabel(canvas, c, lines.join('\n'));
    }
  }

  Offset _centroid(List<Offset> points) {
    var x = 0.0;
    var y = 0.0;
    for (final p in points) {
      x += p.dx;
      y += p.dy;
    }
    return Offset(x / points.length, y / points.length);
  }

  void _drawLabel(Canvas canvas, Offset at, String text) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFF1C2434),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final bg = RRect.fromRectAndRadius(
      Rect.fromLTWH(at.dx, at.dy, tp.width + 8, tp.height + 4),
      const Radius.circular(4),
    );
    canvas.drawRRect(bg, Paint()..color = const Color(0xE6FFFFFF));
    canvas.drawRRect(
      bg,
      Paint()
        ..color = const Color(0xFFDCE3EE)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    tp.paint(canvas, at + const Offset(4, 2));
  }

  Offset? _normToScreen(Offset norm) {
    return mapper.normToScreen(
      MarkupNorm(page: currentPage, x: norm.dx, y: norm.dy),
    );
  }

  @override
  bool shouldRepaint(covariant MarkupPainter old) => true;
}

class _ChainOffsetResolver {
  _ChainOffsetResolver(this.document);

  final DrawingMarkupDocument document;

  Offset offsetFor(MarkupChainNode node) {
    if (node.detectorId != null) {
      for (final el in document.elements) {
        if (el is MarkupDetector && el.id == node.detectorId) {
          return Offset(el.x, el.y);
        }
      }
    }
    return Offset(node.x!, node.y!);
  }
}

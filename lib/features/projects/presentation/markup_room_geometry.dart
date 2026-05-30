import '../domain/drawing_markup.dart';

/// Ortogonale (90°) hjørner for rom-tegning.
class MarkupRoomGeometry {
  /// Snapper neste hjørne til horisontal/vertikal relativt forrige punkt.
  static MarkupNorm snapOrthogonalCorner(
    List<MarkupNorm> draft,
    MarkupNorm raw,
  ) {
    if (draft.isEmpty) return raw;
    if (draft.length == 1) {
      final a = draft.first;
      final dx = (raw.x - a.x).abs();
      final dy = (raw.y - a.y).abs();
      if (dx >= dy) {
        return MarkupNorm(page: raw.page, x: raw.x, y: a.y);
      }
      return MarkupNorm(page: raw.page, x: a.x, y: raw.y);
    }

    final prev = draft.last;
    final before = draft[draft.length - 2];
    final horizontalLeg =
        (prev.y - before.y).abs() <= (prev.x - before.x).abs();
    if (horizontalLeg) {
      return MarkupNorm(page: raw.page, x: prev.x, y: raw.y);
    }
    return MarkupNorm(page: raw.page, x: raw.x, y: prev.y);
  }

  /// Fire ortogonale hjørner → lukket rektangel (sortert).
  static List<MarkupNorm> asOrthogonalRectangle(List<MarkupNorm> corners) {
    if (corners.length < 4) return corners;
    final xs = corners.map((c) => c.x).toList()..sort();
    final ys = corners.map((c) => c.y).toList()..sort();
    final page = corners.first.page;
    final minX = xs.first;
    final maxX = xs.last;
    final minY = ys.first;
    final maxY = ys.last;
    return [
      MarkupNorm(page: page, x: minX, y: minY),
      MarkupNorm(page: page, x: maxX, y: minY),
      MarkupNorm(page: page, x: maxX, y: maxY),
      MarkupNorm(page: page, x: minX, y: maxY),
    ];
  }
}

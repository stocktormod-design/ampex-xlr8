import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/markup_repository.dart';
import '../domain/drawing_markup.dart';

final drawingMarkupProvider = StateNotifierProvider.autoDispose
    .family<DrawingMarkupNotifier, DrawingMarkupDocument, String>(
        (ref, drawingId) {
  final repo = ref.watch(markupRepositoryProvider);
  return DrawingMarkupNotifier(drawingId, repo);
});

/// Pågående rom-polygon (ikke persistert før fullført).
final markupRoomDraftProvider = StateProvider.autoDispose
    .family<List<MarkupNorm>, String>((ref, drawingId) => []);

/// Node i en pågående sløyfe/kjede.
class MarkupChainNode {
  const MarkupChainNode({this.detectorId, this.x, this.y})
      : assert(detectorId != null || (x != null && y != null));

  final String? detectorId;
  final double? x;
  final double? y;
}

/// Pågående kabelkjede / sløyfe.
class MarkupChainDraft {
  const MarkupChainDraft({
    required this.page,
    required this.nodes,
    this.preview,
  });

  final int page;
  final List<MarkupChainNode> nodes;
  final MarkupNorm? preview;

  MarkupChainDraft copyWith({
    List<MarkupChainNode>? nodes,
    MarkupNorm? preview,
    bool clearPreview = false,
  }) =>
      MarkupChainDraft(
        page: page,
        nodes: nodes ?? this.nodes,
        preview: clearPreview ? null : (preview ?? this.preview),
      );
}

final markupChainDraftProvider = StateProvider.autoDispose
    .family<MarkupChainDraft?, String>((ref, drawingId) => null);

/// Valgte element-IDer (select-verktøy).
final markupSelectionProvider = StateProvider.autoDispose
    .family<Set<String>, String>((ref, drawingId) => {});

void clearMarkupDrafts(WidgetRef ref, String drawingId) {
  ref.read(markupRoomDraftProvider(drawingId).notifier).state = [];
  ref.read(markupChainDraftProvider(drawingId).notifier).state = null;
}

void clearMarkupSelection(WidgetRef ref, String drawingId) {
  ref.read(markupSelectionProvider(drawingId).notifier).state = {};
}

Future<void> finishMarkupRoom(
  WidgetRef ref,
  String drawingId,
  int page, {
  String? name,
}) async {
  final draft = ref.read(markupRoomDraftProvider(drawingId));
  if (draft.length < 3) return;
  await ref
      .read(drawingMarkupProvider(drawingId).notifier)
      .addRoom(page, draft, name: name);
  ref.read(markupRoomDraftProvider(drawingId).notifier).state = [];
}

Future<void> closeMarkupChain(WidgetRef ref, String drawingId) async {
  final chain = ref.read(markupChainDraftProvider(drawingId));
  if (chain == null || chain.nodes.length < 2) return;
  final notifier = ref.read(drawingMarkupProvider(drawingId).notifier);
  final first = chain.nodes.first;
  final last = chain.nodes.last;
  await notifier.addLineBetweenNodes(
    page: chain.page,
    from: last,
    to: first,
  );
  ref.read(markupChainDraftProvider(drawingId).notifier).state = null;
}

Future<void> undoMarkup(WidgetRef ref, String drawingId) async {
  clearMarkupDrafts(ref, drawingId);
  await ref.read(drawingMarkupProvider(drawingId).notifier).removeLast();
}

class DrawingMarkupNotifier extends StateNotifier<DrawingMarkupDocument> {
  DrawingMarkupNotifier(this._drawingId, this._repo)
      : super(DrawingMarkupDocument(drawingId: _drawingId, elements: [])) {
    _load();
  }

  final String _drawingId;
  final MarkupRepository _repo;
  final _uuid = const Uuid();

  Future<void> _load() async {
    final doc = await _repo.load(_drawingId);
    if (doc.elements.isNotEmpty &&
        doc.publishedAt == null &&
        doc.revision == 0) {
      state = doc.copyWith(revision: 1);
    } else {
      state = doc;
    }
  }

  Future<void> _persist() => _repo.save(state);

  void _bumpRevision() {
    state = state.copyWith(revision: state.revision + 1);
  }

  String _newId() => _uuid.v4();

  MarkupDetector? detectorById(String id) {
    for (final el in state.elements) {
      if (el is MarkupDetector && el.id == id) return el;
    }
    return null;
  }

  Offset nodeOffset(MarkupChainNode node) {
    if (node.detectorId != null) {
      final d = detectorById(node.detectorId!);
      if (d != null) return Offset(d.x, d.y);
    }
    return Offset(node.x!, node.y!);
  }

  Future<void> publish() async {
    state = state.copyWith(
      publishedRevision: state.revision,
      publishedAt: DateTime.now().toUtc(),
    );
    await _persist();
  }

  Future<void> addDetector(MarkupNorm norm, {String? label}) async {
    _bumpRevision();
    state = state.copyWith(
      elements: [
        ...state.elements,
        MarkupDetector(
          id: _newId(),
          page: norm.page,
          x: norm.x,
          y: norm.y,
          label: label,
        ),
      ],
    );
    await _persist();
  }

  Future<void> addPoint(MarkupNorm norm) async {
    _bumpRevision();
    state = state.copyWith(
      elements: [
        ...state.elements,
        MarkupPoint(id: _newId(), page: norm.page, x: norm.x, y: norm.y),
      ],
    );
    await _persist();
  }

  Future<void> addLineBetweenNodes({
    required int page,
    required MarkupChainNode from,
    required MarkupChainNode to,
  }) async {
    _bumpRevision();
    state = state.copyWith(
      elements: [
        ...state.elements,
        MarkupLine(
          id: _newId(),
          page: page,
          startId: from.detectorId,
          endId: to.detectorId,
          startX: from.detectorId == null ? from.x : null,
          startY: from.detectorId == null ? from.y : null,
          endX: to.detectorId == null ? to.x : null,
          endY: to.detectorId == null ? to.y : null,
        ),
      ],
    );
    await _persist();
  }

  Future<void> addText(MarkupNorm norm, String text) async {
    _bumpRevision();
    state = state.copyWith(
      elements: [
        ...state.elements,
        MarkupText(
          id: _newId(),
          page: norm.page,
          x: norm.x,
          y: norm.y,
          text: text,
        ),
      ],
    );
    await _persist();
  }

  Future<void> addRoom(int page, List<MarkupNorm> vertices, {String? name}) async {
    if (vertices.length < 3) return;
    _bumpRevision();
    state = state.copyWith(
      elements: [
        ...state.elements,
        MarkupRoom(
          id: _newId(),
          page: page,
          vertices: vertices,
          name: name,
        ),
      ],
    );
    await _persist();
  }

  Future<void> updateRoom(
    String roomId, {
    MarkupRoomStatus? status,
    MarkupRoomProgress? progress,
    String? name,
    DateTime? lidarRequestedAt,
  }) async {
    final idx = state.elements.indexWhere((e) => e.id == roomId);
    if (idx < 0) return;
    final el = state.elements[idx];
    if (el is! MarkupRoom) return;
    _bumpRevision();
    final updated = [...state.elements];
    updated[idx] = el.copyWith(
      status: status,
      progress: progress,
      name: name,
      lidarRequestedAt: lidarRequestedAt,
    );
    state = state.copyWith(elements: updated);
    await _persist();
  }

  Future<void> updateDetectorStatus(
    String detectorId,
    MarkupDetectorStatus status,
  ) async {
    final idx = state.elements.indexWhere((e) => e.id == detectorId);
    if (idx < 0) return;
    final el = state.elements[idx];
    if (el is! MarkupDetector) return;
    _bumpRevision();
    final updated = [...state.elements];
    updated[idx] = el.copyWith(status: status);
    state = state.copyWith(elements: updated);
    await _persist();
  }

  Future<void> deleteElements(Set<String> ids) async {
    if (ids.isEmpty) return;
    _bumpRevision();
    state = state.copyWith(
      elements: state.elements.where((e) => !ids.contains(e.id)).toList(),
    );
    await _persist();
  }

  Future<void> removeLast() async {
    if (state.elements.isEmpty) return;
    _bumpRevision();
    state = state.copyWith(
      elements: state.elements.sublist(0, state.elements.length - 1),
    );
    await _persist();
  }

  MarkupDetector? findSnapDetector(MarkupNorm norm, {double threshold = 0.03}) {
    MarkupDetector? best;
    var bestDist = threshold;
    for (final el in state.elements) {
      if (el is! MarkupDetector || el.page != norm.page) continue;
      final d = (Offset(el.x, el.y) - norm.asOffset).distance;
      if (d < bestDist) {
        bestDist = d;
        best = el;
      }
    }
    return best;
  }
}

/// Linje-verktøy: kjed til neste punkt; detektor→detektor lukker sløyfe.
Future<void> handleLineToolTap(
  WidgetRef ref,
  String drawingId,
  MarkupNorm norm,
) async {
  final markup = ref.read(drawingMarkupProvider(drawingId).notifier);
  final snap = markup.findSnapDetector(norm);
  final current = MarkupChainNode(
    detectorId: snap?.id,
    x: snap == null ? norm.x : null,
    y: snap == null ? norm.y : null,
  );

  final chain = ref.read(markupChainDraftProvider(drawingId));
  if (chain == null || chain.nodes.isEmpty) {
    ref.read(markupChainDraftProvider(drawingId).notifier).state =
        MarkupChainDraft(page: norm.page, nodes: [current]);
    return;
  }

  final nodes = chain.nodes;
  final last = nodes.last;
  await markup.addLineBetweenNodes(page: chain.page, from: last, to: current);

  final first = nodes.first;
  final firstIsDetector = first.detectorId != null;
  final currentIsDetector = snap != null;

  if (firstIsDetector && currentIsDetector && nodes.length == 1) {
    ref.read(markupChainDraftProvider(drawingId).notifier).state = null;
    return;
  }

  if (currentIsDetector &&
      snap.id == first.detectorId &&
      nodes.length >= 2) {
    await markup.addLineBetweenNodes(
      page: chain.page,
      from: current,
      to: first,
    );
    ref.read(markupChainDraftProvider(drawingId).notifier).state = null;
    return;
  }

  ref.read(markupChainDraftProvider(drawingId).notifier).state =
      MarkupChainDraft(page: chain.page, nodes: [...nodes, current]);
}

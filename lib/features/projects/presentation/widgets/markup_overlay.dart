import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/drawing_markup.dart';
import '../markup_hit_test.dart';
import '../markup_providers.dart';
import '../markup_room_geometry.dart';
import 'cad_tool.dart';
import 'detector_status_sheet.dart';
import 'markup_coordinate_mapper.dart';
import 'markup_painter.dart';
import 'room_status_sheet.dart';

/// Markeringlag: én finger = verktøy, to fingre = zoom på PDF.
class MarkupOverlay extends ConsumerStatefulWidget {
  const MarkupOverlay({
    super.key,
    required this.controller,
    required this.drawingId,
    required this.projectId,
    required this.projectLabel,
    required this.tool,
  });

  final PdfControllerPinch controller;
  final String drawingId;
  final String projectId;
  final String projectLabel;
  final CadTool tool;

  @override
  ConsumerState<MarkupOverlay> createState() => _MarkupOverlayState();
}

class _MarkupOverlayState extends ConsumerState<MarkupOverlay> {
  int _pointerCount = 0;
  Offset? _previewLocal;
  Timer? _longPressTimer;
  Offset? _pressOrigin;
  bool _longPressHandled = false;

  @override
  void dispose() {
    _longPressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapper = MarkupCoordinateMapper(widget.controller);
    final passGesturesToPdf = _pointerCount >= 2;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerMove: (e) {
        if (_pressOrigin != null &&
            (e.localPosition - _pressOrigin!).distance > 14) {
          _longPressTimer?.cancel();
        }
      },
      onPointerDown: (e) {
        setState(() => _pointerCount++);
        if (_pointerCount == 1) {
          _pressOrigin = e.localPosition;
          _longPressHandled = false;
          _longPressTimer?.cancel();
          _longPressTimer = Timer(const Duration(milliseconds: 480), () {
            if (!mounted || _pressOrigin == null || _longPressHandled) return;
            _longPressHandled = true;
            HapticFeedback.mediumImpact();
            final origin = _pressOrigin!;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              _handleLongPress(context, mapper, origin);
            });
          });
        }
      },
      onPointerUp: (e) {
        _longPressTimer?.cancel();
        if (_pointerCount == 1 &&
            !_longPressHandled &&
            _pressOrigin != null &&
            !_isRoomCheckmarkHit(e.localPosition, mapper)) {
          final moved = (e.localPosition - _pressOrigin!).distance;
          if (moved < 18) {
            _handleTap(context, mapper, e.localPosition);
          }
        }
        setState(() {
          _pointerCount = (_pointerCount - 1).clamp(0, 10);
          if (_pointerCount == 0) {
            _previewLocal = null;
            _pressOrigin = null;
          }
        });
      },
      onPointerCancel: (_) {
        _longPressTimer?.cancel();
        setState(() {
          _pointerCount = (_pointerCount - 1).clamp(0, 10);
          _pressOrigin = null;
        });
      },
      child: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          final doc = ref.watch(drawingMarkupProvider(widget.drawingId));
          final chain = ref.watch(markupChainDraftProvider(widget.drawingId));
          final roomDraft = ref.watch(markupRoomDraftProvider(widget.drawingId));
          final selection =
              ref.watch(markupSelectionProvider(widget.drawingId));
          final page = widget.controller.page;

          MarkupNorm? chainPreview;
          if (_previewLocal != null && chain != null && chain.nodes.isNotEmpty) {
            chainPreview = mapper.screenToNorm(_previewLocal!);
          }

          MarkupNorm? roomPreviewNorm;
          if (_previewLocal != null &&
              widget.tool == CadTool.room &&
              roomDraft.isNotEmpty) {
            final raw = mapper.screenToNorm(_previewLocal!);
            if (raw != null) {
              roomPreviewNorm =
                  MarkupRoomGeometry.snapOrthogonalCorner(roomDraft, raw);
            }
          }

          final painted = CustomPaint(
            painter: MarkupPainter(
              controller: widget.controller,
              mapper: mapper,
              document: doc,
              currentPage: page,
              chain: chain,
              chainPreview: chainPreview,
              roomDraft: widget.tool == CadTool.room && roomDraft.isNotEmpty
                  ? roomDraft.map((n) => n.asOffset).toList()
                  : null,
              roomPreviewCorner: roomPreviewNorm?.asOffset,
              selectedIds: selection,
            ),
            child: const SizedBox.expand(),
          );

          final stack = Stack(
            fit: StackFit.expand,
            children: [
              painted,
              if (widget.tool == CadTool.room && roomDraft.isNotEmpty)
                ..._roomCornerMarkers(mapper, roomDraft, page),
              if (widget.tool == CadTool.room && roomDraft.length >= 3)
                ..._roomFinishCheckmark(mapper, roomDraft.last, page, context),
            ],
          );

          // Pan / pinch: la PDF ta drag og zoom (overlay tegner kun).
          if (passGesturesToPdf || widget.tool == CadTool.pan) {
            return IgnorePointer(ignoring: true, child: stack);
          }

          return Listener(
            behavior: HitTestBehavior.translucent,
            onPointerMove: (e) {
              if (widget.tool == CadTool.line &&
                  chain != null &&
                  chain.nodes.isNotEmpty &&
                  e.buttons == 1) {
                setState(() => _previewLocal = e.localPosition);
              }
              if (widget.tool == CadTool.room && roomDraft.isNotEmpty) {
                setState(() => _previewLocal = e.localPosition);
              }
            },
            child: stack,
          );
        },
      ),
    );
  }

  bool _isRoomCheckmarkHit(Offset local, MarkupCoordinateMapper mapper) {
    if (widget.tool != CadTool.room) return false;
    final draft = ref.read(markupRoomDraftProvider(widget.drawingId));
    if (draft.length < 3) return false;
    final screen = mapper.normToScreen(draft.last);
    if (screen == null) return false;
    final checkCenter = screen + const Offset(28, -28);
    return (local - checkCenter).distance < 28;
  }

  List<Widget> _roomCornerMarkers(
    MarkupCoordinateMapper mapper,
    List<MarkupNorm> draft,
    int page,
  ) {
    return [
      for (var i = 0; i < draft.length; i++)
        if (mapper.normToScreen(draft[i]) case final screen?)
          Positioned(
            left: screen.dx - 8,
            top: screen.dy - 8,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFF34D399),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
    ];
  }

  List<Widget> _roomFinishCheckmark(
    MarkupCoordinateMapper mapper,
    MarkupNorm last,
    int page,
    BuildContext context,
  ) {
    final screen = mapper.normToScreen(last);
    if (screen == null) return [];
    final pos = screen + const Offset(20, -32);
    return [
      Positioned(
        left: pos.dx,
        top: pos.dy,
        child: Material(
          color: AppColors.accent,
          elevation: 4,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => _confirmFinishRoom(context),
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.check, color: AppColors.onAccent, size: 26),
            ),
          ),
        ),
      ),
    ];
  }

  Future<void> _confirmFinishRoom(BuildContext context) => confirmRoomDraft(
        context,
        ref,
        drawingId: widget.drawingId,
        page: widget.controller.page,
      );

  void _handleTap(
    BuildContext context,
    MarkupCoordinateMapper mapper,
    Offset localPosition,
  ) {
    if (_isRoomCheckmarkHit(localPosition, mapper)) {
      _confirmFinishRoom(context);
      return;
    }

    final norm = mapper.screenToNorm(localPosition);
    if (norm == null) return;
    final drawingId = widget.drawingId;

    switch (widget.tool) {
      case CadTool.pan:
        break;
      case CadTool.select:
        _handleSelectTap(norm);
        break;
      case CadTool.detector:
        ref.read(drawingMarkupProvider(drawingId).notifier).addDetector(norm);
        break;
      case CadTool.point:
        ref.read(drawingMarkupProvider(drawingId).notifier).addPoint(norm);
        break;
      case CadTool.line:
        handleLineToolTap(ref, drawingId, norm);
        setState(() => _previewLocal = null);
        break;
      case CadTool.text:
        _handleTextTap(context, norm);
        break;
      case CadTool.room:
        final draft = ref.read(markupRoomDraftProvider(drawingId));
        final snapped = MarkupRoomGeometry.snapOrthogonalCorner(draft, norm);
        ref.read(markupRoomDraftProvider(drawingId).notifier).state = [
          ...draft,
          snapped,
        ];
    }
  }

  void _handleSelectTap(MarkupNorm norm) {
    final doc = ref.read(drawingMarkupProvider(widget.drawingId));
    final el = MarkupHitTest.elementAt(
      doc,
      widget.controller.page,
      norm,
    );
    if (el == null) {
      ref.read(markupSelectionProvider(widget.drawingId).notifier).state = {};
      return;
    }
    final current = ref.read(markupSelectionProvider(widget.drawingId));
    final next = Set<String>.from(current);
    if (next.contains(el.id)) {
      next.remove(el.id);
    } else {
      next.add(el.id);
    }
    ref.read(markupSelectionProvider(widget.drawingId).notifier).state = next;
  }

  void _handleLongPress(
    BuildContext context,
    MarkupCoordinateMapper mapper,
    Offset localPosition,
  ) {
    final norm = mapper.screenToNorm(localPosition);
    if (norm == null) return;
    final doc = ref.read(drawingMarkupProvider(widget.drawingId));
    final page = widget.controller.page;

    final detector = MarkupHitTest.detectorAt(doc, page, norm);
    if (detector != null) {
      unawaited(showDetectorStatusSheet(
        context: context,
        ref: ref,
        drawingId: widget.drawingId,
        detector: detector,
      ));
      return;
    }

    final room = MarkupHitTest.roomAt(doc, page, norm);
    if (room != null) {
      unawaited(showRoomStatusSheet(
        context: context,
        ref: ref,
        drawingId: widget.drawingId,
        projectId: widget.projectId,
        projectLabel: widget.projectLabel,
        room: room,
      ));
    } else {
      _longPressHandled = false;
    }
  }

  Future<void> _handleTextTap(BuildContext context, MarkupNorm norm) async {
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => const _TextInputDialog(initial: 'Merknad'),
    );
    if (text == null || text.trim().isEmpty) return;
    await ref
        .read(drawingMarkupProvider(widget.drawingId).notifier)
        .addText(norm, text.trim());
  }
}

/// Fullfør romutkast med navn og 90°-rektangel.
Future<void> confirmRoomDraft(
  BuildContext context,
  WidgetRef ref, {
  required String drawingId,
  required int page,
}) async {
  var draft = List<MarkupNorm>.from(ref.read(markupRoomDraftProvider(drawingId)));
  if (draft.length < 3) return;
  if (draft.length >= 4) {
    draft = MarkupRoomGeometry.asOrthogonalRectangle(draft);
  }
  final name = await showDialog<String>(
    context: context,
    builder: (ctx) => _RoomNameDialog(),
  );
  if (!context.mounted) return;
  if (name == null) return;
  await ref.read(drawingMarkupProvider(drawingId).notifier).addRoom(
        page,
        draft,
        name: name.trim().isEmpty ? null : name.trim(),
      );
  ref.read(markupRoomDraftProvider(drawingId).notifier).state = [];
}

class _RoomNameDialog extends StatefulWidget {
  @override
  State<_RoomNameDialog> createState() => _RoomNameDialogState();
}

class _RoomNameDialogState extends State<_RoomNameDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Romnavn'),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'F.eks. Soverom 1',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Avbryt'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _ctrl.text),
          child: const Text('Lagre rom'),
        ),
      ],
    );
  }
}

class _TextInputDialog extends StatelessWidget {
  const _TextInputDialog({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    final ctrl = TextEditingController(text: initial);
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Tekst'),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Skriv merknad…',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Avbryt'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, ctrl.text),
          child: const Text('Legg til'),
        ),
      ],
    );
  }
}

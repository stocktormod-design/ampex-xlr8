import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';

import '../../../presentation/markup_providers.dart';
import '../../../presentation/widgets/cad_pdf_viewer.dart';
import '../../../presentation/widgets/cad_tool.dart';
import '../../../presentation/widgets/cad_zoom.dart';
import '../../../presentation/widgets/markup_overlay.dart';
import '../../../presentation/widgets/markup_status_theme.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';

/// Felt: fullskjerm PDF + verktøy nederst, rom/detektor som hvite sheets.
class FieldDrawingWorkspace extends ConsumerStatefulWidget {
  const FieldDrawingWorkspace({
    super.key,
    required this.drawingId,
    required this.projectId,
    required this.projectLabel,
    required this.title,
    required this.controller,
    required this.onBack,
    this.fromCache = false,
  });

  final String drawingId;
  final String projectId;
  final String projectLabel;
  final String title;
  final PdfControllerPinch controller;
  final VoidCallback onBack;
  final bool fromCache;

  @override
  ConsumerState<FieldDrawingWorkspace> createState() =>
      _FieldDrawingWorkspaceState();
}

class _FieldDrawingWorkspaceState extends ConsumerState<FieldDrawingWorkspace>
    with CadZoomFocalMixin {
  CadTool _tool = CadTool.pan;
  int _zoomPercent = 100;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTransform);
    widget.controller.loadingState.addListener(_onLoading);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTransform);
    widget.controller.loadingState.removeListener(_onLoading);
    super.dispose();
  }

  void _onLoading() {
    if (widget.controller.loadingState.value == PdfLoadingState.success) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitWidth());
    }
  }

  void _onTransform() {
    final z = widget.controller.zoomRatio;
    if (z.isNaN || z <= 0) return;
    final pct = (z * 100).round();
    if (pct != _zoomPercent) setState(() => _zoomPercent = pct);
  }

  Future<void> _fitWidth() async {
    final matrix = widget.controller.calculatePageFitMatrix(
      pageNumber: widget.controller.page,
      padding: 8,
    );
    if (matrix != null) {
      await widget.controller.goTo(
        destination: matrix,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _zoomBy(double factor) {
    CadZoom.applyFactor(widget.controller, zoomPoint(context), factor);
  }

  void _selectTool(CadTool tool) {
    if (tool != CadTool.room && tool != CadTool.line) {
      clearMarkupDrafts(ref, widget.drawingId);
    }
    setState(() => _tool = tool);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return ColoredBox(
      color: AppColors.cadCanvas,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Listener(
            onPointerHover: trackZoomFocal,
            onPointerMove: trackZoomFocal,
            onPointerDown: trackZoomFocal,
            child: CadZoomSurface(
              controller: widget.controller,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  IgnorePointer(
                    ignoring: _tool != CadTool.pan,
                    child: CadPdfViewer(
                      controller: widget.controller,
                      onDocumentLoaded: (_) {
                        WidgetsBinding.instance
                            .addPostFrameCallback((_) => _fitWidth());
                      },
                    ),
                  ),
                  MarkupOverlay(
                    controller: widget.controller,
                    drawingId: widget.drawingId,
                    projectId: widget.projectId,
                    projectLabel: widget.projectLabel,
                    tool: _tool,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _TopBar(
              title: widget.title,
              fromCache: widget.fromCache,
              zoomPercent: _zoomPercent,
              onBack: widget.onBack,
              onZoomOut: () => _zoomBy(0.8),
              onZoomIn: () => _zoomBy(1.25),
              onFit: _fitWidth,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomTools(
              tool: _tool,
              bottomInset: bottom,
              onSelect: _selectTool,
              onFinishRoom: () => confirmRoomDraft(
                context,
                ref,
                drawingId: widget.drawingId,
                page: widget.controller.page,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.fromCache,
    required this.zoomPercent,
    required this.onBack,
    required this.onZoomOut,
    required this.onZoomIn,
    required this.onFit,
  });

  final String title;
  final bool fromCache;
  final int zoomPercent;
  final VoidCallback onBack;
  final VoidCallback onZoomOut;
  final VoidCallback onZoomIn;
  final VoidCallback onFit;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Material(
      color: MarkupStatusTheme.surface.withValues(alpha: 0.96),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: MarkupStatusTheme.border)),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(4, top + 4, 8, 8),
          child: Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(CupertinoIcons.chevron_left),
                color: MarkupStatusTheme.text,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: MarkupStatusTheme.text,
                      ),
                    ),
                    if (fromCache)
                      Text(
                        'Offline',
                        style: MarkupStatusTheme.caption,
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onZoomOut,
                icon: const Icon(CupertinoIcons.minus, size: 18),
              ),
              Text(
                '$zoomPercent%',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              IconButton(
                onPressed: onZoomIn,
                icon: const Icon(CupertinoIcons.plus, size: 18),
              ),
              TextButton(onPressed: onFit, child: const Text('Fit')),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomTools extends StatelessWidget {
  const _BottomTools({
    required this.tool,
    required this.bottomInset,
    required this.onSelect,
    required this.onFinishRoom,
  });

  final CadTool tool;
  final double bottomInset;
  final ValueChanged<CadTool> onSelect;
  final VoidCallback onFinishRoom;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MarkupStatusTheme.surface,
      child: SafeArea(
        top: false,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: MarkupStatusTheme.border)),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(8, 8, 8, 8 + bottomInset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (tool == CadTool.room)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SizedBox(
                      width: double.infinity,
                      height: AppSpacing.minTouch,
                      child: FilledButton(
                        onPressed: onFinishRoom,
                        child: const Text('Fullfør rom'),
                      ),
                    ),
                  ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _chip(CupertinoIcons.hand_raised, CadTool.pan),
                      _chip(CupertinoIcons.selection_pin_in_out, CadTool.select),
                      _chip(CupertinoIcons.arrow_right, CadTool.line),
                      _chip(CupertinoIcons.circle_fill, CadTool.point),
                      _chip(CupertinoIcons.dot_radiowaves_left_right, CadTool.detector),
                      _chip(CupertinoIcons.textformat, CadTool.text),
                      _chip(CupertinoIcons.square_split_2x2, CadTool.room),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, CadTool t) {
    final active = tool == t;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Material(
        color: active ? MarkupStatusTheme.accent : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => onSelect(t),
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: AppSpacing.minTouch,
            height: AppSpacing.minTouch,
            child: Icon(
              icon,
              size: 22,
              color: active ? Colors.white : MarkupStatusTheme.muted,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';

import '../markup_providers.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mobile_preview_frame.dart';
import 'cad_inspector_panel.dart';
import 'cad_pdf_viewer.dart';
import 'cad_tool.dart';
import 'cad_tool_rail.dart';
import 'cad_zoom.dart';
import 'markup_overlay.dart';

/// Fullskjerm CAD – venstre verktøyrail, blueprint rundt PDF, panel til høyre.
class CadWorkspace extends ConsumerStatefulWidget {
  const CadWorkspace({
    super.key,
    required this.drawingId,
    required this.projectId,
    required this.projectLabel,
    required this.title,
    required this.controller,
    required this.onBack,
    this.fromCache = false,
    this.showMobilePreviewToggle = false,
    this.mobilePreviewEnabled = false,
    this.onToggleMobilePreview,
  });

  final String drawingId;
  final String projectId;
  final String projectLabel;
  final String title;
  final PdfControllerPinch controller;
  final VoidCallback onBack;
  final bool fromCache;
  final bool showMobilePreviewToggle;
  final bool mobilePreviewEnabled;
  final VoidCallback? onToggleMobilePreview;

  @override
  ConsumerState<CadWorkspace> createState() => _CadWorkspaceState();
}

class _CadWorkspaceState extends ConsumerState<CadWorkspace>
    with CadZoomFocalMixin {
  CadTool _tool = CadTool.pan;
  bool _showGrid = true;
  bool _chromeVisible = true;
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
      padding: 12,
    );
    if (matrix != null) {
      await widget.controller.goTo(
        destination: matrix,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _fitPage() async {
    await widget.controller.animateToPage(
      pageNumber: widget.controller.page,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
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

  Future<void> _undo() async {
    await undoMarkup(ref, widget.drawingId);
  }

  @override
  Widget build(BuildContext context) {
    final roomDraftCount =
        ref.watch(markupRoomDraftProvider(widget.drawingId)).length;
    final chain = ref.watch(markupChainDraftProvider(widget.drawingId));
    final markupDoc = ref.watch(drawingMarkupProvider(widget.drawingId));
    final selection = ref.watch(markupSelectionProvider(widget.drawingId));

    final workspace = ColoredBox(
      color: const Color(0xFF0E1118),
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
                    ignoring: _tool != CadTool.pan && _tool.capturesGestures,
                    child: CadPdfViewer(
                      controller: widget.controller,
                      showGrid: _showGrid,
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
          if (_chromeVisible) ...[
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _TopBar(
                title: widget.title,
                fromCache: widget.fromCache,
                zoomPercent: _zoomPercent,
                hasUnpublished: markupDoc.hasUnpublishedChanges,
                unpublishedCount: markupDoc.unpublishedChangeCount,
                selectionNotEmpty: selection.isNotEmpty,
                onBack: widget.onBack,
                onToggleChrome: () =>
                    setState(() => _chromeVisible = !_chromeVisible),
                onZoomOut: () => _zoomBy(0.8),
                onZoomIn: () => _zoomBy(1.25),
                onFit: _fitWidth,
                onPublish: () async {
                  await ref
                      .read(drawingMarkupProvider(widget.drawingId).notifier)
                      .publish();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Publisert')),
                  );
                },
                onDeleteSelection: () async {
                  await ref
                      .read(drawingMarkupProvider(widget.drawingId).notifier)
                      .deleteElements(selection);
                  clearMarkupSelection(ref, widget.drawingId);
                },
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              bottom: 0,
              child: CadToolRail(
                activeTool: _tool,
                showGrid: _showGrid,
                onSelectTool: _selectTool,
                onZoomIn: () => _zoomBy(1.25),
                onZoomOut: () => _zoomBy(0.8),
                onFitWidth: _fitWidth,
                onFitPage: _fitPage,
                onToggleGrid: () => setState(() => _showGrid = !_showGrid),
                onUndo: _undo,
                showMobileToggle: widget.showMobilePreviewToggle,
                mobilePreview: widget.mobilePreviewEnabled,
                onToggleMobile: widget.onToggleMobilePreview,
              ),
            ),
            Positioned(
              left: 52,
              right: _chromeVisible ? 300 : 0,
              bottom: 0,
              child: _StatusBar(
                tool: _tool,
                zoomPercent: _zoomPercent,
                roomDraftCount: roomDraftCount,
                chainCount: chain?.nodes.length ?? 0,
                onFinishRoom: () => confirmRoomDraft(
                  context,
                  ref,
                  drawingId: widget.drawingId,
                  page: widget.controller.page,
                ),
                onCloseLoop: () => closeMarkupChain(ref, widget.drawingId),
              ),
            ),
            if (_chromeVisible)
              Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                child: CadInspectorPanel(
                  drawingId: widget.drawingId,
                  projectId: widget.projectId,
                  projectLabel: widget.projectLabel,
                  tool: _tool,
                  roomDraftCount: roomDraftCount,
                  chainNodeCount: chain?.nodes.length ?? 0,
                  onFinishRoom: () => confirmRoomDraft(
                    context,
                    ref,
                    drawingId: widget.drawingId,
                    page: widget.controller.page,
                  ),
                  onCloseLoop: () =>
                      closeMarkupChain(ref, widget.drawingId),
                  onDeleteSelected: () async {
                    await ref
                        .read(drawingMarkupProvider(widget.drawingId)
                            .notifier)
                        .deleteElements(selection);
                    clearMarkupSelection(ref, widget.drawingId);
                  },
                  onPublishSelected: () async {
                    await ref
                        .read(drawingMarkupProvider(widget.drawingId)
                            .notifier)
                        .publish();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Publisert')),
                    );
                  },
                ),
              ),
          ] else
            Positioned(
              top: MediaQuery.paddingOf(context).top + 8,
              right: 12,
              child: _FloatingChromeBtn(
                onTap: () => setState(() => _chromeVisible = true),
              ),
            ),
        ],
      ),
    );

    if (widget.mobilePreviewEnabled && widget.showMobilePreviewToggle) {
      return MobilePreviewFrame(child: workspace);
    }
    return workspace;
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.fromCache,
    required this.zoomPercent,
    required this.hasUnpublished,
    required this.unpublishedCount,
    required this.selectionNotEmpty,
    required this.onBack,
    required this.onToggleChrome,
    required this.onZoomOut,
    required this.onZoomIn,
    required this.onFit,
    required this.onPublish,
    required this.onDeleteSelection,
  });

  final String title;
  final bool fromCache;
  final int zoomPercent;
  final bool hasUnpublished;
  final int unpublishedCount;
  final bool selectionNotEmpty;
  final VoidCallback onBack;
  final VoidCallback onToggleChrome;
  final VoidCallback onZoomOut;
  final VoidCallback onZoomIn;
  final VoidCallback onFit;
  final VoidCallback onPublish;
  final VoidCallback onDeleteSelection;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Material(
      color: const Color(0xF012151C),
      child: Padding(
        padding: EdgeInsets.fromLTRB(56, top + 4, 12, 8),
        child: Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(CupertinoIcons.chevron_left, size: 20),
              color: AppColors.label,
              tooltip: 'Tilbake',
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.callout.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    fromCache
                        ? 'Offline · markering lagres lokalt'
                        : 'Markering lagres lokalt',
                    style: AppTypography.caption.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            _ZoomCluster(
              percent: zoomPercent,
              onZoomOut: onZoomOut,
              onZoomIn: onZoomIn,
              onFit: onFit,
            ),
            const SizedBox(width: 8),
            if (hasUnpublished)
              FilledButton(
                onPressed: onPublish,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2E9B5E),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: Text(
                  unpublishedCount > 0
                      ? 'Publiser ($unpublishedCount)'
                      : 'Publiser',
                ),
              ),
            if (selectionNotEmpty)
              OutlinedButton(
                onPressed: onDeleteSelection,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF6E7A),
                  side: const BorderSide(color: Color(0xFFFF6E7A)),
                ),
                child: const Text('Slett'),
              ),
            IconButton(
              onPressed: onToggleChrome,
              icon: const Icon(CupertinoIcons.sidebar_right, size: 18),
              color: AppColors.labelSecondary,
              tooltip: 'Skjul panel',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({
    required this.tool,
    required this.zoomPercent,
    required this.roomDraftCount,
    required this.chainCount,
    required this.onFinishRoom,
    required this.onCloseLoop,
  });

  final CadTool tool;
  final int zoomPercent;
  final int roomDraftCount;
  final int chainCount;
  final VoidCallback onFinishRoom;
  final VoidCallback onCloseLoop;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xF00A0C10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Text(
              tool.label,
              style: AppTypography.caption.copyWith(
                color: AppColors.label,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                tool.hint,
                style: AppTypography.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (tool == CadTool.room && roomDraftCount > 0)
              TextButton(
                onPressed: onFinishRoom,
                child: Text('Fullfør rom ($roomDraftCount)'),
              ),
            if (tool == CadTool.line && chainCount > 0)
              TextButton(
                onPressed: onCloseLoop,
                child: Text('Lukk sløyfe ($chainCount)'),
              ),
            Text(
              '$zoomPercent %',
              style: AppTypography.caption.copyWith(
                color: AppColors.labelSecondary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingChromeBtn extends StatelessWidget {
  const _FloatingChromeBtn({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xF012151C),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Icon(
            CupertinoIcons.sidebar_right,
            size: 20,
            color: AppColors.labelSecondary,
          ),
        ),
      ),
    );
  }
}

class _ZoomCluster extends StatelessWidget {
  const _ZoomCluster({
    required this.percent,
    required this.onZoomOut,
    required this.onZoomIn,
    required this.onFit,
  });

  final int percent;
  final VoidCallback onZoomOut;
  final VoidCallback onZoomIn;
  final VoidCallback onFit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
            onPressed: onZoomOut,
            icon: const Icon(CupertinoIcons.minus, size: 18),
            color: AppColors.label,
          ),
          SizedBox(
            width: 44,
            child: Text(
              '$percent%',
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.label,
              ),
            ),
          ),
          IconButton(
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
            onPressed: onZoomIn,
            icon: const Icon(CupertinoIcons.plus, size: 18),
            color: AppColors.label,
          ),
          TextButton(onPressed: onFit, child: const Text('Fit')),
        ],
      ),
    );
  }
}

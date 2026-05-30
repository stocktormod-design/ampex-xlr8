import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdfx/pdfx.dart';

import '../../../core/network/is_online_provider.dart';
import '../../../core/platform/app_product_provider.dart';
import '../../../core/storage/file_cache_service.dart';
import '../../../core/storage/storage_buckets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/ampex_error_banner.dart';
import '../desktop/presentation/drawing/office_drawing_workspace.dart';
import '../mobile/presentation/drawing/field_drawing_workspace.dart';
import 'drawings_providers.dart';

/// Velger felt- eller kontor-tegning – delt PDF-lasting, ikke delt layout.
class AdaptiveDrawingViewerScreen extends ConsumerStatefulWidget {
  const AdaptiveDrawingViewerScreen({
    super.key,
    required this.projectId,
    required this.drawingId,
  });

  final String projectId;
  final String drawingId;

  @override
  ConsumerState<AdaptiveDrawingViewerScreen> createState() =>
      _AdaptiveDrawingViewerScreenState();
}

class _AdaptiveDrawingViewerScreenState
    extends ConsumerState<AdaptiveDrawingViewerScreen> {
  PdfControllerPinch? _controller;
  String? _error;
  bool _fromCache = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _openPdf();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _openPdf() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final drawing = await ref.read(drawingProvider(widget.drawingId).future);
      if (drawing == null) {
        setState(() {
          _error = 'Tegningen finnes ikke.';
          _loading = false;
        });
        return;
      }

      final online = ref.read(isOnlineProvider);
      final handle = await ref.read(fileCacheServiceProvider).resolvePdf(
            bucket: StorageBuckets.drawings,
            remotePath: drawing.filePath,
            entityType: 'drawing',
            entityId: drawing.id,
            online: online,
          );

      final Future<PdfDocument> documentFuture = handle.isInMemory
          ? PdfDocument.openData(Uint8List.fromList(handle.bytes!))
          : PdfDocument.openFile(handle.localPath!);

      _controller?.dispose();
      if (!mounted) return;

      setState(() {
        _controller = PdfControllerPinch(document: documentFuture);
        _fromCache = handle.fromCache;
        _loading = false;
      });
    } on FileCacheException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Kunne ikke åpne PDF.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final drawingAsync = ref.watch(drawingProvider(widget.drawingId));
    final title = drawingAsync.valueOrNull?.displayName ?? 'Tegning';

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenH),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.close),
                ),
                const SizedBox(height: AppSpacing.md),
                AmpexErrorBanner(message: _error!),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: _openPdf,
                  child: const Text('Prøv igjen'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_loading || _controller == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final common = (
      drawingId: widget.drawingId,
      projectId: widget.projectId,
      projectLabel: title,
      title: title,
      controller: _controller!,
      onBack: () => context.pop(),
      fromCache: _fromCache,
    );

    if (context.isAmpexMobile) {
      return Scaffold(
        body: FieldDrawingWorkspace(
          drawingId: common.drawingId,
          projectId: common.projectId,
          projectLabel: common.projectLabel,
          title: common.title,
          controller: common.controller,
          onBack: common.onBack,
          fromCache: common.fromCache,
        ),
      );
    }

    return Scaffold(
      body: CadWorkspace(
        drawingId: common.drawingId,
        projectId: common.projectId,
        projectLabel: common.projectLabel,
        title: common.title,
        controller: common.controller,
        onBack: common.onBack,
        fromCache: common.fromCache,
      ),
    );
  }
}

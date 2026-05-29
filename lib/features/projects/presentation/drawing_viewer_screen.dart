import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdfx/pdfx.dart';

import '../../../core/network/is_online_provider.dart';
import '../../../core/storage/file_cache_service.dart';
import '../../../core/storage/storage_buckets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ampex_error_banner.dart';
import '../../../core/widgets/ampex_glass.dart';
import 'drawings_providers.dart';

class DrawingViewerScreen extends ConsumerStatefulWidget {
  const DrawingViewerScreen({
    super.key,
    required this.projectId,
    required this.drawingId,
  });

  final String projectId;
  final String drawingId;

  @override
  ConsumerState<DrawingViewerScreen> createState() =>
      _DrawingViewerScreenState();
}

class _DrawingViewerScreenState extends ConsumerState<DrawingViewerScreen> {
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
    final topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(8, topPad + 8, AppSpacing.screenH, 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(CupertinoIcons.back, size: 26),
                  color: AppColors.accent,
                ),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.headline,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (_fromCache)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
              child: AmpexGlass(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.checkmark_circle_fill,
                        size: 18,
                        color: AppColors.statusDone,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Lagret på enheten – tilgjengelig offline',
                        style: AppTypography.footnote.copyWith(
                          color: AppColors.labelSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenH),
              child: Column(
                children: [
                  AmpexErrorBanner(message: _error!),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(
                    onPressed: _openPdf,
                    child: const Text('Prøv igjen'),
                  ),
                ],
              ),
            )
          else if (_loading)
            const Expanded(
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (_controller != null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  AppSpacing.sm,
                  AppSpacing.screenH,
                  AppSpacing.lg,
                ),
                child: AmpexGlass(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: PdfViewPinch(controller: _controller!),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

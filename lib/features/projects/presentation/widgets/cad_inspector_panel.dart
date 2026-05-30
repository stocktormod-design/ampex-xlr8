import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_typography.dart';
import '../../domain/drawing_markup.dart';
import '../markup_providers.dart';
import 'cad_tool.dart';
import 'detector_status_sheet.dart';
import 'room_status_sheet.dart';

/// Lys høyre panel – status / verktøy (som Ampex web).
class CadInspectorPanel extends ConsumerWidget {
  const CadInspectorPanel({
    super.key,
    required this.drawingId,
    required this.projectId,
    required this.projectLabel,
    required this.tool,
    required this.roomDraftCount,
    required this.chainNodeCount,
    required this.onFinishRoom,
    required this.onCloseLoop,
    required this.onDeleteSelected,
    required this.onPublishSelected,
  });

  final String drawingId;
  final String projectId;
  final String projectLabel;
  final CadTool tool;
  final int roomDraftCount;
  final int chainNodeCount;
  final VoidCallback onFinishRoom;
  final VoidCallback onCloseLoop;
  final VoidCallback onDeleteSelected;
  final VoidCallback onPublishSelected;

  static const _border = Color(0xFFDCE3EE);
  static const _text = Color(0xFF1C2434);
  static const _muted = Color(0xFF6B7A94);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doc = ref.watch(drawingMarkupProvider(drawingId));
    final selection = ref.watch(markupSelectionProvider(drawingId));
    final selected = _resolveSelected(doc, selection);

    return Material(
      color: Colors.white,
      child: Container(
        width: 300,
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: _border)),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Text('VERKTØY', style: _section),
            const SizedBox(height: 6),
            Text(tool.label, style: AppTypography.headline.copyWith(color: _text)),
            Text(tool.hint, style: AppTypography.caption.copyWith(color: _muted)),
            const SizedBox(height: 20),
            if (selected != null) ...[
              Text('STATUS', style: _section),
              const SizedBox(height: 8),
              _SelectedCard(
                label: _labelFor(selected),
                onOpen: () => _openEditor(context, ref, selected),
              ),
              const SizedBox(height: 16),
            ],
            if (tool == CadTool.room && roomDraftCount > 0) ...[
              _ActionTile(
                icon: CupertinoIcons.checkmark_circle_fill,
                label: 'Fullfør rom ($roomDraftCount hjørner)',
                onTap: onFinishRoom,
              ),
              const SizedBox(height: 8),
            ],
            if (tool == CadTool.line && chainNodeCount >= 2)
              _ActionTile(
                icon: CupertinoIcons.arrow_2_circlepath,
                label: 'Lukk sløyfe',
                onTap: onCloseLoop,
              ),
            if (tool == CadTool.select && selection.isNotEmpty) ...[
              Text('VALGT (${selection.length})', style: _section),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDeleteSelected,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC3545),
                        side: const BorderSide(color: Color(0xFFDC3545)),
                      ),
                      child: const Text('Slett'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: onPublishSelected,
                      child: const Text('Publiser'),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            Text('HJELP', style: _section),
            const SizedBox(height: 6),
            Text(
              'Mac: ⌘ + scroll eller pinch for zoom. '
              'Hold inne rom eller detektor for status.',
              style: AppTypography.caption.copyWith(color: _muted, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  static const _section = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: _muted,
  );

  MarkupElement? _resolveSelected(
    DrawingMarkupDocument doc,
    Set<String> ids,
  ) {
    if (ids.length != 1) return null;
    final id = ids.first;
    for (final e in doc.elements) {
      if (e.id == id) return e;
    }
    return null;
  }

  String _labelFor(MarkupElement el) => switch (el) {
        MarkupRoom r => r.name ?? 'Rom',
        MarkupDetector _ => 'Detektor',
        MarkupPoint _ => 'Punkt',
        MarkupText t => t.text,
        MarkupLine _ => 'Linje',
      };

  void _openEditor(BuildContext context, WidgetRef ref, MarkupElement el) {
    switch (el) {
      case MarkupRoom r:
        showRoomStatusSheet(
          context: context,
          ref: ref,
          drawingId: drawingId,
          projectId: projectId,
          projectLabel: projectLabel,
          room: r,
        );
      case MarkupDetector d:
        showDetectorStatusSheet(
          context: context,
          ref: ref,
          drawingId: drawingId,
          detector: d,
        );
      default:
        break;
    }
  }
}

class _SelectedCard extends StatelessWidget {
  const _SelectedCard({required this.label, required this.onOpen});

  final String label;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF4F7FB),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C2434),
                  ),
                ),
              ),
              const Icon(CupertinoIcons.chevron_right, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}

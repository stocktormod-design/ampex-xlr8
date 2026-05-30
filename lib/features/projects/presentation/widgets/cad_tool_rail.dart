import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'cad_tool.dart';

/// Vertikal verktøyrail til venstre (CAD).
class CadToolRail extends StatelessWidget {
  const CadToolRail({
    super.key,
    required this.activeTool,
    required this.showGrid,
    required this.onSelectTool,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onFitWidth,
    required this.onFitPage,
    required this.onToggleGrid,
    required this.onUndo,
    this.showMobileToggle = false,
    this.mobilePreview = false,
    this.onToggleMobile,
  });

  final CadTool activeTool;
  final bool showGrid;
  final ValueChanged<CadTool> onSelectTool;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onFitWidth;
  final VoidCallback onFitPage;
  final VoidCallback onToggleGrid;
  final VoidCallback onUndo;
  final bool showMobileToggle;
  final bool mobilePreview;
  final VoidCallback? onToggleMobile;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Material(
      color: const Color(0xF00A0C10),
      child: Container(
        width: 52,
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: AppColors.border)),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: top + 52, bottom: 80),
          child: Column(
            children: [
              _btn(
                CupertinoIcons.hand_raised,
                CadTool.pan.label,
                activeTool == CadTool.pan,
                () => onSelectTool(CadTool.pan),
              ),
              _btn(
                CupertinoIcons.selection_pin_in_out,
                CadTool.select.label,
                activeTool == CadTool.select,
                () => onSelectTool(CadTool.select),
              ),
              const _Divider(),
              _btn(
                CupertinoIcons.arrow_right,
                CadTool.line.label,
                activeTool == CadTool.line,
                () => onSelectTool(CadTool.line),
              ),
              _btn(
                CupertinoIcons.circle_fill,
                CadTool.point.label,
                activeTool == CadTool.point,
                () => onSelectTool(CadTool.point),
              ),
              _btn(
                CupertinoIcons.dot_radiowaves_left_right,
                CadTool.detector.label,
                activeTool == CadTool.detector,
                () => onSelectTool(CadTool.detector),
              ),
              _btn(
                CupertinoIcons.textformat,
                CadTool.text.label,
                activeTool == CadTool.text,
                () => onSelectTool(CadTool.text),
              ),
              _btn(
                CupertinoIcons.square_split_2x2,
                CadTool.room.label,
                activeTool == CadTool.room,
                () => onSelectTool(CadTool.room),
              ),
              const _Divider(),
              _btn(CupertinoIcons.plus, 'Zoom inn', false, onZoomIn),
              _btn(CupertinoIcons.minus, 'Zoom ut', false, onZoomOut),
              _btn(
                CupertinoIcons.arrow_left_right,
                'Tilpass bredde',
                false,
                onFitWidth,
              ),
              _btn(
                CupertinoIcons.arrow_up_left_arrow_down_right,
                'Hele siden',
                false,
                onFitPage,
              ),
              const _Divider(),
              _btn(CupertinoIcons.arrow_uturn_left, 'Angre', false, onUndo),
              _btn(
                CupertinoIcons.grid,
                'Blueprint-rutenett',
                showGrid,
                onToggleGrid,
              ),
              if (showMobileToggle && onToggleMobile != null)
                _btn(
                  mobilePreview
                      ? CupertinoIcons.device_phone_portrait
                      : CupertinoIcons.desktopcomputer,
                  'Mobilforhåndsvisning',
                  mobilePreview,
                  onToggleMobile!,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _btn(
    IconData icon,
    String tooltip,
    bool active,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: active ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(
                icon,
                size: 20,
                color: active ? AppColors.onAccent : AppColors.labelSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: AppColors.border,
    );
  }
}

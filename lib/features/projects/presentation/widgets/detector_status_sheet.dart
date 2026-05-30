import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/drawing_markup.dart';
import '../markup_providers.dart';
import 'markup_status_theme.dart';

Future<void> showDetectorStatusSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String drawingId,
  required MarkupDetector detector,
}) {
  return MarkupStatusTheme.showSheet(
    context: context,
    initialSize: 0.52,
    child: _DetectorStatusSheet(
      drawingId: drawingId,
      detector: detector,
    ),
  );
}

class _DetectorStatusSheet extends ConsumerStatefulWidget {
  const _DetectorStatusSheet({
    required this.drawingId,
    required this.detector,
  });

  final String drawingId;
  final MarkupDetector detector;

  @override
  ConsumerState<_DetectorStatusSheet> createState() =>
      _DetectorStatusSheetState();
}

class _DetectorStatusSheetState extends ConsumerState<_DetectorStatusSheet> {
  late MarkupDetectorStatus _status;
  late final TextEditingController _serialCtrl;
  late final TextEditingController _tagCtrl;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _status = widget.detector.status;
    _serialCtrl = TextEditingController(text: _status.serienummer ?? '');
    _tagCtrl = TextEditingController(text: _status.tagnummer ?? '');
  }

  @override
  void dispose() {
    _serialCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  Future<void> _scanTo(TextEditingController target) async {
    final file = await _picker.pickImage(source: ImageSource.camera);
    if (file == null || !mounted) return;
    setState(() => _status = _status.copyWith(scanImagePath: file.path));
    if (target.text.isEmpty) {
      target.text =
          'Skannet ${DateTime.now().toIso8601String().substring(11, 16)}';
    }
  }

  Future<void> _save() async {
    await ref.read(drawingMarkupProvider(widget.drawingId).notifier).updateDetectorStatus(
          widget.detector.id,
          _status.copyWith(
            serienummer: _serialCtrl.text.trim().isEmpty
                ? null
                : _serialCtrl.text.trim(),
            tagnummer:
                _tagCtrl.text.trim().isEmpty ? null : _tagCtrl.text.trim(),
          ),
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MarkupStatusTheme.sheetHandle(),
        Text('Detektor / sokkel', style: MarkupStatusTheme.title),
        const SizedBox(height: 16),
        _toggleRow('Sokkel montert', _status.sokkelMontert, (v) =>
            setState(() => _status = _status.copyWith(sokkelMontert: v))),
        _toggleRow('Detektor montert', _status.detektorMontert, (v) =>
            setState(() => _status = _status.copyWith(detektorMontert: v))),
        const SizedBox(height: 12),
        _scanRow('Serienummer', _serialCtrl),
        const SizedBox(height: 12),
        _scanRow('Tagnummer', _tagCtrl),
        const SizedBox(height: 16),
        Text('Kappe på plass?', style: MarkupStatusTheme.caption),
        const SizedBox(height: 8),
        SegmentedButton<bool?>(
          style: SegmentedButton.styleFrom(
            backgroundColor: const Color(0xFFF1F5F9),
            selectedBackgroundColor: MarkupStatusTheme.accent,
            selectedForegroundColor: Colors.white,
          ),
          segments: const [
            ButtonSegment(value: false, label: Text('Ja')),
            ButtonSegment(value: true, label: Text('Nei')),
            ButtonSegment(value: null, label: Text('–')),
          ],
          selected: {_status.kappeAv},
          onSelectionChanged: (s) =>
              setState(() => _status = _status.copyWith(kappeAv: s.first)),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _save,
          style: FilledButton.styleFrom(
            backgroundColor: MarkupStatusTheme.accent,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text('Lagre'),
        ),
      ],
    );
  }

  Widget _toggleRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: MarkupStatusTheme.border),
      ),
      child: SwitchListTile(
        title: Text(label, style: const TextStyle(color: MarkupStatusTheme.text)),
        value: value,
        activeThumbColor: MarkupStatusTheme.accent,
        onChanged: onChanged,
      ),
    );
  }

  Widget _scanRow(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: MarkupStatusTheme.caption),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: ctrl,
                decoration: MarkupStatusTheme.field(
                  label,
                  hint: 'Skriv eller skann',
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonal(
              onPressed: () => _scanTo(ctrl),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE8F0FE),
                foregroundColor: MarkupStatusTheme.accent,
              ),
              child: const Icon(CupertinoIcons.camera, size: 20),
            ),
          ],
        ),
      ],
    );
  }
}

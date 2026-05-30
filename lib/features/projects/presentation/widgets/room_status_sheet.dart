import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/inbox/inbox_models.dart';
import '../../../../core/inbox/inbox_provider.dart';
import '../../domain/drawing_markup.dart';
import '../markup_providers.dart';
import 'markup_status_theme.dart';

Future<void> showRoomStatusSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String drawingId,
  required String projectId,
  required String projectLabel,
  required MarkupRoom room,
}) {
  return MarkupStatusTheme.showSheet(
    context: context,
    initialSize: 0.82,
    child: _RoomStatusSheet(
      drawingId: drawingId,
      projectId: projectId,
      projectLabel: projectLabel,
      room: room,
    ),
  );
}

class _RoomStatusSheet extends ConsumerStatefulWidget {
  const _RoomStatusSheet({
    required this.drawingId,
    required this.projectId,
    required this.projectLabel,
    required this.room,
  });

  final String drawingId;
  final String projectId;
  final String projectLabel;
  final MarkupRoom room;

  @override
  ConsumerState<_RoomStatusSheet> createState() => _RoomStatusSheetState();
}

class _RoomStatusSheetState extends ConsumerState<_RoomStatusSheet> {
  late MarkupRoomStatus _status;
  late MarkupRoomProgress _progress;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _serialCtrl;
  late final TextEditingController _tagCtrl;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _status = widget.room.status;
    _progress = widget.room.progress;
    _nameCtrl = TextEditingController(text: widget.room.name ?? '');
    _serialCtrl = TextEditingController(text: _status.serienummer ?? '');
    _tagCtrl = TextEditingController(text: _status.tagnummer ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
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

  Future<void> _requestLidar() async {
    final roomName = _nameCtrl.text.trim().isEmpty
        ? 'Rom uten navn'
        : _nameCtrl.text.trim();
    final at = DateTime.now().toUtc();
    await ref.read(drawingMarkupProvider(widget.drawingId).notifier).updateRoom(
          widget.room.id,
          name: roomName,
          lidarRequestedAt: at,
        );
    ref.read(inboxProvider.notifier).push(
          title: 'LiDAR-scan ønsket',
          body:
              '$roomName · ${widget.projectLabel}\nMontør har bedt om LiDAR-scan av rommet.',
          kind: InboxMessageKind.lidarRequest,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'LiDAR-ansvarlig varslet (push + innboks). Kobles til Supabase senere.',
        ),
      ),
    );
  }

  Future<void> _save() async {
    await ref.read(drawingMarkupProvider(widget.drawingId).notifier).updateRoom(
          widget.room.id,
          name: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
          status: _status.copyWith(
            serienummer: _serialCtrl.text.trim().isEmpty
                ? null
                : _serialCtrl.text.trim(),
            tagnummer:
                _tagCtrl.text.trim().isEmpty ? null : _tagCtrl.text.trim(),
          ),
          progress: _progress,
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MarkupStatusTheme.sheetHandle(),
        Text(
          _nameCtrl.text.trim().isEmpty ? 'Rom' : _nameCtrl.text.trim(),
          style: MarkupStatusTheme.title,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _nameCtrl,
          decoration: MarkupStatusTheme.field('Romnavn', hint: 'F.eks. Bad'),
        ),
        const SizedBox(height: 20),
        Text('Fremdrift', style: MarkupStatusTheme.section),
        const SizedBox(height: 8),
        _progressCard('Sterkstrøm', _progress.sterkstrom, (v) => setState(
              () => _progress = _progress.copyWith(sterkstrom: v.round()),
            )),
        _progressCard('Svakstrøm', _progress.svakstrom, (v) => setState(
              () => _progress = _progress.copyWith(svakstrom: v.round()),
            )),
        _progressCard('Automasjon', _progress.automasjon, (v) => setState(
              () => _progress = _progress.copyWith(automasjon: v.round()),
            )),
        _progressCard('Brann', _progress.brann, (v) => setState(
              () => _progress = _progress.copyWith(brann: v.round()),
            )),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _requestLidar,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF6B4EFF),
            side: const BorderSide(color: Color(0xFF6B4EFF)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          icon: const Icon(CupertinoIcons.view_3d),
          label: Text(
            widget.room.lidarRequestedAt != null
                ? 'LiDAR bestilt ${widget.room.lidarRequestedAt!.toLocal().toString().substring(0, 16)}'
                : 'Etterspør LiDAR-scan',
          ),
        ),
        const Divider(height: 32, color: MarkupStatusTheme.border),
        Text('Montering', style: MarkupStatusTheme.section),
        const SizedBox(height: 8),
        _toggleRow('Sokkel montert', _status.sokkelMontert, (v) =>
            setState(() => _status = _status.copyWith(sokkelMontert: v))),
        _toggleRow('Detektor montert', _status.detektorMontert, (v) =>
            setState(() => _status = _status.copyWith(detektorMontert: v))),
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

  Widget _progressCard(
    String label,
    int value,
    ValueChanged<double> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: MarkupStatusTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(
                color: MarkupStatusTheme.text,
                fontWeight: FontWeight.w600,
              )),
              Text('$value %', style: MarkupStatusTheme.caption),
            ],
          ),
          Slider(
            value: value.toDouble(),
            min: 0,
            max: 100,
            divisions: 20,
            activeColor: MarkupStatusTheme.accent,
            label: '$value%',
            onChanged: onChanged,
          ),
        ],
      ),
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
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: ctrl,
              decoration: MarkupStatusTheme.field(label),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.tonal(
            onPressed: () => _scanTo(ctrl),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE8F0FE),
              foregroundColor: MarkupStatusTheme.accent,
            ),
            child: const Icon(CupertinoIcons.camera),
          ),
        ],
      ),
    );
  }
}

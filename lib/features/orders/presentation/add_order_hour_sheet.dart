import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ampex_error_banner.dart';
import '../../../core/widgets/ampex_primary_button.dart';
import '../../../core/widgets/ampex_text_field.dart';
import '../data/order_hours_repository.dart';

/// Bottom sheet for å registrere timer på en ordre.
Future<bool?> showAddOrderHourSheet(
  BuildContext context, {
  required String orderId,
  required String userId,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: AddOrderHourSheet(orderId: orderId, userId: userId),
    ),
  );
}

class AddOrderHourSheet extends ConsumerStatefulWidget {
  const AddOrderHourSheet({
    super.key,
    required this.orderId,
    required this.userId,
  });

  final String orderId;
  final String userId;

  @override
  ConsumerState<AddOrderHourSheet> createState() => _AddOrderHourSheetState();
}

class _AddOrderHourSheetState extends ConsumerState<AddOrderHourSheet> {
  DateTime _workDate = DateTime.now();
  int _minutes = 60;
  final _noteController = TextEditingController();
  bool _loading = false;
  String? _error;

  static const _durations = <int, String>{
    30: '30 min',
    60: '1 time',
    90: '1,5 time',
    120: '2 timer',
    240: '4 timer',
    480: '8 timer',
  };

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _workDate,
      firstDate: DateTime.now().subtract(const Duration(days: 14)),
      lastDate: DateTime.now(),
      locale: const Locale('nb'),
    );
    if (picked != null) setState(() => _workDate = picked);
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ref.read(orderHoursRepositoryProvider).registerHour(
            RegisterOrderHourInput(
              orderId: widget.orderId,
              userId: widget.userId,
              workDate: _workDate,
              minutes: _minutes,
              note: _noteController.text,
            ),
          );

      if (!mounted) return;
      Navigator.pop(context, true);
    } on OrderHoursException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Kunne ikke lagre timer.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('EEEE d. MMMM', 'nb');

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH,
          AppSpacing.lg,
          AppSpacing.screenH,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.separator,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Registrer timer', style: AppTypography.title2),
            const SizedBox(height: AppSpacing.lg),
            if (_error != null) ...[
              AmpexErrorBanner(message: _error!),
              const SizedBox(height: AppSpacing.md),
            ],
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Ink(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        const Icon(
                          CupertinoIcons.calendar,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Arbeidsdag',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.labelSecondary,
                                ),
                              ),
                              Text(
                                dateFmt.format(_workDate),
                                style: AppTypography.headline,
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          CupertinoIcons.chevron_down,
                          size: 16,
                          color: AppColors.labelTertiary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Varighet',
              style: AppTypography.caption.copyWith(
                color: AppColors.labelSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _durations.entries.map((e) {
                final selected = _minutes == e.key;
                return FilterChip(
                  label: Text(e.value),
                  selected: selected,
                  onSelected: (_) => setState(() => _minutes = e.key),
                  selectedColor: AppColors.accentSoft,
                  checkmarkColor: AppColors.accent,
                  labelStyle: AppTypography.callout.copyWith(
                    color: selected ? AppColors.accent : AppColors.label,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: selected ? AppColors.accent : AppColors.border,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            AmpexTextField(
              controller: _noteController,
              hint: 'Notat (valgfritt)',
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: AppSpacing.lg),
            AmpexPrimaryButton(
              label: 'Lagre timer',
              isLoading: _loading,
              onPressed: _loading ? null : _submit,
            ),
            const SizedBox(height: AppSpacing.sm),
            AmpexTextButton(
              label: 'Avbryt',
              onPressed: _loading ? null : () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

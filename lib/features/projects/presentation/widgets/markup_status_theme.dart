import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';

/// Lys status-UI for rom / detektor (matcher Ampex web).
abstract final class MarkupStatusTheme {
  static const surface = Colors.white;
  static const border = Color(0xFFE2E8F0);
  static const text = Color(0xFF1C2434);
  static const muted = Color(0xFF6B7A94);
  static const accent = Color(0xFF2F7BFF);

  static InputDecoration field(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: accent, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  static TextStyle get title =>
      AppTypography.title2.copyWith(color: text, fontWeight: FontWeight.w700);

  static TextStyle get section =>
      AppTypography.headline.copyWith(color: text, fontWeight: FontWeight.w600);

  static TextStyle get caption =>
      AppTypography.caption.copyWith(color: muted);

  static Widget sheetHandle() => Center(
        child: Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: border,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );

  static Future<T?> showSheet<T>({
    required BuildContext context,
    required Widget child,
    double initialSize = 0.55,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: surface,
      barrierColor: const Color(0x66000000),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: initialSize,
        minChildSize: 0.35,
        maxChildSize: 0.92,
        builder: (_, scroll) => Material(
          color: surface,
          child: SingleChildScrollView(
            controller: scroll,
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              20 + MediaQuery.paddingOf(ctx).bottom,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

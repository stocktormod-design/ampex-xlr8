import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// På web: viser appen som en «telefon» midt på skjermen (tydelig forskjell
/// fra utstrakt nettside). På iOS/Android: ingen endring.
class AmpexWebFrame extends StatelessWidget {
  const AmpexWebFrame({super.key, required this.child});

  final Widget child;

  static const _phoneWidth = 390.0;
  static const _phoneRadius = 44.0;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;

    return ColoredBox(
      color: const Color(0xFFD1D1D6),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: _phoneWidth,
              maxHeight: 844,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_phoneRadius),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 48,
                    offset: Offset(0, 16),
                  ),
                ],
                border: Border.all(color: const Color(0x26000000)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_phoneRadius),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'offline_banner.dart';

/// Sideskall for alle listeskjermer.
///
/// – Ekte iOS CupertinoSliverNavigationBar for den riktige
///   large title / blur / collapse-effekten.
/// – Maks bredde på 480px på web/desktop slik at den føles som en mobilapp.
class AmpexScaffold extends StatelessWidget {
  const AmpexScaffold({
    super.key,
    required this.title,
    required this.slivers,
    this.trailing,
    this.maxContentWidth = 480,
    this.backgroundColor = AppColors.background,
  });

  /// Stor venstrejustert tittel (iOS style).
  final String title;

  /// Innhold.
  final List<Widget> slivers;
  
  /// Ikon/knapp oppe til høyre.
  final Widget? trailing;
  
  final double maxContentWidth;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: OfflineBanner(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: ColoredBox(
              color: backgroundColor,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  CupertinoSliverNavigationBar(
                    largeTitle: Text(title),
                    trailing: trailing,
                    backgroundColor: backgroundColor.withValues(alpha: 0.92),
                    border: null,
                    stretch: true,
                  ),
                  ...slivers,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

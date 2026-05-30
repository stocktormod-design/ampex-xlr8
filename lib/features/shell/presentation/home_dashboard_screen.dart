import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/models/session_context.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../orders/domain/order.dart';
import '../../orders/presentation/orders_providers.dart';
import '../../projects/domain/project.dart';
import '../../projects/presentation/projects_providers.dart';
import '../../shared/status_labels.dart';
import 'widgets/dashboard_card.dart';

/// Dashboard-layout etter referanse-mockup (hvitt accent).
class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key, required this.session});

  final SessionContext session;

  String get _firstName {
    final name = session.displayName.trim();
    if (name.isEmpty || name == 'Bruker') return 'der';
    return name.split(' ').first;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects =
        ref.watch(projectsListProvider).valueOrNull ?? const <Project>[];
    final attention = ref.watch(attentionOrdersProvider);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 4, 28, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _GreetingRow(firstName: _firstName),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 1024;
                  if (!wide) {
                    return _MobileStack(
                      projects: projects,
                      attention: attention,
                    );
                  }
                  return _DesktopGrid(
                    projects: projects,
                    attention: attention,
                  );
                },
              ),
              const SizedBox(height: 24),
              const _QuickActions(),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileStack extends StatelessWidget {
  const _MobileStack({required this.projects, required this.attention});

  final List<Project> projects;
  final List<Order> attention;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TodayWorkCard(
          project: projects.isNotEmpty ? projects.first : null,
          onOpen: () => context.go(Routes.projects),
        ),
        const SizedBox(height: 16),
        const _ScheduleCard(),
        const SizedBox(height: 16),
        _TasksCard(orders: attention),
        const SizedBox(height: 16),
        _ProjectsCard(projects: projects.take(3).toList()),
        const SizedBox(height: 16),
        const _AlertsCard(),
      ],
    );
  }
}

class _DesktopGrid extends StatelessWidget {
  const _DesktopGrid({required this.projects, required this.attention});

  final List<Project> projects;
  final List<Order> attention;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 62,
                child: _TodayWorkCard(
                  project: projects.isNotEmpty ? projects.first : null,
                  onOpen: () => context.go(Routes.projects),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(flex: 38, child: _ScheduleCard()),
            ],
          ),
        ),
        const SizedBox(height: 16),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _TasksCard(orders: attention)),
              const SizedBox(width: 16),
              Expanded(
                child: _ProjectsCard(projects: projects.take(3).toList()),
              ),
              const SizedBox(width: 16),
              const Expanded(child: _AlertsCard()),
            ],
          ),
        ),
      ],
    );
  }
}

class _GreetingRow extends StatelessWidget {
  const _GreetingRow({required this.firstName});

  final String firstName;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'God dag, $firstName 👋',
                style: AppTypography.title1.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Her er oversikten for i dag.',
                style: AppTypography.callout.copyWith(
                  color: AppColors.labelSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CupertinoIcons.cloud,
                size: 22,
                color: AppColors.labelSecondary,
              ),
              const SizedBox(width: 10),
              Text('16°C', style: AppTypography.headline),
              const SizedBox(width: 10),
              Text('Skyet, Oslo', style: AppTypography.caption),
            ],
          ),
        ),
      ],
    );
  }
}

class _TodayWorkCard extends StatelessWidget {
  const _TodayWorkCard({required this.project, required this.onOpen});

  final Project? project;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final title = project?.displayName ?? 'Test2';
    final location =
        project?.subtitle ?? 'Torvhaugan Omsorgsbolig';

    return Container(
      constraints: const BoxConstraints(minHeight: 300),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 340,
            child: _HeroBuildingArt(),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.surface,
                    AppColors.surface.withValues(alpha: 0.92),
                    AppColors.surface.withValues(alpha: 0.55),
                    Colors.transparent,
                  ],
                  stops: const [0, 0.45, 0.7, 1],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dagens arbeid',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.labelSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _ProgressRing(progress: 0.62, size: 128),
                    const SizedBox(width: 28),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PÅGÅENDE PROSJEKT',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.labelSecondary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            title,
                            style: AppTypography.title1.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                CupertinoIcons.location_solid,
                                size: 14,
                                color: AppColors.labelSecondary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  location,
                                  style: AppTypography.callout,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '07:00 – 15:00',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.labelSecondary,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            children: const [
                              _Chip(
                                icon: CupertinoIcons.car_detailed,
                                label: '25 min unna',
                              ),
                              _Chip(
                                icon: CupertinoIcons.list_bullet,
                                label: '2 oppgaver i dag',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: 24,
            bottom: 24,
            child: DashboardPrimaryButton(
              label: 'Åpne prosjekt',
              icon: Icons.chevron_right,
              onPressed: onOpen,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dekorativ «bygnings»-flate på høyre side av hero-kortet.
class _HeroBuildingArt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2A3448), Color(0xFF141A24)],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _BuildingSilhouettePainter()),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.surface.withValues(alpha: 0.85),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BuildingSilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF3D4A62);
    final w = size.width;
    final h = size.height;

    final rects = [
      Rect.fromLTWH(w * 0.08, h * 0.35, w * 0.35, h * 0.65),
      Rect.fromLTWH(w * 0.38, h * 0.22, w * 0.42, h * 0.78),
      Rect.fromLTWH(w * 0.62, h * 0.45, w * 0.32, h * 0.55),
    ];
    for (final r in rects) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(6)),
        paint,
      );
    }

    final window = Paint()..color = const Color(0xFF6B7A96).withValues(alpha: 0.5);
    for (var i = 0; i < 8; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          w * 0.42 + (i % 2) * 18,
          h * 0.32 + (i ~/ 2) * 22,
          12,
          14,
        ),
        window,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.progress, required this.size});

  final double progress;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(progress: progress),
          ),
          Text(
            '${(progress * 100).round()}%',
            style: AppTypography.title1.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 10.0;
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - stroke;

    final bg = Paint()
      ..color = const Color(0xFF252B38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final fg = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bg);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: AppColors.labelSecondary),
            const SizedBox(width: 6),
          ],
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard();

  static const _items = [
    (
      time: '07:00',
      title: 'Start arbeidsdag',
      subtitle: 'Verksted',
      color: AppColors.accent,
    ),
    (
      time: '07:30',
      title: 'Kjøring til prosjekt',
      subtitle: 'Test2',
      color: AppColors.accent,
    ),
    (
      time: '08:00',
      title: 'Monter stikk i leilighet 101',
      subtitle: 'Test2 · Plan 1',
      color: AppColors.success,
    ),
    (
      time: '10:30',
      title: 'Monter nødlys i trapp 2',
      subtitle: 'Test2 · Plan 1',
      color: AppColors.warning,
    ),
    (
      time: '13:00',
      title: 'Kontroller brannsentral',
      subtitle: 'Test2 · Plan 1',
      color: Color(0xFF9A8BFF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      header: 'Dagens timeplan',
      trailingLink: 'Se full dag',
      child: Column(
        children: [
          for (var i = 0; i < _items.length; i++)
            _TimelineRow(
              time: _items[i].time,
              title: _items[i].title,
              subtitle: _items[i].subtitle,
              dotColor: _items[i].color,
              isLast: i == _items.length - 1,
            ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.time,
    required this.title,
    required this.subtitle,
    required this.dotColor,
    required this.isLast,
  });

  final String time;
  final String title;
  final String subtitle;
  final Color dotColor;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0 : 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 42,
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(time, style: AppTypography.caption),
              ),
            ),
            SizedBox(
              width: 20,
              child: Column(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: dotColor.withValues(alpha: 0.35),
                        width: 3,
                      ),
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: AppColors.separatorOpaque,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.callout.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTypography.caption),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoTask {
  const _DemoTask({
    required this.title,
    required this.location,
    required this.time,
    this.done = false,
  });

  final String title;
  final String location;
  final String time;
  final bool done;
}

class _TasksCard extends StatelessWidget {
  const _TasksCard({required this.orders});

  final List<Order> orders;

  static const _demo = [
    _DemoTask(
      title: 'Monter stikk i leilighet 101',
      location: 'Test2 · Plan 1',
      time: '08:00',
      done: true,
    ),
    _DemoTask(
      title: 'Monter nødlys i trapp 2',
      location: 'Test2 · Plan 1',
      time: '10:30',
    ),
    _DemoTask(
      title: 'Kontroller brannsentral',
      location: 'Test2 · Plan 1',
      time: '13:00',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      header: 'Oppgaver i dag',
      trailingLink: 'Se alle',
      onTrailingTap: () => context.go(Routes.orders),
      child: Column(
        children: [
          for (var i = 0; i < _demo.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            _TaskRow(
              done: _demo[i].done,
              title: _demo[i].title,
              location: _demo[i].location,
              time: _demo[i].time,
            ),
          ],
          if (orders.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 14),
            for (var i = 0; i < orders.length && i < 2; i++) ...[
              if (i > 0) const SizedBox(height: 14),
              _TaskRow(
                title: orders[i].displayTitle,
                location: orderStatusLabel(orders[i].status),
                time: '—',
              ),
            ],
          ],
          const SizedBox(height: 8),
          DashboardLinkButton(
            label: 'Åpne alle oppgaver',
            onPressed: () => context.go(Routes.orders),
          ),
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.title,
    required this.location,
    required this.time,
    this.done = false,
  });

  final bool done;
  final String title;
  final String location;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(
            done
                ? CupertinoIcons.checkmark_circle_fill
                : CupertinoIcons.circle,
            color: done ? AppColors.success : AppColors.labelTertiary,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.callout.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(location, style: AppTypography.caption),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          time,
          style: AppTypography.caption.copyWith(
            color: AppColors.labelSecondary,
          ),
        ),
      ],
    );
  }
}

class _ProjectsCard extends StatelessWidget {
  const _ProjectsCard({required this.projects});

  final List<Project> projects;

  static const _demoPercents = [0.62, 0.35, 0.18];
  static const _demoNames = [
    'Torvhaugan Omsorgsbolig',
    'Fjordveien 12',
    'Industripark Nord',
  ];
  static const _demoCategories = [
    'Bolig · Elektro',
    'Næring · Service',
    'Industri',
  ];

  @override
  Widget build(BuildContext context) {
    final rows = projects.isEmpty
        ? List.generate(
            3,
            (i) => (
              name: _demoNames[i],
              category: _demoCategories[i],
              progress: _demoPercents[i],
            ),
          )
        : [
            for (var i = 0; i < projects.length && i < 3; i++)
              (
                name: projects[i].displayName,
                category: projectStatusLabel(projects[i].status),
                progress: _demoPercents[i % 3],
              ),
          ];

    return DashboardCard(
      header: 'Siste prosjekter',
      trailingLink: 'Se alle',
      onTrailingTap: () => context.go(Routes.projects),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            _ProjectRow(
              name: rows[i].name,
              category: rows[i].category,
              progress: rows[i].progress,
            ),
          ],
          const SizedBox(height: 8),
          DashboardLinkButton(
            label: 'Åpne prosjekter',
            onPressed: () => context.go(Routes.projects),
          ),
        ],
      ),
    );
  }
}

class _ProjectRow extends StatelessWidget {
  const _ProjectRow({
    required this.name,
    required this.category,
    required this.progress,
  });

  final String name;
  final String category;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round();

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: const _ProjectThumb(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppTypography.callout.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(category, style: AppTypography.caption),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 5,
                        backgroundColor: AppColors.accentSoft,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$pct%',
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProjectThumb extends StatelessWidget {
  const _ProjectThumb();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3A4A62), Color(0xFF1E2634)],
        ),
      ),
      child: CustomPaint(painter: _MiniBuildingPainter()),
    );
  }
}

class _MiniBuildingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFF5A6B84);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.2, size.height * 0.25, size.width * 0.6,
            size.height * 0.65),
        const Radius.circular(3),
      ),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AlertsCard extends StatelessWidget {
  const _AlertsCard();

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      header: 'Varsler',
      badge: '3',
      trailingLink: 'Se alle',
      child: Column(
        children: const [
          _AlertRow(
            icon: CupertinoIcons.exclamationmark_triangle,
            color: AppColors.warning,
            title: 'Provisorisk åpning mangler dokumentasjon',
            time: '2t siden',
          ),
          SizedBox(height: 14),
          _AlertRow(
            icon: CupertinoIcons.doc_text,
            color: AppColors.label,
            title: 'LiDAR-forespørsel mottatt',
            time: '5t siden',
          ),
          SizedBox(height: 14),
          _AlertRow(
            icon: CupertinoIcons.checkmark_circle,
            color: AppColors.success,
            title: 'Ordre merket som fullført',
            time: 'I går',
          ),
        ],
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.time,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.callout.copyWith(height: 1.35),
              ),
              const SizedBox(height: 2),
              Text(time, style: AppTypography.caption),
            ],
          ),
        ),
      ],
    );
  }
}

void _snack(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.surfaceElevated,
    ),
  );
}

class _QuickActions extends ConsumerWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attention = ref.watch(attentionOrdersProvider);

    final actions = [
      (
        CupertinoIcons.play_fill,
        'Start timer',
        AppColors.success,
        () {
          if (attention.isNotEmpty) {
            context.go('${Routes.orders}/${attention.first.id}');
            _snack(context, 'Trykk «Registrer timer» på ordren');
          } else {
            context.go(Routes.orders);
          }
        },
      ),
      (
        CupertinoIcons.plus_circle_fill,
        'Ny oppgave',
        AppColors.accent,
        () => _snack(context, 'Oppgaver kommer i neste fase'),
      ),
      (
        CupertinoIcons.cube_box_fill,
        'Registrer materiell',
        const Color(0xFF9A8BFF),
        () => context.go(Routes.orders),
      ),
      (
        CupertinoIcons.camera_fill,
        'Ta bilde',
        AppColors.warning,
        () => _snack(context, 'Bildeopplasting kommer snart'),
      ),
      (
        CupertinoIcons.exclamationmark_triangle_fill,
        'Nytt avvik',
        AppColors.destructive,
        () => _snack(context, 'Avvik kommer i neste fase'),
      ),
      (
        CupertinoIcons.plus_rectangle_fill,
        'Ny ordre',
        AppColors.success,
        () => context.go(Routes.orders),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hurtighandlinger',
          style: AppTypography.headline.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, c) {
            final cols = c.maxWidth > 900 ? 6 : 3;
            final gap = 12.0;
            final w = (c.maxWidth - (cols - 1) * gap) / cols;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: actions.map((a) {
                return SizedBox(
                  width: w,
                  child: _QuickActionTile(
                    icon: a.$1,
                    label: a.$2,
                    iconColor: a.$3,
                    onTap: a.$4,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Icon(icon, size: 24, color: iconColor),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

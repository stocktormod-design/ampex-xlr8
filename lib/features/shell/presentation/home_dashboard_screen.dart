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

/// Pro dashboard – matcher referansedesign (hvitt accent).
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
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _GreetingRow(firstName: _firstName),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              if (!wide) {
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
              return Column(
                children: [
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _TodayWorkCard(
                            project: projects.isNotEmpty
                                ? projects.first
                                : null,
                            onOpen: () => context.go(Routes.projects),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(flex: 3, child: _ScheduleCard()),
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
                          child: _ProjectsCard(
                            projects: projects.take(3).toList(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(child: _AlertsCard()),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          const _QuickActions(),
        ],
      ),
    );
  }
}

class _GreetingRow extends StatelessWidget {
  const _GreetingRow({required this.firstName});

  final String firstName;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'God dag, $firstName 👋',
                style: AppTypography.title1.copyWith(
                  fontSize: 26,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Her er oversikten for i dag.',
                style: AppTypography.callout,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(
                CupertinoIcons.cloud,
                size: 20,
                color: AppColors.labelSecondary,
              ),
              const SizedBox(width: 8),
              Text('16°C', style: AppTypography.headline),
              const SizedBox(width: 8),
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
    final title = project?.displayName ?? 'Ingen aktivt prosjekt';
    final subtitle = project?.subtitle ?? 'Velg et prosjekt for å starte dagen';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C2230), Color(0xFF10141C)],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.15,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomRight,
                      end: Alignment.topLeft,
                      colors: [Color(0xFF2A3348), Colors.transparent],
                    ),
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
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _ProgressRing(progress: 0.62, size: 120),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: AppTypography.title1),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  CupertinoIcons.location,
                                  size: 14,
                                  color: AppColors.labelSecondary,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    subtitle,
                                    style: AppTypography.callout,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('07:00 – 15:00', style: AppTypography.caption),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
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
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: DashboardPrimaryButton(
                      label: 'Åpne prosjekt',
                      icon: Icons.chevron_right,
                      onPressed: onOpen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
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
            style: AppTypography.title1.copyWith(fontSize: 22),
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
    final stroke = 8.0;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.width / 2 - stroke;

    final bg = Paint()
      ..color = AppColors.accentSoft
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
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
    (time: '07:00', title: 'Start arbeidsdag', color: AppColors.accent),
    (
      time: '07:30',
      title: 'Kjøring til prosjekt',
      color: AppColors.labelTertiary,
    ),
    (
      time: '08:00',
      title: 'Monter stikk i leilighet 101',
      color: AppColors.success,
    ),
    (time: '10:30', title: 'Monter nødlys i trapp 2', color: AppColors.warning),
    (time: '13:00', title: 'Kontroller brannsentral', color: Color(0xFF9A8BFF)),
  ];

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      header: 'Dagens timeplan',
      trailingLink: 'Se full dag',
      child: Column(
        children: [
          for (var i = 0; i < _items.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 44,
                  child: Text(_items[i].time, style: AppTypography.caption),
                ),
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: _items[i].color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(_items[i].title, style: AppTypography.callout),
                ),
              ],
            ),
            if (i < _items.length - 1) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _TasksCard extends StatelessWidget {
  const _TasksCard({required this.orders});

  final List<Order> orders;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      header: 'Oppgaver i dag',
      trailingLink: 'Se alle',
      child: Column(
        children: [
          if (orders.isEmpty)
            Text(
              'Ingen oppgaver som krever handling.',
              style: AppTypography.callout,
            )
          else
            for (var i = 0; i < orders.length && i < 4; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              _TaskRow(
                done: false,
                title: orders[i].displayTitle,
                meta: orderStatusLabel(orders[i].status),
              ),
            ],
          const SizedBox(height: 12),
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
  const _TaskRow({required this.done, required this.title, required this.meta});

  final bool done;
  final String title;
  final String meta;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          done ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle,
          color: done ? AppColors.success : AppColors.labelTertiary,
          size: 22,
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(meta, style: AppTypography.caption),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProjectsCard extends StatelessWidget {
  const _ProjectsCard({required this.projects});

  final List<Project> projects;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      header: 'Siste prosjekter',
      trailingLink: 'Se alle',
      onTrailingTap: () => context.go(Routes.projects),
      child: Column(
        children: [
          if (projects.isEmpty)
            Text('Ingen prosjekter ennå.', style: AppTypography.callout)
          else
            for (var i = 0; i < projects.length; i++) ...[
              if (i > 0) const SizedBox(height: 14),
              _ProjectRow(project: projects[i]),
            ],
          const SizedBox(height: 12),
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
  const _ProjectRow({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final progress = project.status == 'completed'
        ? 1.0
        : project.status == 'active'
        ? 0.55
        : 0.2;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceHighlight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(
            CupertinoIcons.building_2_fill,
            size: 20,
            color: AppColors.labelSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.displayName,
                style: AppTypography.callout.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                projectStatusLabel(project.status),
                style: AppTypography.caption,
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: AppColors.accentSoft,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AlertsCard extends StatelessWidget {
  const _AlertsCard();

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      header: 'Varsler',
      trailingLink: 'Se alle',
      child: Column(
        children: const [
          _AlertRow(
            icon: CupertinoIcons.exclamationmark_triangle,
            color: AppColors.warning,
            title: 'Avvik venter på godkjenning',
            time: '2t siden',
          ),
          SizedBox(height: 12),
          _AlertRow(
            icon: CupertinoIcons.doc_text,
            color: AppColors.label,
            title: 'Ny tegning publisert',
            time: '5t siden',
          ),
          SizedBox(height: 12),
          _AlertRow(
            icon: CupertinoIcons.checkmark_circle,
            color: AppColors.success,
            title: 'Ordre fullført',
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
              Text(title, style: AppTypography.callout),
              Text(time, style: AppTypography.caption),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final actions = [
      (CupertinoIcons.time, 'Start timer', () {}),
      (CupertinoIcons.plus_circle, 'Ny oppgave', () {}),
      (CupertinoIcons.cube_box, 'Registrer materiell', () {}),
      (CupertinoIcons.camera, 'Ta bilde', () {}),
      (CupertinoIcons.exclamationmark_triangle, 'Nytt avvik', () {}),
      (CupertinoIcons.doc_text, 'Ny ordre', () => context.go(Routes.orders)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hurtighandlinger',
          style: AppTypography.caption.copyWith(
            color: AppColors.labelSecondary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, c) {
            final cols = c.maxWidth > 700 ? 6 : 3;
            final w = (c.maxWidth - (cols - 1) * 12) / cols;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: actions.map((a) {
                return SizedBox(
                  width: w,
                  child: _QuickActionTile(icon: a.$1, label: a.$2, onTap: a.$3),
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
    required this.onTap,
  });

  final IconData icon;
  final String label;
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
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Icon(icon, size: 22, color: AppColors.label),
              const SizedBox(height: 8),
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

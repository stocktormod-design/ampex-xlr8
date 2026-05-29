import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/session_providers.dart';
import '../../../core/network/supabase_provider.dart';
import '../../../core/sync/sync_providers.dart';
import '../../../core/storage/storage_buckets.dart';
import '../../../core/theme/app_breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/ampex_empty_state.dart';
import '../../../core/widgets/ampex_grouped_section.dart';
import '../../../core/widgets/ampex_list_row.dart';
import '../../../core/widgets/ampex_scaffold.dart';
import '../../shared/documentation_labels.dart';
import '../../shared/status_labels.dart';
import '../../shared/status_pill.dart';
import '../domain/order.dart';
import '../domain/order_detail.dart';
import 'add_order_hour_sheet.dart';
import 'orders_providers.dart';

final orderPhotoUrlProvider =
    FutureProvider.autoDispose.family<String?, String>((ref, path) async {
  final client = ref.watch(supabaseClientProvider);
  try {
    return await client.storage
        .from(StorageBuckets.orderPhotos)
        .createSignedUrl(path, 3600);
  } catch (_) {
    return null;
  }
});

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(orderDetailProvider(id));
    final hPad = context.isMobile ? AppSpacing.screenH : AppSpacing.xl;
    final dateFmt = DateFormat('d. MMM yyyy', 'nb');
    final dateTimeFmt = DateFormat('d. MMM yyyy, HH:mm', 'nb');

    return detailAsync.when(
      loading: () => AmpexScaffold(
        title: 'Ordre',
        onBack: () => context.pop(),
        slivers: const [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        ],
      ),
      error: (_, _) => AmpexScaffold(
        title: 'Ordre',
        onBack: () => context.pop(),
        slivers: const [
          SliverFillRemaining(
            hasScrollBody: false,
            child: AmpexEmptyState(
              icon: CupertinoIcons.exclamationmark_triangle,
              title: 'Kunne ikke laste',
              body: 'Ordren finnes ikke eller du har ikke tilgang.',
            ),
          ),
        ],
      ),
      data: (detail) {
        if (detail == null) {
          return AmpexScaffold(
            title: 'Ordre',
            onBack: () => context.pop(),
            slivers: const [
              SliverFillRemaining(
                hasScrollBody: false,
                child: AmpexEmptyState(
                  icon: CupertinoIcons.doc_text,
                  title: 'Ikke funnet',
                  body: 'Ordren finnes ikke.',
                ),
              ),
            ],
          );
        }

        final order = detail.order;
        final userId = ref.watch(sessionContextProvider).valueOrNull?.profile.id;

        return AmpexScaffold(
          title: order.displayTitle,
          subtitle: order.subtitle != null
              ? Text(order.subtitle!, style: const TextStyle(fontSize: 15))
              : null,
          onBack: () => context.pop(),
          onRefresh: () async {
            ref.invalidate(orderDetailProvider(id));
          },
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(hPad, 0, hPad, AppSpacing.md),
                    child: StatusPill(
                      label: orderStatusLabel(order.status),
                      color: orderStatusColor(order.status),
                    ),
                  ),
                  AmpexGroupedSection(
                    margin: EdgeInsets.symmetric(horizontal: hPad),
                    header: 'Oversikt',
                    dividerIndent: AppSpacing.rowH,
                    children: [
                      AmpexListRow(
                        title: 'Status',
                        value: orderStatusLabel(order.status),
                        showChevron: false,
                      ),
                      AmpexListRow(
                        title: 'Type',
                        value: orderTypeLabel(order.type),
                        showChevron: false,
                      ),
                      if (detail.assignedInstallerName != null)
                        AmpexListRow(
                          title: 'Ansvarlig',
                          value: detail.assignedInstallerName,
                          showChevron: false,
                        ),
                      if (order.createdAt != null)
                        AmpexListRow(
                          title: 'Opprettet',
                          value: dateFmt.format(order.createdAt!.toLocal()),
                          showChevron: false,
                        ),
                      AmpexListRow(
                        title: 'Oppdatert',
                        value: dateTimeFmt.format(order.updatedAt.toLocal()),
                        showChevron: false,
                      ),
                      if (order.archiveReference != null &&
                          order.archiveReference!.isNotEmpty)
                        AmpexListRow(
                          title: 'Arkivref.',
                          value: order.archiveReference,
                          showChevron: false,
                        ),
                    ],
                  ),
                  if (_hasCustomer(order)) ...[
                    const SizedBox(height: AppSpacing.sectionGap),
                    AmpexGroupedSection(
                      margin: EdgeInsets.symmetric(horizontal: hPad),
                      header: 'Kunde',
                      dividerIndent: AppSpacing.rowH,
                      children: [
                        if (order.customer.name != null &&
                            order.customer.name!.isNotEmpty)
                          AmpexListRow(
                            title: 'Navn',
                            value: order.customer.name,
                            showChevron: false,
                          ),
                        if (order.customer.phone != null &&
                            order.customer.phone!.isNotEmpty)
                          AmpexListRow(
                            title: 'Telefon',
                            value: order.customer.phone,
                            showChevron: false,
                          ),
                        if (order.customer.address != null &&
                            order.customer.address!.isNotEmpty)
                          AmpexListRow(
                            title: 'Adresse',
                            value: order.customer.address,
                            showChevron: false,
                          ),
                      ],
                    ),
                  ],
                  if (order.description != null &&
                      order.description!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sectionGap),
                    AmpexGroupedSection(
                      margin: EdgeInsets.symmetric(horizontal: hPad),
                      header: 'Beskrivelse',
                      dividerIndent: AppSpacing.rowH,
                      children: [
                        AmpexListRow(
                          title: order.description!,
                          showChevron: false,
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sectionGap),
                  _HoursSection(
                    detail: detail,
                    hPad: hPad,
                    dateFmt: dateFmt,
                    orderId: id,
                    userId: userId,
                    onRegistered: () {
                      ref.invalidate(orderDetailProvider(id));
                      ref.invalidate(ordersListProvider);
                      ref.invalidate(pendingSyncCountProvider);
                      unawaited(
                        ref.read(syncEngineProvider).runOnce().then((_) {
                          ref.invalidate(pendingSyncCountProvider);
                        }),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.sectionGap),
                  _MaterialsSection(detail: detail, hPad: hPad),
                  const SizedBox(height: AppSpacing.sectionGap),
                  _DocumentationSection(detail: detail, hPad: hPad),
                  const SizedBox(height: AppSpacing.sectionGap),
                  _PhotosSection(detail: detail, hPad: hPad),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  bool _hasCustomer(Order order) {
    final c = order.customer;
    return (c.name?.isNotEmpty ?? false) ||
        (c.phone?.isNotEmpty ?? false) ||
        (c.address?.isNotEmpty ?? false);
  }
}

class _HoursSection extends StatelessWidget {
  const _HoursSection({
    required this.detail,
    required this.hPad,
    required this.dateFmt,
    required this.orderId,
    required this.userId,
    required this.onRegistered,
  });

  final OrderDetail detail;
  final double hPad;
  final DateFormat dateFmt;
  final String orderId;
  final String? userId;
  final VoidCallback onRegistered;

  Future<void> _register(BuildContext context) async {
    final uid = userId;
    if (uid == null) return;
    final saved = await showAddOrderHourSheet(
      context,
      orderId: orderId,
      userId: uid,
    );
    if (saved == true) onRegistered();
  }

  @override
  Widget build(BuildContext context) {
    final total = detail.totalMinutes;
    final totalLabel = total >= 60
        ? '${total ~/ 60}t ${total % 60 > 0 ? '${total % 60}min' : ''}'.trim()
        : '${total}min';

    final rows = <Widget>[
      if (userId != null)
        AmpexListRow(
          leading: CupertinoIcons.plus_circle_fill,
          leadingColor: AppColors.accent,
          title: 'Registrer timer',
          onTap: () => _register(context),
        ),
      if (detail.hours.isEmpty && userId != null)
        const AmpexListRow(
          leading: CupertinoIcons.time,
          title: 'Ingen timer ennå',
          showChevron: false,
        ),
      for (final hour in detail.hours)
        AmpexListRow(
          leading: CupertinoIcons.time,
          leadingColor: AppColors.accent,
          title: dateFmt.format(hour.workDate.toLocal()),
          subtitle: hour.userName,
          value: hour.hoursLabel,
          showChevron: false,
        ),
    ];

    return AmpexGroupedSection(
      margin: EdgeInsets.symmetric(horizontal: hPad),
      header: 'Timer',
      footer: detail.hours.isEmpty
          ? 'Timer lagres lokalt offline og synkes automatisk.'
          : 'Totalt $totalLabel',
      dividerIndent: userId != null ? 64 : AppSpacing.rowH,
      children: rows,
    );
  }
}

class _MaterialsSection extends StatelessWidget {
  const _MaterialsSection({required this.detail, required this.hPad});

  final OrderDetail detail;
  final double hPad;

  @override
  Widget build(BuildContext context) {
    if (detail.materials.isEmpty) {
      return AmpexGroupedSection(
        margin: EdgeInsets.symmetric(horizontal: hPad),
        header: 'Materiell',
        dividerIndent: AppSpacing.rowH,
        children: const [
          AmpexListRow(
            leading: CupertinoIcons.cube_box,
            title: 'Ingen materiell',
            showChevron: false,
          ),
        ],
      );
    }

    return AmpexGroupedSection(
      margin: EdgeInsets.symmetric(horizontal: hPad),
      header: 'Materiell',
      dividerIndent: AppSpacing.rowH,
      children: [
        for (final m in detail.materials)
          AmpexListRow(
            leading: CupertinoIcons.cube_box,
            leadingColor: AppColors.labelSecondary,
            title: m.name,
            subtitle: m.note,
            value: m.quantityLabel,
            showChevron: false,
          ),
      ],
    );
  }
}

class _DocumentationSection extends StatelessWidget {
  const _DocumentationSection({required this.detail, required this.hPad});

  final OrderDetail detail;
  final double hPad;

  @override
  Widget build(BuildContext context) {
    if (detail.documentation.isEmpty) {
      return AmpexGroupedSection(
        margin: EdgeInsets.symmetric(horizontal: hPad),
        header: 'Dokumentasjon',
        dividerIndent: AppSpacing.rowH,
        children: const [
          AmpexListRow(
            leading: CupertinoIcons.doc_plaintext,
            title: 'Ingen dokumentasjon',
            showChevron: false,
          ),
        ],
      );
    }

    return AmpexGroupedSection(
      margin: EdgeInsets.symmetric(horizontal: hPad),
      header: 'Dokumentasjon',
      dividerIndent: AppSpacing.rowH,
      children: [
        for (final doc in detail.documentation)
          AmpexListRow(
            leading: doc.isCompleted
                ? CupertinoIcons.checkmark_circle_fill
                : CupertinoIcons.circle,
            leadingColor: doc.isCompleted
                ? AppColors.statusDone
                : AppColors.labelTertiary,
            title: orderDocumentationLabel(doc.templateType),
            subtitle: doc.sectionKey.isNotEmpty ? doc.sectionKey : null,
            value: doc.isCompleted ? 'Ferdig' : 'Mangler',
            showChevron: false,
          ),
      ],
    );
  }
}

class _PhotosSection extends ConsumerWidget {
  const _PhotosSection({required this.detail, required this.hPad});

  final OrderDetail detail;
  final double hPad;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (detail.photos.isEmpty) {
      return AmpexGroupedSection(
        margin: EdgeInsets.symmetric(horizontal: hPad),
        header: 'Bilder',
        dividerIndent: AppSpacing.rowH,
        children: const [
          AmpexListRow(
            leading: CupertinoIcons.photo,
            title: 'Ingen bilder',
            showChevron: false,
          ),
        ],
      );
    }

    return AmpexGroupedSection(
      margin: EdgeInsets.symmetric(horizontal: hPad),
      header: 'Bilder',
      footer: '${detail.photos.length} bilde(r)',
      dividerIndent: AppSpacing.rowH,
      children: [
        for (final photo in detail.photos)
          _PhotoRow(photo: photo),
      ],
    );
  }
}

class _PhotoRow extends ConsumerWidget {
  const _PhotoRow({required this.photo});

  final OrderPhotoEntry photo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urlAsync = ref.watch(orderPhotoUrlProvider(photo.filePath));

    return AmpexListRow(
      leading: CupertinoIcons.photo,
      leadingColor: AppColors.accent,
      title: photo.caption ?? photo.photoType ?? 'Bilde',
      showChevron: false,
      onTap: urlAsync.valueOrNull != null
          ? () => _showPhoto(context, urlAsync.value!)
          : null,
    );
  }

  void _showPhoto(BuildContext context, String url) {
    final size = MediaQuery.sizeOf(context);
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.surface,
        child: SizedBox(
          width: size.width * 0.92,
          height: size.height * 0.72,
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(photo.caption ?? 'Bilde'),
                leading: IconButton(
                  icon: const Icon(CupertinoIcons.xmark),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: InteractiveViewer(
                  child: Image.network(url, fit: BoxFit.contain),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

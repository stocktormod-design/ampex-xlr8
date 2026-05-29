import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Norske etiketter for `order_status` fra Supabase.
String orderStatusLabel(String status) => switch (status) {
      'active' => 'Pågår',
      'awaiting_installer' => 'Venter montør',
      'approved' => 'Godkjent',
      'finished' => 'Ferdig',
      'archived' => 'Arkivert',
      'rejected' => 'Avslått',
      _ => status,
    };

Color orderStatusColor(String status) => switch (status) {
      'active' => AppColors.statusActive,
      'awaiting_installer' => AppColors.statusWaiting,
      'approved' => AppColors.statusDone,
      'finished' => AppColors.statusDone,
      'archived' => AppColors.statusNeutral,
      'rejected' => AppColors.destructive,
      _ => AppColors.statusNeutral,
    };

String orderTypeLabel(String? type) => switch (type) {
      'bolig' => 'Bolig',
      'maritim' => 'Maritim',
      'kompleks' => 'Kompleks',
      null || '' => '—',
      _ => type,
    };

/// Norske etiketter for `project_status` fra Supabase.
String projectStatusLabel(String status) => switch (status) {
      'planning' => 'Planlegging',
      'active' => 'Pågår',
      'completed' => 'Fullført',
      _ => status,
    };

Color projectStatusColor(String status) => switch (status) {
      'planning' => AppColors.statusWaiting,
      'active' => AppColors.statusActive,
      'completed' => AppColors.statusDone,
      _ => AppColors.statusNeutral,
    };

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_scaffold.dart';

/// Erstattes med prosjektliste og PDF i fase 1.
class ProjectsPlaceholderScreen extends StatelessWidget {
  const ProjectsPlaceholderScreen({super.key, this.id});

  final String? id;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: id == null ? 'Prosjekter' : 'Prosjekt',
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.apartment_outlined, size: 48),
              const SizedBox(height: 16),
              Text(
                id == null
                    ? 'Prosjektliste kommer i fase 1'
                    : 'Prosjektdetalj og PDF for $id kommer i fase 1',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              FilledButton.tonal(
                onPressed: () => context.pop(),
                child: const Text('Tilbake'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

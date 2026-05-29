import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_scaffold.dart';

/// Erstattes med ordreliste i fase 1.
class OrdersPlaceholderScreen extends StatelessWidget {
  const OrdersPlaceholderScreen({super.key, this.id});

  final String? id;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: id == null ? 'Ordre' : 'Ordre',
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.assignment_outlined, size: 48),
              const SizedBox(height: 16),
              Text(
                id == null
                    ? 'Ordreliste kommer i fase 1'
                    : 'Ordredetalj $id kommer i fase 1',
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

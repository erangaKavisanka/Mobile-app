import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/common.dart';
import '../../../shared/widgets/eco_card.dart';
import '../../../shared/widgets/state_views.dart';
import '../domain/sos_event.dart';
import 'sos_screen.dart';
import 'sos_widgets.dart';

class SosDetailScreen extends ConsumerWidget {
  const SosDetailScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = ref.watch(sosEventProvider(eventId));
    final local = ref.watch(localNodeIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('SOS details')),
      body: AsyncValueView<SosEvent?>(
        value: event,
        data: (e) {
          if (e == null) {
            return const EmptyState(
              icon: Icons.search_off,
              title: 'Event not found',
              message: 'This SOS event no longer exists on this phone.',
            );
          }
          final isOwn = e.sourceNodeId == local;
          return ListView(
            padding: const EdgeInsets.all(Spacing.lg),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isOwn ? 'Your SOS' : 'SOS from ${e.sourceNodeId}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  SosStatusPill(e.status),
                ],
              ),
              const SectionHeader('Lifecycle'),
              EcoCard(
                child: SosTimeline(event: e, isOwn: isOwn),
              ),
              const SectionHeader('Details'),
              EcoCard(
                child: Column(
                  children: [
                    InfoRow('Event ID', e.id),
                    InfoRow('Source', e.sourceNodeId),
                    InfoRow('Created', Formatters.dateTime(e.createdAt)),
                    InfoRow(
                      'Location',
                      e.hasLocation
                          ? '${Formatters.coordinates(e.latitude!, e.longitude!)}\n${Formatters.accuracy(e.accuracy)}'
                          : 'Not attached',
                    ),
                    if (e.note != null) InfoRow('Note', e.note!),
                  ],
                ),
              ),
              if (e.hasLocation) ...[
                const SizedBox(height: Spacing.md),
                OutlinedButton.icon(
                  onPressed: () => context.go(
                    '${AppRoutes.map}?lat=${e.latitude}&lon=${e.longitude}',
                  ),
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Show on map'),
                ),
              ],
              if (e.isActive && isOwn) ...[
                const SizedBox(height: Spacing.xl),
                if (e.status == SosStatus.failed) ...[
                  FilledButton.icon(
                    onPressed: () => ref.read(sosServiceProvider).retry(e.id),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry sending'),
                  ),
                  const SizedBox(height: Spacing.sm),
                ],
                FilledButton(
                  onPressed: () => resolveSos(context, ref, e),
                  child: const Text('Mark as resolved'),
                ),
                const SizedBox(height: Spacing.sm),
                OutlinedButton(
                  onPressed: () => cancelSos(context, ref, e),
                  child: const Text('Cancel SOS (sent by mistake)'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

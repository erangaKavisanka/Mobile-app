import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/common.dart';
import '../../../shared/widgets/eco_card.dart';
import '../../../shared/widgets/state_views.dart';
import '../../../shared/widgets/status_pill.dart';
import '../domain/sync_item.dart';

class SyncScreen extends ConsumerStatefulWidget {
  const SyncScreen({super.key});

  @override
  ConsumerState<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends ConsumerState<SyncScreen> {
  bool _running = false;

  Future<void> _run({bool retry = false}) async {
    setState(() => _running = true);
    final service = ref.read(syncServiceProvider);
    final result = await (retry
        ? service.retryFailed()
        : service.syncNow(force: true));
    if (!mounted) return;
    setState(() => _running = false);
    showMessage(
      context,
      result.synced + result.failed == 0
          ? 'Nothing to synchronize.'
          : '${result.synced} uploaded, ${result.failed} failed.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(syncSummaryProvider).value ?? const SyncSummary();
    final items = ref.watch(syncItemsProvider);
    final prefs = ref.watch(preferencesProvider).value;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Synchronization')),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          EcoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Expanded(child: Text('Cloud sync')),
                    SimulatedBadge(label: 'SIMULATED CLOUD'),
                  ],
                ),
                const SizedBox(height: Spacing.sm),
                Text(
                  'No real cloud is connected yet. Uploads only "succeed" while the simulated Internet switch below is on, and no data leaves this phone.',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: Spacing.lg),
                Row(
                  children: [
                    _Count('Pending', summary.pending),
                    _Count('Failed', summary.failed),
                    _Count('Uploaded', summary.synced),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                InfoRow(
                  'Last sync',
                  summary.lastSyncedAt == null
                      ? 'Never'
                      : Formatters.dateTime(summary.lastSyncedAt!),
                ),
                if (summary.lastError != null)
                  InfoRow('Last error', summary.lastError!),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
            title: const Text('Simulate Internet connection'),
            subtitle: const Text('Lets the simulated cloud accept uploads'),
            value: prefs?.simulateInternet ?? false,
            onChanged: prefs == null
                ? null
                : (v) => ref
                      .read(settingsRepositoryProvider)
                      .save(prefs.copyWith(simulateInternet: v)),
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _running ? null : _run,
                  icon: const Icon(Icons.cloud_upload_outlined),
                  label: const Text('Sync now'),
                ),
              ),
              if (summary.failed > 0) ...[
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _running ? null : () => _run(retry: true),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry failed'),
                  ),
                ),
              ],
            ],
          ),
          const SectionHeader('Queue'),
          AsyncValueView<List<SyncItem>>(
            value: items,
            data: (list) => list.isEmpty
                ? const SizedBox(
                    height: 200,
                    child: EmptyState(
                      icon: Icons.cloud_done_outlined,
                      title: 'Queue is empty',
                      message: 'Messages and SOS events you create are queued here for upload.',
                    ),
                  )
                : Column(children: [for (final i in list) _ItemTile(item: i)]),
          ),
        ],
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count(this.label, this.value);

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text('$value', style: Theme.of(context).textTheme.headlineMedium),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    ),
  );
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.item});

  final SyncItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (tone, label) = switch (item.status) {
      SyncStatus.pending => (PillTone.warning, 'Pending'),
      SyncStatus.inProgress => (PillTone.info, 'Uploading'),
      SyncStatus.synced => (PillTone.success, 'Uploaded'),
      SyncStatus.failed => (PillTone.danger, 'Failed'),
    };
    final kind = item.entityType == SyncEntityType.message
        ? 'Message'
        : 'SOS event';
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: EcoCard(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$kind · ${item.operation.name}',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                StatusPill(label: label, tone: tone),
              ],
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              'Queued ${Formatters.dateTime(item.createdAt)} · retries: ${item.retryCount}',
              style: theme.textTheme.bodySmall,
            ),
            if (item.lastError != null && item.status != SyncStatus.synced)
              Text(
                item.lastError!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

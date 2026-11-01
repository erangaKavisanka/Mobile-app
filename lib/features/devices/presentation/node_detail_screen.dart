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
import '../../../shared/widgets/status_pill.dart';
import '../domain/node.dart';
import 'device_logs_screen.dart';
import 'device_widgets.dart';

class NodeDetailScreen extends ConsumerWidget {
  const NodeDetailScreen({super.key, required this.nodeRowId});

  final String nodeRowId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final node = ref.watch(nodeProvider(nodeRowId));
    final logs = ref.watch(deviceLogsProvider(nodeRowId));

    return Scaffold(
      appBar: AppBar(title: const Text('Device details')),
      body: AsyncValueView<Node?>(
        value: node,
        data: (n) {
          if (n == null) {
            return const EmptyState(
              icon: Icons.search_off,
              title: 'Device not found',
              message: 'This device is no longer in the local registry.',
            );
          }
          final theme = Theme.of(context);
          return ListView(
            padding: const EdgeInsets.all(Spacing.lg),
            children: [
              Row(
                children: [
                  Icon(
                    nodeIcon(n.role),
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n.name, style: theme.textTheme.headlineSmall),
                        Text(
                          roleLabel(n.role),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  NodeStatusPill(status: n.status),
                ],
              ),
              if (n.isSimulated) ...[
                const SizedBox(height: Spacing.md),
                const SimulatedBadge(
                  label: 'SIMULATED DEVICE — values are not real readings',
                ),
              ],
              const SectionHeader('Identity'),
              EcoCard(
                child: Column(
                  children: [
                    InfoRow('Node ID', n.nodeId),
                    InfoRow('Role', roleLabel(n.role)),
                    InfoRow(
                      'Last seen',
                      n.lastSeenAt == null
                          ? 'Never'
                          : Formatters.dateTime(n.lastSeenAt!),
                    ),
                  ],
                ),
              ),
              const SectionHeader('Readings'),
              EcoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Battery', style: theme.textTheme.labelMedium),
                    const SizedBox(height: Spacing.sm),
                    if (n.batteryPercent == null)
                      Text('Not reported', style: theme.textTheme.bodyMedium)
                    else
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(Radii.pill),
                              child: LinearProgressIndicator(
                                value: n.batteryPercent! / 100,
                                minHeight: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: Spacing.md),
                          Text(
                            '${n.batteryPercent}%',
                            style: theme.textTheme.titleSmall,
                          ),
                        ],
                      ),
                    const SizedBox(height: Spacing.lg),
                    InfoRow(
                      'Signal (RSSI)',
                      n.rssi == null ? 'Not reported' : '${n.rssi} dBm',
                    ),
                  ],
                ),
              ),
              if (!n.isGateway) ...[
                const SizedBox(height: Spacing.lg),
                OutlinedButton.icon(
                  onPressed: () async {
                    final conv = await ref
                        .read(messageRepositoryProvider)
                        .getOrCreateConversation(n.nodeId, title: n.name);
                    if (context.mounted) {
                      context.push(AppRoutes.conversation(conv.id));
                    }
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Message this node'),
                ),
              ],
              const SectionHeader('Activity'),
              AsyncValueView<List<DeviceLog>>(
                value: logs,
                data: (list) => list.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(Spacing.lg),
                        child: Text('No activity recorded for this device.'),
                      )
                    : LogList(logs: list.take(20).toList(), shrink: true),
              ),
            ],
          );
        },
      ),
    );
  }
}

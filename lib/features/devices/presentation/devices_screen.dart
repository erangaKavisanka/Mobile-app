import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/eco_card.dart';
import '../../../shared/widgets/common.dart';
import '../../../shared/widgets/state_views.dart';
import '../../../shared/widgets/status_pill.dart';
import '../domain/device_transport.dart';
import '../domain/node.dart';
import 'device_widgets.dart';

class DevicesScreen extends ConsumerWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nodes = ref.watch(nodesProvider);
    final state =
        ref.watch(connectionStateProvider).value ??
        TransportConnectionState.disconnected;
    final transport = ref.watch(deviceTransportProvider);
    final controls = ref.watch(simulationControlsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Devices'),
        actions: [
          IconButton(
            tooltip: 'Activity log',
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () => context.push(AppRoutes.deviceLogs),
          ),
        ],
      ),
      body: AsyncValueView<List<Node>>(
        value: nodes,
        data: (list) {
          final gateway = list.where((n) => n.isGateway).firstOrNull;
          final others = list.where((n) => !n.isGateway).toList();
          return ListView(
            padding: const EdgeInsets.all(Spacing.lg),
            children: [
              _GatewayCard(
                gateway: gateway,
                state: state,
                simulated: transport.isSimulated,
              ),
              if (controls != null &&
                  state == TransportConnectionState.connected) ...[
                const SizedBox(height: Spacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => transport.getStatus(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Request status'),
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: controls.simulateIncomingSos,
                        icon: const Icon(Icons.science_outlined),
                        label: const Text('Simulate SOS'),
                      ),
                    ),
                  ],
                ),
              ],
              SectionHeader('Nodes (${others.length})'),
              if (others.isEmpty)
                const SizedBox(
                  height: 260,
                  child: EmptyState(
                    icon: Icons.cell_tower,
                    title: 'No nodes discovered',
                    message: 'Connect to the gateway to discover nearby EcoLink nodes. Nothing is shown until a device reports in.',
                  ),
                )
              else
                for (final n in others)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.md),
                    child: _NodeTile(node: n),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _GatewayCard extends ConsumerWidget {
  const _GatewayCard({
    required this.gateway,
    required this.state,
    required this.simulated,
  });

  final Node? gateway;
  final TransportConnectionState state;
  final bool simulated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final connected = state == TransportConnectionState.connected;
    final connecting = state == TransportConnectionState.connecting;
    return EcoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(Spacing.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(Radii.sm),
                ),
                child: Icon(Icons.router, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gateway?.name ?? 'EcoLink gateway',
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      gateway?.nodeId ?? 'ESP32-C3 via USB-OTG (not connected)',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (simulated) const SimulatedBadge(),
            ],
          ),
          const SizedBox(height: Spacing.md),
          ConnectionPill(state: state),
          if (gateway?.lastSeenAt != null)
            Padding(
              padding: const EdgeInsets.only(top: Spacing.sm),
              child: Text(
                'Last seen ${Formatters.relative(gateway!.lastSeenAt!)}',
                style: theme.textTheme.bodySmall,
              ),
            ),
          const SizedBox(height: Spacing.md),
          SizedBox(
            width: double.infinity,
            child: connected || connecting
                ? OutlinedButton.icon(
                    onPressed: () => toggleGateway(context, ref),
                    icon: const Icon(Icons.link_off),
                    label: Text(connecting ? 'Cancel' : 'Disconnect'),
                  )
                : FilledButton.icon(
                    onPressed: () => toggleGateway(context, ref),
                    icon: const Icon(Icons.usb),
                    label: Text(
                      simulated
                          ? 'Connect simulated gateway'
                          : 'Connect gateway',
                    ),
                  ),
          ),
          if (simulated)
            Padding(
              padding: const EdgeInsets.only(top: Spacing.sm),
              child: Text(
                'No hardware is attached. This gateway and its nodes are generated by the in-app simulator.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NodeTile extends StatelessWidget {
  const _NodeTile({required this.node});

  final Node node;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return EcoCard(
      onTap: () => context.push(AppRoutes.node(node.id)),
      child: Row(
        children: [
          Icon(nodeIcon(node.role), color: theme.colorScheme.primary),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(node.name, style: theme.textTheme.titleSmall),
                Text(node.nodeId, style: theme.textTheme.bodySmall),
                const SizedBox(height: Spacing.xs),
                NodeReadings(node: node),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              NodeStatusPill(status: node.status),
              if (node.isSimulated) ...[
                const SizedBox(height: Spacing.xs),
                const SimulatedBadge(),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

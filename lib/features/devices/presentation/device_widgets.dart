import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/errors/app_exception.dart';
import '../../../shared/widgets/common.dart';
import '../../../shared/widgets/status_pill.dart';
import '../domain/device_transport.dart';
import '../domain/node.dart';

class ConnectionPill extends StatelessWidget {
  const ConnectionPill({super.key, required this.state});

  final TransportConnectionState state;

  @override
  Widget build(BuildContext context) {
    final (label, tone, icon) = switch (state) {
      TransportConnectionState.connected => (
        'Gateway connected',
        PillTone.success,
        Icons.link,
      ),
      TransportConnectionState.connecting => (
        'Connecting…',
        PillTone.info,
        Icons.sync,
      ),
      TransportConnectionState.disconnected => (
        'Gateway offline',
        PillTone.neutral,
        Icons.link_off,
      ),
      TransportConnectionState.error => (
        'Connection error',
        PillTone.danger,
        Icons.error_outline,
      ),
    };
    return StatusPill(label: label, tone: tone, icon: icon);
  }
}

class NodeStatusPill extends StatelessWidget {
  const NodeStatusPill({super.key, required this.status});

  final NodeStatus status;

  @override
  Widget build(BuildContext context) => switch (status) {
    NodeStatus.online => const StatusPill(
      label: 'Online',
      tone: PillTone.success,
    ),
    NodeStatus.offline => const StatusPill(
      label: 'Offline',
      tone: PillTone.neutral,
    ),
    NodeStatus.unknown => const StatusPill(
      label: 'Unknown',
      tone: PillTone.warning,
    ),
  };
}

IconData nodeIcon(NodeRole role) => switch (role) {
  NodeRole.gateway => Icons.router,
  NodeRole.relay => Icons.cell_tower,
  NodeRole.traveller => Icons.hiking,
};

String roleLabel(NodeRole role) => switch (role) {
  NodeRole.gateway => 'Gateway',
  NodeRole.relay => 'Relay node',
  NodeRole.traveller => 'Traveller node',
};

/// Battery and signal readings. Missing values render as "—", never as zero.
class NodeReadings extends StatelessWidget {
  const NodeReadings({super.key, required this.node});

  final Node node;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.battery_std, size: 14, color: style?.color),
        const SizedBox(width: 2),
        Text(
          node.batteryPercent == null ? '—' : '${node.batteryPercent}%',
          style: style,
        ),
        const SizedBox(width: Spacing.md),
        Icon(Icons.network_cell, size: 14, color: style?.color),
        const SizedBox(width: 2),
        Text(node.rssi == null ? '—' : '${node.rssi} dBm', style: style),
      ],
    );
  }
}

/// Connect/disconnect handling shared by the dashboard and Devices tab.
Future<void> toggleGateway(BuildContext context, WidgetRef ref) async {
  final transport = ref.read(deviceTransportProvider);
  try {
    if (transport.currentState == TransportConnectionState.connected ||
        transport.currentState == TransportConnectionState.connecting) {
      await transport.disconnect();
    } else {
      await transport.connect();
    }
  } on TransportException catch (e) {
    if (context.mounted) showMessage(context, e.message);
  }
}

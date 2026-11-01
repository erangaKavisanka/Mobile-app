import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../app/shell_scaffold.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/common.dart';
import '../../../shared/widgets/eco_card.dart';
import '../../../shared/widgets/status_pill.dart';
import '../../devices/domain/device_transport.dart';
import '../../devices/domain/node.dart';
import '../../devices/presentation/device_widgets.dart';
import '../../location/domain/location_fix.dart';
import '../../location/presentation/location_controller.dart';
import '../../messaging/presentation/message_widgets.dart';
import '../../sos/presentation/sos_screen.dart';
import '../../synchronization/domain/sync_item.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).value;
    final connection =
        ref.watch(connectionStateProvider).value ??
        TransportConnectionState.disconnected;
    final transport = ref.watch(deviceTransportProvider);
    final nodes = ref.watch(nodesProvider).value ?? const <Node>[];
    final conversations = ref.watch(conversationsProvider).value ?? const [];
    final sos = ref.watch(sosEventsProvider).value ?? const [];
    final local = ref.watch(localNodeIdProvider);

    final active = sos.where((e) => e.isActive).toList();
    final others = nodes.where((n) => !n.isGateway).toList();
    final online = others.where((n) => n.status == NodeStatus.online).length;
    final gateway = nodes.where((n) => n.isGateway).firstOrNull;
    final simulated = transport.isSimulated;

    final rssiValues = others
        .where((n) => n.status == NodeStatus.online && n.rssi != null)
        .map((n) => n.rssi!);
    final bestRssi = rssiValues.isEmpty
        ? null
        : rssiValues.reduce((a, b) => a > b ? a : b);
    final batteries = others
        .where((n) => n.status == NodeStatus.online && n.batteryPercent != null)
        .map((n) => n.batteryPercent!);
    final lowBattery = batteries.isEmpty
        ? null
        : batteries.reduce((a, b) => a < b ? a : b);

    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoLink'),
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: context.openProfile,
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: context.openSettings,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Spacing.lg,
          Spacing.sm,
          Spacing.lg,
          Spacing.xxl,
        ),
        children: [
          _Welcome(
            name: profile?.displayName ?? 'Traveller',
            nodeId: local,
            connection: connection,
            simulated: simulated,
            onToggle: () => toggleGateway(context, ref),
          ),
          if (active.isNotEmpty) ...[
            const SectionHeader('Active SOS'),
            for (final e in active)
              Padding(
                padding: const EdgeInsets.only(bottom: Spacing.md),
                child: SosEventCard(event: e, isOwn: e.sourceNodeId == local),
              ),
          ],
          const SectionHeader('Network'),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: Spacing.md,
            crossAxisSpacing: Spacing.md,
            childAspectRatio: 1.45,
            children: [
              _StatTile(
                icon: Icons.router,
                label: 'Gateway',
                value: switch (connection) {
                  TransportConnectionState.connected => 'Connected',
                  TransportConnectionState.connecting => 'Connecting',
                  TransportConnectionState.error => 'Error',
                  TransportConnectionState.disconnected => 'Offline',
                },
                detail: gateway?.nodeId ?? 'No device',
                simulated: simulated && gateway != null,
              ),
              _StatTile(
                icon: Icons.cell_tower,
                label: 'Nodes online',
                value: '$online / ${others.length}',
                detail: others.isEmpty
                    ? 'None discovered'
                    : 'Discovered nearby',
                simulated: others.any((n) => n.isSimulated),
                onTap: () => context.go(AppRoutes.devices),
              ),
              _StatTile(
                icon: Icons.network_cell,
                label: 'Best signal',
                value: bestRssi == null ? '—' : '$bestRssi dBm',
                detail: 'Strongest online node',
                simulated: bestRssi != null && simulated,
              ),
              _StatTile(
                icon: Icons.battery_alert_outlined,
                label: 'Lowest battery',
                value: lowBattery == null ? '—' : '$lowBattery%',
                detail: 'Across online nodes',
                simulated: lowBattery != null && simulated,
              ),
            ],
          ),
          const SectionHeader('Quick actions'),
          Row(
            children: [
              Expanded(
                child: _QuickAction(
                  icon: Icons.chat_bubble_outline,
                  label: 'Message',
                  onTap: () => context.go(AppRoutes.messages),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: _QuickAction(
                  icon: Icons.sos,
                  label: 'SOS',
                  emergency: true,
                  onTap: () => context.go(AppRoutes.sos),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: _QuickAction(
                  icon: Icons.my_location,
                  label: 'Location',
                  onTap: () => context.go(AppRoutes.map),
                ),
              ),
            ],
          ),
          const SectionHeader('Location'),
          const _LocationSummary(),
          SectionHeader(
            'Recent messages',
            actionLabel: 'See all',
            onAction: () => context.go(AppRoutes.messages),
          ),
          if (conversations.isEmpty)
            const EcoCard(
              child: Text(
                'No messages yet. Conversations you start or receive appear here.',
              ),
            )
          else
            for (final c in conversations.take(3))
              Padding(
                padding: const EdgeInsets.only(bottom: Spacing.sm),
                child: EcoCard(
                  onTap: () => context.push(AppRoutes.conversation(c.id)),
                  child: Row(
                    children: [
                      PeerAvatar(c.title, radius: 18),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.title,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              c.lastMessage ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (c.unreadCount > 0)
                        Badge(label: Text('${c.unreadCount}')),
                    ],
                  ),
                ),
              ),
          const SectionHeader('Cloud synchronization'),
          const _SyncSummary(),
        ],
      ),
    );
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome({
    required this.name,
    required this.nodeId,
    required this.connection,
    required this.simulated,
    required this.onToggle,
  });

  final String name;
  final String nodeId;
  final TransportConnectionState connection;
  final bool simulated;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final connected = connection == TransportConnectionState.connected;
    final busy = connection == TransportConnectionState.connecting;
    return Container(
      padding: const EdgeInsets.all(Spacing.xl - 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Radii.lg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary,
            Color.lerp(scheme.primary, scheme.secondary, 0.55)!,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, $name',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: scheme.onPrimary,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            'Node $nodeId',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onPrimary.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: Spacing.lg),
          Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ConnectionPill(state: connection),
              if (simulated) const SimulatedBadge(),
            ],
          ),
          const SizedBox(height: Spacing.lg),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: scheme.onPrimary,
              foregroundColor: scheme.primary,
            ),
            onPressed: busy ? null : onToggle,
            icon: Icon(connected ? Icons.link_off : Icons.usb),
            label: Text(connected ? 'Disconnect gateway' : 'Connect gateway'),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
    this.simulated = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final String detail;
  final bool simulated;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return EcoCard(
      onTap: onTap,
      semanticLabel: '$label: $value',
      padding: const EdgeInsets.all(Spacing.md + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (simulated)
                Icon(
                  Icons.science_outlined,
                  size: 14,
                  color: context.status.simulated,
                ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: theme.textTheme.headlineSmall),
          ),
          Text(
            detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.emergency = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool emergency;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = emergency ? scheme.error : scheme.primary;
    return EcoCard(
      onTap: onTap,
      color: emergency ? scheme.error.withValues(alpha: 0.08) : null,
      borderColor: emergency ? scheme.error.withValues(alpha: 0.4) : null,
      padding: const EdgeInsets.symmetric(vertical: Spacing.lg),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: Spacing.sm),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _LocationSummary extends ConsumerWidget {
  const _LocationSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(locationControllerProvider);
    final latest = ref.watch(latestLocationProvider).value;
    final fix = state.fix ?? latest;
    final theme = Theme.of(context);

    final String title;
    final String detail;
    if (state.permission == LocationPermissionState.denied ||
        state.permission == LocationPermissionState.deniedForever) {
      title = 'Location permission needed';
      detail = 'Open the Map tab to grant access.';
    } else if (state.permission == LocationPermissionState.serviceDisabled) {
      title = 'GPS is turned off';
      detail = 'Turn on location services to get a fix.';
    } else if (fix == null) {
      title = state.isLoading ? 'Getting GPS fix…' : 'No location yet';
      detail = state.error ?? 'Open the Map tab to get your position.';
    } else {
      title = Formatters.coordinates(fix.latitude, fix.longitude);
      detail =
          '${Formatters.accuracy(fix.accuracy)} · ${Formatters.relative(fix.recordedAt)}';
    }

    return EcoCard(
      onTap: () => context.go(AppRoutes.map),
      child: Row(
        children: [
          Icon(
            fix == null ? Icons.location_off_outlined : Icons.place,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                Text(detail, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

class _SyncSummary extends ConsumerWidget {
  const _SyncSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(syncSummaryProvider).value ?? const SyncSummary();
    final theme = Theme.of(context);
    final PillTone tone;
    final String label;
    if (summary.failed > 0) {
      tone = PillTone.danger;
      label = '${summary.failed} failed';
    } else if (summary.pending > 0) {
      tone = PillTone.warning;
      label = '${summary.pending} waiting for Internet';
    } else {
      tone = summary.synced > 0 ? PillTone.success : PillTone.neutral;
      label = summary.synced > 0 ? 'All uploaded' : 'Nothing to upload';
    }
    return EcoCard(
      onTap: context.openSync,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cloud_sync_outlined),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Text(
                  'Opportunistic sync',
                  style: theme.textTheme.titleSmall,
                ),
              ),
              const SimulatedBadge(label: 'SIMULATED CLOUD'),
            ],
          ),
          const SizedBox(height: Spacing.md),
          StatusPill(label: label, tone: tone),
          const SizedBox(height: Spacing.sm),
          Text(
            summary.lastSyncedAt == null
                ? 'Never synchronized'
                : 'Last sync ${Formatters.relative(summary.lastSyncedAt!)}',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

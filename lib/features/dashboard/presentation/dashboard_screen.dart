import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/app.dart';
import '../../../core/constants/app_constants.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, this.onNavigate});

  final void Function(int index)? onNavigate;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EcoLinkState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            onPressed: () => state.log('Diagnostics refreshed'),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _HeroCard(state: state),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _MetricCard(
                  title: 'USB',
                  value: state.usbStatus,
                  icon: Icons.usb_rounded,
                  tint: Colors.blue,
                ),
                _MetricCard(
                  title: 'RF',
                  value: state.rfStatus,
                  icon: Icons.signal_cellular_4_bar_rounded,
                  tint: Colors.green,
                ),
                _MetricCard(
                  title: 'Internet',
                  value: state.internetAvailable ? 'Online' : 'Offline',
                  icon: Icons.wifi,
                  tint: Colors.orange,
                ),
                _MetricCard(
                  title: 'Cloud',
                  value: state.cloudStatus,
                  icon: Icons.cloud_done_rounded,
                  tint: Colors.indigo,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ActionRow(
              onNavigate: onNavigate,
              actions: [
                ('Messages', Icons.message_rounded, 1),
                ('Devices', Icons.devices_rounded, 3),
                ('SOS', Icons.warning_amber_rounded, 2),
                ('Settings', Icons.settings_rounded, 4),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MetricSummary(
                    title: 'Sent',
                    value: '${state.sentMessagesCount}',
                    accent: Colors.teal,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricSummary(
                    title: 'Received',
                    value: '${state.receivedMessagesCount}',
                    accent: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _MetricSummary(
              title: 'Pending sync',
              value: '${state.pendingQueueCount}',
              accent: Colors.amber,
            ),
            const SizedBox(height: 12),
            _MetricSummary(
              title: 'Last sync',
              value: state.lastSuccessfulSync == null
                  ? 'Unknown'
                  : state.lastSuccessfulSync!.toLocal().toString().substring(
                      0,
                      16,
                    ),
              accent: Colors.red,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await state.activateSos();
        },
        icon: const Icon(Icons.warning_amber_rounded),
        label: const Text('Activate SOS'),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.state});

  final EcoLinkState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, const Color(0xFF2D7A76)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.eco_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                AppConstants.appName,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Traveller safety and RF fallback communication',
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusChip(label: 'USB ${state.usbStatus}', color: Colors.white),
              _StatusChip(label: 'RF ${state.rfStatus}', color: Colors.white),
              _StatusChip(
                label: state.internetAvailable
                    ? 'Internet online'
                    : 'Internet offline',
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.tint,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: tint),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.actions, this.onNavigate});

  final List<(String, IconData, int)> actions;
  final void Function(int index)? onNavigate;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.4,
      children: actions
          .map(
            (action) => FilledButton.tonal(
              onPressed: () => onNavigate?.call(action.$3),
              child: Row(
                children: [
                  Icon(action.$2),
                  const SizedBox(width: 8),
                  Text(action.$1),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _MetricSummary extends StatelessWidget {
  const _MetricSummary({
    required this.title,
    required this.value,
    required this.accent,
  });

  final String title;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.labelMedium),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

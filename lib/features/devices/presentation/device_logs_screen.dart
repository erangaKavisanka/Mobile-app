import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/state_views.dart';
import '../domain/node.dart';

class DeviceLogsScreen extends ConsumerWidget {
  const DeviceLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(deviceLogsProvider(null));
    return Scaffold(
      appBar: AppBar(title: const Text('Device activity')),
      body: AsyncValueView<List<DeviceLog>>(
        value: logs,
        data: (list) => list.isEmpty
            ? const EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No activity yet',
                message: 'Connection events, acknowledgements and errors from the gateway are recorded here.',
              )
            : LogList(logs: list),
      ),
    );
  }
}

class LogList extends StatelessWidget {
  const LogList({super.key, required this.logs, this.shrink = false});

  final List<DeviceLog> logs;
  final bool shrink;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = context.status;
    return ListView.separated(
      shrinkWrap: shrink,
      physics: shrink ? const NeverScrollableScrollPhysics() : null,
      padding: shrink ? EdgeInsets.zero : const EdgeInsets.all(Spacing.lg),
      itemCount: logs.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (_, i) {
        final log = logs[i];
        final color = switch (log.level) {
          LogLevel.info => scheme.onSurfaceVariant,
          LogLevel.warning => c.warning,
          LogLevel.error => scheme.error,
        };
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            switch (log.level) {
              LogLevel.info => Icons.info_outline,
              LogLevel.warning => Icons.warning_amber,
              LogLevel.error => Icons.error_outline,
            },
            color: color,
            size: 20,
          ),
          title: Text(log.message),
          subtitle: Text(Formatters.dateTime(log.createdAt)),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/shell_scaffold.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/common.dart';
import '../../../shared/widgets/eco_card.dart';
import '../domain/app_preferences.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(preferencesProvider);
    final profile = ref.watch(profileProvider).value;
    final prefs = prefsAsync.value ?? const AppPreferences();

    Future<void> update(AppPreferences next) =>
        ref.read(settingsRepositoryProvider).save(next);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Spacing.lg,
          0,
          Spacing.lg,
          Spacing.xxl,
        ),
        children: [
          const SectionHeader('Profile'),
          EcoCard(
            onTap: context.openProfile,
            child: Row(
              children: [
                const Icon(Icons.account_circle_outlined, size: 32),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile?.displayName ?? 'Traveller',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(profile?.nodeId ?? ref.watch(localNodeIdProvider)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
          const SectionHeader('Appearance'),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.system,
                label: Text('System'),
                icon: Icon(Icons.brightness_auto),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                label: Text('Light'),
                icon: Icon(Icons.light_mode_outlined),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text('Dark'),
                icon: Icon(Icons.dark_mode_outlined),
              ),
            ],
            selected: {prefs.themeMode},
            onSelectionChanged: (s) =>
                update(prefs.copyWith(themeMode: s.first)),
          ),
          const SectionHeader('Notifications'),
          _Group(
            children: [
              SwitchListTile(
                title: const Text('In-app alerts'),
                subtitle: const Text(
                  'Show alerts while EcoLink is open. System push notifications are not implemented yet.',
                ),
                value: prefs.notificationsEnabled,
                onChanged: (v) =>
                    update(prefs.copyWith(notificationsEnabled: v)),
              ),
              SwitchListTile(
                title: const Text('SOS alerts'),
                value: prefs.notifyOnSos,
                onChanged: prefs.notificationsEnabled
                    ? (v) => update(prefs.copyWith(notifyOnSos: v))
                    : null,
              ),
              SwitchListTile(
                title: const Text('Message alerts'),
                value: prefs.notifyOnMessages,
                onChanged: prefs.notificationsEnabled
                    ? (v) => update(prefs.copyWith(notifyOnMessages: v))
                    : null,
              ),
            ],
          ),
          const SectionHeader('Device'),
          _Group(
            children: [
              SwitchListTile(
                title: const Text('Connect gateway on launch'),
                subtitle: const Text(
                  'Uses the simulated gateway until USB hardware support is added.',
                ),
                value: prefs.autoConnectDevice,
                onChanged: (v) => update(prefs.copyWith(autoConnectDevice: v)),
              ),
            ],
          ),
          const SectionHeader('Privacy'),
          _Group(
            children: [
              SwitchListTile(
                title: const Text('Keep location history'),
                subtitle: const Text(
                  'Save GPS fixes on this phone so they can be drawn on the map.',
                ),
                value: prefs.saveLocationHistory,
                onChanged: (v) =>
                    update(prefs.copyWith(saveLocationHistory: v)),
              ),
              SwitchListTile(
                title: const Text('Attach location to SOS'),
                subtitle: const Text(
                  'Include coordinates in emergency alerts.',
                ),
                value: prefs.attachLocationToSos,
                onChanged: (v) =>
                    update(prefs.copyWith(attachLocationToSos: v)),
              ),
              ListTile(
                title: const Text('Delete location history'),
                trailing: const Icon(Icons.delete_outline),
                onTap: () async {
                  final ok = await confirmAction(
                    context,
                    title: 'Delete location history?',
                    message: 'All saved GPS points will be removed from this phone. Locations already attached to messages or SOS events are kept.',
                    confirmLabel: 'Delete',
                    destructive: true,
                  );
                  if (ok) {
                    await ref.read(locationRepositoryProvider).clearHistory();
                    if (context.mounted) {
                      showMessage(context, 'Location history deleted.');
                    }
                  }
                },
              ),
            ],
          ),
          const SectionHeader('Synchronization'),
          _Group(
            children: [
              ListTile(
                title: const Text('Sync queue'),
                subtitle: const Text(
                  'Simulated cloud — see pending and failed uploads',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: context.openSync,
              ),
            ],
          ),
          const SectionHeader('About'),
          const EcoCard(
            child: Column(
              children: [
                InfoRow(
                  'Application',
                  '${AppConstants.appName} ${AppConstants.appVersion}',
                ),
                InfoRow('Protocol', 'v${AppConstants.protocolVersion}'),
                InfoRow('Network', AppConstants.networkName),
                InfoRow('Hardware', 'Not integrated — simulated gateway'),
                InfoRow('Cloud', 'Not integrated — simulated sync'),
              ],
            ),
          ),
          const SectionHeader('Data'),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              final ok = await confirmAction(
                context,
                title: 'Clear all local data?',
                message:
                    'This permanently deletes every message, SOS event, location point, device record and sync item stored on this phone. '
                    'Your profile name and node ID are kept. This cannot be undone.',
                confirmLabel: 'Delete everything',
                destructive: true,
              );
              if (!ok) return;
              await ref.read(localDataManagerProvider).clearAll();
              if (context.mounted) {
                showMessage(context, 'All local data cleared.');
              }
            },
            icon: const Icon(Icons.delete_forever_outlined),
            label: const Text('Clear all local data'),
          ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.md),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

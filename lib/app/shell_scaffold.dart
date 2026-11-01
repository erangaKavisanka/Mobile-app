import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/messaging/domain/message.dart';
import '../features/sos/domain/sos_event.dart';
import '../shared/widgets/common.dart';
import 'providers.dart';
import 'router.dart';

/// Bottom navigation frame around the five main sections.
class ShellScaffold extends ConsumerWidget {
  const ShellScaffold({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In-app alert when another node broadcasts an SOS, if the user wants it.
    ref.listen<AsyncValue<List<SosEvent>>>(sosEventsProvider, (prev, next) {
      final prefs = ref.read(preferencesProvider).value;
      if (prefs != null && !(prefs.notificationsEnabled && prefs.notifyOnSos)) {
        return;
      }
      final known = prev?.value?.map((e) => e.id).toSet();
      if (known == null) return;
      final local = ref.read(localNodeIdProvider);
      for (final e in next.value ?? const <SosEvent>[]) {
        if (!known.contains(e.id) && e.sourceNodeId != local) {
          showMessage(context, 'SOS received from ${e.sourceNodeId}');
        }
      }
    });

    // In-app alert when new unread messages arrive.
    ref.listen<AsyncValue<List<Conversation>>>(conversationsProvider, (
      prev,
      next,
    ) {
      final prefs = ref.read(preferencesProvider).value;
      if (prefs != null &&
          !(prefs.notificationsEnabled && prefs.notifyOnMessages)) {
        return;
      }
      final before = prev?.value;
      if (before == null) return;
      final unreadBefore = {for (final c in before) c.id: c.unreadCount};
      for (final c in next.value ?? const <Conversation>[]) {
        if (c.unreadCount > (unreadBefore[c.id] ?? 0)) {
          showMessage(context, 'New message from ${c.title}');
          break;
        }
      }
    });

    final activeSos =
        ref.watch(sosEventsProvider).value?.where((e) => e.isActive).length ??
        0;

    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: activeSos > 0,
              label: Text('$activeSos'),
              child: const Icon(Icons.sos_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: activeSos > 0,
              label: Text('$activeSos'),
              child: const Icon(Icons.sos),
            ),
            label: 'SOS',
          ),
          const NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Map',
          ),
          const NavigationDestination(
            icon: Icon(Icons.router_outlined),
            selectedIcon: Icon(Icons.router),
            label: 'Devices',
          ),
        ],
      ),
    );
  }
}

/// Convenience for pushing the root-level screens from anywhere.
extension AppNavigation on BuildContext {
  void openSettings() => push(AppRoutes.settings);
  void openProfile() => push(AppRoutes.profile);
  void openSync() => push(AppRoutes.sync);
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/devices/presentation/device_logs_screen.dart';
import '../features/devices/presentation/devices_screen.dart';
import '../features/devices/presentation/node_detail_screen.dart';
import '../features/location/presentation/map_screen.dart';
import '../features/messaging/presentation/conversation_screen.dart';
import '../features/messaging/presentation/messages_screen.dart';
import '../features/settings/presentation/profile_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/sos/presentation/sos_detail_screen.dart';
import '../features/sos/presentation/sos_screen.dart';
import '../features/synchronization/presentation/sync_screen.dart';
import 'shell_scaffold.dart';

class AppRoutes {
  AppRoutes._();

  static const home = '/home';
  static const messages = '/messages';
  static const sos = '/sos';
  static const map = '/map';
  static const devices = '/devices';
  static const deviceLogs = '/devices/logs';
  static const settings = '/settings';
  static const profile = '/profile';
  static const sync = '/sync';

  static String conversation(String id) => '/messages/$id';
  static String sosEvent(String id) => '/sos/$id';
  static String node(String id) => '/devices/$id';
}

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => ShellScaffold(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (_, _) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.messages,
                builder: (_, _) => const MessagesScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (_, s) => ConversationScreen(
                      conversationId: s.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.sos,
                builder: (_, _) => const SosScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (_, s) =>
                        SosDetailScreen(eventId: s.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.map,
                builder: (_, s) {
                  final lat = double.tryParse(
                    s.uri.queryParameters['lat'] ?? '',
                  );
                  final lon = double.tryParse(
                    s.uri.queryParameters['lon'] ?? '',
                  );
                  return MapScreen(
                    focus: lat == null || lon == null ? null : LatLng(lat, lon),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.devices,
                builder: (_, _) => const DevicesScreen(),
                routes: [
                  GoRoute(
                    path: 'logs',
                    builder: (_, _) => const DeviceLogsScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (_, s) =>
                        NodeDetailScreen(nodeRowId: s.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.settings,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.sync,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const SyncScreen(),
      ),
    ],
  );
});

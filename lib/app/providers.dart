import 'dart:async';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/protocol/protocol_factory.dart';
import '../data/database/app_database.dart';
import '../data/repositories/location_repository_impl.dart';
import '../data/repositories/message_repository_impl.dart';
import '../data/repositories/node_repository_impl.dart';
import '../data/repositories/settings_repository_impl.dart';
import '../data/repositories/sos_repository_impl.dart';
import '../data/repositories/sync_repository_impl.dart';
import '../data/services/geolocator_location_source.dart';
import '../data/services/gateway_coordinator.dart';
import '../data/services/messaging_service.dart';
import '../data/services/simulated_device_transport.dart';
import '../data/services/sos_service.dart';
import '../data/services/sync_service.dart';
import '../features/devices/domain/device_transport.dart';
import '../features/devices/domain/node.dart';
import '../features/devices/domain/node_repository.dart';
import '../features/location/domain/location_fix.dart';
import '../features/location/domain/location_repository.dart';
import '../features/messaging/domain/message.dart';
import '../features/messaging/domain/message_repository.dart';
import '../features/settings/domain/app_preferences.dart';
import '../features/settings/domain/settings_repository.dart';
import '../features/sos/domain/sos_event.dart';
import '../features/sos/domain/sos_repository.dart';
import '../features/synchronization/domain/sync_item.dart';
import '../features/synchronization/domain/sync_repository.dart';

// --- Roots supplied by main() / tests ---------------------------------------

final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('databaseProvider must be overridden'),
);

/// Node identity of this phone, resolved before the UI starts.
final localNodeIdProvider = Provider<String>(
  (ref) => throw UnimplementedError('localNodeIdProvider must be overridden'),
);

// --- Repositories -----------------------------------------------------------

final messageRepositoryProvider = Provider<MessageRepository>(
  (ref) => MessageRepositoryImpl(ref.watch(databaseProvider)),
);
final sosRepositoryProvider = Provider<SosRepository>(
  (ref) => SosRepositoryImpl(ref.watch(databaseProvider)),
);
final nodeRepositoryProvider = Provider<NodeRepository>(
  (ref) => NodeRepositoryImpl(ref.watch(databaseProvider)),
);
final locationRepositoryProvider = Provider<LocationRepository>(
  (ref) => LocationRepositoryImpl(ref.watch(databaseProvider)),
);
final syncRepositoryProvider = Provider<SyncRepository>(
  (ref) => SyncRepositoryImpl(ref.watch(databaseProvider)),
);
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepositoryImpl(ref.watch(databaseProvider)),
);
final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepositoryImpl(ref.watch(databaseProvider)),
);
final localDataManagerProvider = Provider<LocalDataManager>(
  (ref) => LocalDataManagerImpl(ref.watch(databaseProvider)),
);
final locationSourceProvider = Provider<LocationSource>(
  (ref) => const GeolocatorLocationSource(),
);

/// Map tile source. Built-in caching keeps visited areas viewable offline.
/// Tests override this to avoid the platform cache directory.
final mapTileProviderProvider = Provider<TileProvider>(
  (ref) => NetworkTileProvider(),
);

// --- Device transport (swap this provider for the USB implementation later) --

final deviceTransportProvider = Provider<DeviceTransport>((ref) {
  final transport = SimulatedDeviceTransport(
    localNodeId: ref.watch(localNodeIdProvider),
    statusInterval: const Duration(seconds: 30),
  );
  ref.onDispose(transport.dispose);
  return transport;
});

/// Non-null only when the active transport is simulated.
final simulationControlsProvider = Provider<SimulationControls?>((ref) {
  final transport = ref.watch(deviceTransportProvider);
  return transport is SimulationControls
      ? transport as SimulationControls
      : null;
});

// --- Services ---------------------------------------------------------------

final protocolFactoryProvider = Provider<ProtocolFactory>(
  (ref) => ProtocolFactory(localNodeId: ref.watch(localNodeIdProvider)),
);

final messagingServiceProvider = Provider<MessagingService>(
  (ref) => MessagingService(
    messages: ref.watch(messageRepositoryProvider),
    nodes: ref.watch(nodeRepositoryProvider),
    transport: ref.watch(deviceTransportProvider),
    protocol: ref.watch(protocolFactoryProvider),
  ),
);

final sosServiceProvider = Provider<SosService>(
  (ref) => SosService(
    events: ref.watch(sosRepositoryProvider),
    transport: ref.watch(deviceTransportProvider),
    protocol: ref.watch(protocolFactoryProvider),
  ),
);

final gatewayCoordinatorProvider = Provider<GatewayCoordinator>((ref) {
  final coordinator = GatewayCoordinator(
    transport: ref.watch(deviceTransportProvider),
    messaging: ref.watch(messagingServiceProvider),
    sos: ref.watch(sosServiceProvider),
    nodes: ref.watch(nodeRepositoryProvider),
  );
  ref.onDispose(coordinator.dispose);
  return coordinator;
});

final syncServiceProvider = Provider<SyncService>(
  (ref) => SyncService(
    queue: ref.watch(syncRepositoryProvider),
    cloud: SimulatedCloudGateway(
      // Read lazily so toggling the preference takes effect immediately.
      isInternetAvailable: () =>
          ref.read(preferencesProvider).value?.simulateInternet ?? false,
    ),
  ),
);

// --- Reactive data ----------------------------------------------------------

final preferencesProvider = StreamProvider<AppPreferences>(
  (ref) => ref.watch(settingsRepositoryProvider).watchPreferences(),
);
final profileProvider = StreamProvider<UserProfile?>(
  (ref) => ref.watch(userRepositoryProvider).watchLocalUser(),
);

final connectionStateProvider = StreamProvider<TransportConnectionState>((
  ref,
) async* {
  final transport = ref.watch(deviceTransportProvider);
  yield transport.currentState;
  yield* transport.connectionState;
});

final conversationsProvider = StreamProvider<List<Conversation>>(
  (ref) => ref.watch(messageRepositoryProvider).watchConversations(),
);
final conversationProvider = StreamProvider.family<Conversation?, String>(
  (ref, id) => ref.watch(messageRepositoryProvider).watchConversation(id),
);
final messagesProvider = StreamProvider.family<List<Message>, String>(
  (ref, id) => ref.watch(messageRepositoryProvider).watchMessages(id),
);

final sosEventsProvider = StreamProvider<List<SosEvent>>(
  (ref) => ref.watch(sosRepositoryProvider).watchAll(),
);
final sosEventProvider = StreamProvider.family<SosEvent?, String>(
  (ref, id) => ref.watch(sosRepositoryProvider).watch(id),
);

final nodesProvider = StreamProvider<List<Node>>(
  (ref) => ref.watch(nodeRepositoryProvider).watchNodes(),
);
final nodeProvider = StreamProvider.family<Node?, String>(
  (ref, id) => ref.watch(nodeRepositoryProvider).watchNode(id),
);
final deviceLogsProvider = StreamProvider.family<List<DeviceLog>, String?>(
  (ref, nodeRowId) =>
      ref.watch(nodeRepositoryProvider).watchLogs(nodeId: nodeRowId),
);

final latestLocationProvider = StreamProvider<LocationFix?>(
  (ref) => ref.watch(locationRepositoryProvider).watchLatest(),
);
final locationHistoryProvider = StreamProvider<List<LocationFix>>(
  (ref) => ref.watch(locationRepositoryProvider).watchHistory(),
);

final syncSummaryProvider = StreamProvider<SyncSummary>(
  (ref) => ref.watch(syncRepositoryProvider).watchSummary(),
);
final syncItemsProvider = StreamProvider<List<SyncItem>>(
  (ref) => ref.watch(syncRepositoryProvider).watchItems(),
);

// --- Startup ----------------------------------------------------------------

/// Starts background behaviour once: queue recovery, packet handling,
/// auto-connect, and opportunistic simulated sync.
final appBootstrapProvider = FutureProvider<void>((ref) async {
  final sync = ref.watch(syncServiceProvider);
  final coordinator = ref.watch(gatewayCoordinatorProvider);
  final transport = ref.watch(deviceTransportProvider);
  final settings = ref.watch(settingsRepositoryProvider);
  final nodes = ref.watch(nodeRepositoryProvider);

  await sync.recoverInterrupted();
  await coordinator.start();

  // Opportunistic sync: run when (simulated) Internet appears or new items queue.
  ref.listen<AsyncValue<AppPreferences>>(preferencesProvider, (prev, next) {
    final was = prev?.value?.simulateInternet ?? false;
    if (next.value?.simulateInternet == true && !was) unawaited(sync.syncNow());
  });
  ref.listen<AsyncValue<SyncSummary>>(syncSummaryProvider, (prev, next) {
    final before = prev?.value?.pending ?? 0;
    final now = next.value?.pending ?? 0;
    final online =
        ref.read(preferencesProvider).value?.simulateInternet ?? false;
    if (online && now > before) unawaited(sync.syncNow());
  });

  final prefs = await settings.load();
  if (prefs.autoConnectDevice) {
    unawaited(
      transport.connect().catchError(
        (Object e) =>
            nodes.log('Auto-connect failed: $e', level: LogLevel.error),
      ),
    );
  }
});

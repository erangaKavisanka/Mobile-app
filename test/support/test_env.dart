import 'dart:async';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:ecolink/core/protocol/protocol_factory.dart';
import 'package:ecolink/data/database/app_database.dart';
import 'package:ecolink/data/repositories/location_repository_impl.dart';
import 'package:ecolink/data/repositories/message_repository_impl.dart';
import 'package:ecolink/data/repositories/node_repository_impl.dart';
import 'package:ecolink/data/repositories/settings_repository_impl.dart';
import 'package:ecolink/data/repositories/sos_repository_impl.dart';
import 'package:ecolink/data/repositories/sync_repository_impl.dart';
import 'package:ecolink/data/services/gateway_coordinator.dart';
import 'package:ecolink/data/services/messaging_service.dart';
import 'package:ecolink/data/services/simulated_device_transport.dart';
import 'package:ecolink/data/services/sos_service.dart';

/// Tests open several databases (e.g. before and after a simulated restart).
void allowMultipleDatabases() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
}

AppDatabase memoryDatabase() {
  allowMultipleDatabases();
  return AppDatabase(NativeDatabase.memory());
}

/// Wires the real repositories and services around an in-memory database and
/// a fast simulated transport.
class TestEnv {
  TestEnv({double failureRate = 0}) : this._(memoryDatabase(), failureRate);

  /// Builds the stack around an existing database.
  TestEnv.forDatabase(AppDatabase db) : this._(db, 0);

  TestEnv._(this.db, double failureRate) : localNodeId = 'ECO-TEST01' {
    transport = SimulatedDeviceTransport(
      localNodeId: localNodeId,
      connectDelay: Duration.zero,
      ackDelay: const Duration(milliseconds: 5),
      propagationDelay: const Duration(milliseconds: 10),
      failureRate: failureRate,
    );
    messages = MessageRepositoryImpl(db);
    nodes = NodeRepositoryImpl(db);
    sosRepo = SosRepositoryImpl(db);
    sync = SyncRepositoryImpl(db);
    location = LocationRepositoryImpl(db);
    settings = SettingsRepositoryImpl(db);
    users = UserRepositoryImpl(db);
    final protocol = ProtocolFactory(localNodeId: localNodeId);
    messaging = MessagingService(
      messages: messages,
      nodes: nodes,
      transport: transport,
      protocol: protocol,
    );
    sos = SosService(events: sosRepo, transport: transport, protocol: protocol);
    coordinator = GatewayCoordinator(
      transport: transport,
      messaging: messaging,
      sos: sos,
      nodes: nodes,
    );
  }

  final AppDatabase db;
  final String localNodeId;
  late final SimulatedDeviceTransport transport;
  late final MessageRepositoryImpl messages;
  late final NodeRepositoryImpl nodes;
  late final SosRepositoryImpl sosRepo;
  late final SyncRepositoryImpl sync;
  late final LocationRepositoryImpl location;
  late final SettingsRepositoryImpl settings;
  late final UserRepositoryImpl users;
  late final MessagingService messaging;
  late final SosService sos;
  late final GatewayCoordinator coordinator;

  /// Polls [check] until true or timeout; avoids fixed sleeps.
  Future<void> until(Future<bool> Function() check) async {
    for (var i = 0; i < 200; i++) {
      await coordinator.idle;
      if (await check()) return;
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    throw TimeoutException('Condition not met');
  }

  Future<void> dispose() async {
    await coordinator.dispose();
    await transport.dispose();
    await db.close();
  }
}

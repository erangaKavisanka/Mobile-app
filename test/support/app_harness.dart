import 'package:ecolink/app/app.dart';
import 'package:ecolink/app/providers.dart';
import 'package:ecolink/data/database/app_database.dart';
import 'package:ecolink/data/services/simulated_device_transport.dart';
import 'package:ecolink/features/devices/domain/device_transport.dart';
import 'package:ecolink/features/settings/domain/app_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';
import 'test_env.dart';

/// Boots the real app against an in-memory database. All asynchronous setup
/// runs inside `runAsync` because sqlite I/O does not complete under FakeAsync.
class AppHarness {
  AppHarness._(this.tester, this.db, this.container, this.location);

  final WidgetTester tester;
  final AppDatabase db;
  final ProviderContainer container;
  final FakeLocationSource location;

  static const nodeId = 'ECO-TEST01';

  static Future<AppHarness> launch(
    WidgetTester tester, {
    AppPreferences? preferences,
    FakeLocationSource? location,
  }) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = memoryDatabase();
    final loc = location ?? FakeLocationSource();
    late ProviderContainer container;
    await tester.runAsync(() async {
      final env = TestEnv.forDatabase(db);
      await env.users.ensureLocalUser();
      await env.settings.save(
        preferences ?? const AppPreferences(autoConnectDevice: false),
      );
    });

    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        localNodeIdProvider.overrideWithValue(nodeId),
        locationSourceProvider.overrideWithValue(loc),
        mapTileProviderProvider.overrideWithValue(
          NetworkTileProvider(
            cachingProvider: const DisabledMapCachingProvider(),
          ),
        ),
        deviceTransportProvider.overrideWith((ref) {
          final t = SimulatedDeviceTransport(
            localNodeId: nodeId,
            connectDelay: Duration.zero,
            ackDelay: const Duration(milliseconds: 20),
            propagationDelay: const Duration(milliseconds: 40),
          );
          ref.onDispose(t.dispose);
          return t;
        }),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const EcoLinkApp(),
      ),
    );
    final harness = AppHarness._(tester, db, container, loc);
    await harness.settle();
    addTearDown(harness.dispose);
    return harness;
  }

  /// Pumps frames so database streams, timers and rebuilds can run.
  Future<void> settle() => advance(const Duration(milliseconds: 500));

  /// Advances fake time in small steps, letting simulated device timers fire.
  Future<void> advance(Duration total) async {
    const step = Duration(milliseconds: 25);
    for (var t = Duration.zero; t < total; t += step) {
      await tester.pump(step);
    }
  }

  /// Runs database/service work in the same fake-async zone as the widgets.
  /// (`runAsync` would deadlock against live drift streams.)
  Future<T> run<T>(Future<T> Function() action) async {
    var done = false;
    T? result;
    Object? error;
    StackTrace? stack;
    action().then(
      (v) {
        result = v;
        done = true;
      },
      onError: (Object e, StackTrace s) {
        error = e;
        stack = s;
        done = true;
      },
    );
    for (var i = 0; i < 200 && !done; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
    if (!done) throw StateError('Timed out waiting for async work');
    if (error != null) Error.throwWithStackTrace(error!, stack!);
    return result as T;
  }

  Future<void> tapText(String text) async {
    await tester.tap(find.text(text).first);
    await settle();
  }

  /// Taps a button inside the open dialog (card buttons may share the label).
  Future<void> tapDialog(String text) async {
    await tester.tap(
      find.descendant(of: find.byType(AlertDialog), matching: find.text(text)),
    );
    await settle();
  }

  Future<void> tapTab(String label) async {
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(label),
      ),
    );
    await settle();
  }

  Future<void> dispose() async {
    // Unmount first so providers cancel their drift streams, then close.
    await tester.pumpWidget(const SizedBox());
    container.dispose();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await db.close();
    });
  }

  ConnectionLink get link =>
      ConnectionLink(container.read(deviceTransportProvider));
}

class ConnectionLink {
  ConnectionLink(this.transport);
  final DeviceTransport transport;
}

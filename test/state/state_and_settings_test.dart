import 'package:ecolink/app/providers.dart';
import 'package:ecolink/features/location/domain/location_fix.dart';
import 'package:ecolink/features/location/presentation/location_controller.dart';
import 'package:ecolink/features/messaging/domain/message.dart';
import 'package:ecolink/features/settings/domain/app_preferences.dart';
import 'package:ecolink/features/sos/domain/sos_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';
import '../support/test_env.dart';

LocationFix fixAt(DateTime t) =>
    LocationFix(latitude: 6.9, longitude: 79.8, accuracy: 5, recordedAt: t);

void main() {
  group('domain models', () {
    test('message status pending flags', () {
      expect(MessageStatus.local.isPending, isTrue);
      expect(MessageStatus.queued.isPending, isTrue);
      expect(MessageStatus.sentToGateway.isPending, isTrue);
      expect(MessageStatus.delivered.isPending, isFalse);
      expect(MessageStatus.failed.isPending, isFalse);
    });

    test('SOS status active flags', () {
      for (final s in SosStatus.values) {
        expect(s.isActive, s != SosStatus.resolved && s != SosStatus.cancelled);
      }
    });

    test('preferences copyWith changes only the given fields', () {
      const base = AppPreferences();
      final next = base.copyWith(
        themeMode: ThemeMode.dark,
        simulateInternet: true,
      );
      expect(next.themeMode, ThemeMode.dark);
      expect(next.simulateInternet, isTrue);
      expect(next.saveLocationHistory, base.saveLocationHistory);
    });
  });

  group('settings and profile repositories', () {
    late TestEnv env;
    setUp(() => env = TestEnv());
    tearDown(() => env.dispose());

    test('preferences default, persist, and stream updates', () async {
      expect((await env.settings.load()).themeMode, ThemeMode.system);
      final updated = const AppPreferences().copyWith(
        themeMode: ThemeMode.dark,
        notifyOnSos: false,
        saveLocationHistory: false,
        simulateInternet: true,
      );
      await env.settings.save(updated);
      final loaded = await env.settings.load();
      expect(loaded.themeMode, ThemeMode.dark);
      expect(loaded.notifyOnSos, isFalse);
      expect(loaded.saveLocationHistory, isFalse);
      expect(loaded.simulateInternet, isTrue);
      expect(loaded.attachLocationToSos, isTrue); // untouched default
      expect(
        (await env.settings.watchPreferences().first).themeMode,
        ThemeMode.dark,
      );
    });

    test('local user is created once with a generated node id', () async {
      final a = await env.users.ensureLocalUser();
      final b = await env.users.ensureLocalUser();
      expect(a.id, b.id);
      expect(a.nodeId, startsWith('ECO-'));
      await env.users.updateDisplayName('  Nimali ');
      await env.users.updateDisplayName('   '); // ignored
      expect((await env.users.ensureLocalUser()).displayName, 'Nimali');
    });

    test('location history can be recorded and cleared', () async {
      await env.location.record(fixAt(DateTime.now()));
      expect(await env.location.watchHistory().first, hasLength(1));
      expect((await env.location.watchLatest().first)!.latitude, 6.9);
      await env.location.clearHistory();
      expect(await env.location.watchHistory().first, isEmpty);
      expect(await env.location.watchLatest().first, isNull);
    });
  });

  group('LocationController', () {
    late TestEnv env;
    late FakeLocationSource source;
    ProviderContainer makeContainer(
      FakeLocationSource src, {
      AppPreferences prefs = const AppPreferences(),
    }) {
      final c = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(env.db),
          localNodeIdProvider.overrideWithValue(env.localNodeId),
          locationSourceProvider.overrideWithValue(src),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    setUp(() {
      env = TestEnv();
      source = FakeLocationSource(fix: fixAt(DateTime.now()));
    });
    tearDown(() => env.dispose());

    test('refresh stores history when the privacy setting allows it', () async {
      final c = makeContainer(source);
      await env.settings.save(const AppPreferences());
      c.listen(preferencesProvider, (_, _) {});
      await c.read(preferencesProvider.future);

      final fix = await c.read(locationControllerProvider.notifier).refresh();
      expect(fix, isNotNull);
      expect(await env.location.watchHistory().first, hasLength(1));
    });

    test('refresh does not store history when disabled', () async {
      final c = makeContainer(source);
      await env.settings.save(const AppPreferences(saveLocationHistory: false));
      c.listen(preferencesProvider, (_, _) {});
      await c.read(preferencesProvider.future);

      await c.read(locationControllerProvider.notifier).refresh();
      expect(await env.location.watchHistory().first, isEmpty);
      expect(c.read(locationControllerProvider).fix, isNotNull);
    });

    test('denied permission yields an error state, not a crash', () async {
      source.permission = LocationPermissionState.denied;
      final c = makeContainer(source);
      final fix = await c.read(locationControllerProvider.notifier).refresh();
      expect(fix, isNull);
      expect(c.read(locationControllerProvider).error, isNotNull);
    });

    test('captureForSos respects the privacy setting and permission', () async {
      final c = makeContainer(source);
      await env.settings.save(const AppPreferences(attachLocationToSos: false));
      c.listen(preferencesProvider, (_, _) {});
      await c.read(preferencesProvider.future);
      expect(
        await c.read(locationControllerProvider.notifier).captureForSos(),
        isNull,
      );

      await env.settings.save(const AppPreferences());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      source.permission = LocationPermissionState.denied;
      expect(
        await c.read(locationControllerProvider.notifier).captureForSos(),
        isNull,
      );

      source.permission = LocationPermissionState.granted;
      expect(
        await c.read(locationControllerProvider.notifier).captureForSos(),
        isNotNull,
      );
    });

    test(
      'captureForSos falls back to a recent fix but not a stale one',
      () async {
        final c = makeContainer(source);
        final controller = c.read(locationControllerProvider.notifier);
        await controller.refresh(); // remember a fix
        source.fix = null; // GPS now unavailable
        expect(await controller.captureForSos(), isNotNull);
        expect(await controller.captureForSos(maxAge: Duration.zero), isNull);
      },
    );
  });
}

import 'package:ecolink/app/router.dart';
import 'package:ecolink/app/providers.dart';
import 'package:ecolink/features/location/domain/location_fix.dart';
import 'package:ecolink/features/messaging/domain/message.dart';
import 'package:ecolink/features/sos/domain/sos_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';
import '../support/fakes.dart';

void main() {
  testWidgets('dashboard starts empty and shows no invented data', (
    tester,
  ) async {
    await AppHarness.launch(tester);

    expect(find.text('Hello, Traveller'), findsOneWidget);
    expect(find.text('Node ECO-TEST01'), findsOneWidget);
    expect(find.text('Gateway offline'), findsOneWidget);
    expect(
      find.text('0 / 0'),
      findsOneWidget,
    ); // no nodes until a device reports
    expect(find.textContaining('No messages yet'), findsOneWidget);
    expect(find.text('Never synchronized'), findsOneWidget);
  });

  testWidgets('bottom navigation reaches all five sections', (tester) async {
    final app = await AppHarness.launch(tester);

    await app.tapTab('Messages');
    expect(find.text('No conversations yet'), findsOneWidget);
    await app.tapTab('SOS');
    expect(find.text('Emergency SOS'), findsOneWidget);
    await app.tapTab('Map');
    expect(find.text('Map'), findsWidgets);
    await app.tapTab('Devices');
    expect(find.text('No nodes discovered'), findsOneWidget);
    await app.tapTab('Home');
    expect(find.text('Hello, Traveller'), findsOneWidget);
  });

  testWidgets('connecting the simulated gateway discovers labelled nodes', (
    tester,
  ) async {
    final app = await AppHarness.launch(tester);

    await app.tapTab('Devices');
    expect(find.text('Connect simulated gateway'), findsOneWidget);
    await app.tapText('Connect simulated gateway');
    await app.settle();

    expect(find.text('Gateway connected'), findsOneWidget);
    expect(find.text('Simulated Relay B'), findsOneWidget);
    expect(find.text('Simulated Traveller C'), findsOneWidget);
    expect(find.text('SIMULATED'), findsWidgets);

    await app.tapText('Disconnect');
    expect(find.text('Gateway offline'), findsOneWidget);
  });

  testWidgets('SOS requires confirmation and persists the event', (
    tester,
  ) async {
    final fix = LocationFix(
      latitude: 6.9271,
      longitude: 79.8612,
      accuracy: 6,
      recordedAt: DateTime.now(),
    );
    final app = await AppHarness.launch(
      tester,
      location: FakeLocationSource(fix: fix),
    );

    await app.tapTab('SOS');
    await app.tapText('SOS');
    expect(find.text('Send SOS alert?'), findsOneWidget);

    // Backing out creates nothing.
    await app.tapDialog('Cancel');
    expect(
      await app.run(() => app.container.read(sosRepositoryProvider).active()),
      isEmpty,
    );

    await app.tapText('SOS');
    await tester.enterText(find.byType(TextField).last, 'Twisted ankle');
    await tester.tap(find.text('Send SOS'));
    await app.advance(const Duration(milliseconds: 100));
    await app.settle();

    final events = (await app.run(
      () => app.container.read(sosRepositoryProvider).active(),
    ));
    expect(events, hasLength(1));
    expect(
      events.single.status,
      SosStatus.triggered,
    ); // gateway offline: not "sent"
    expect(events.single.latitude, 6.9271);
    expect(events.single.note, 'Twisted ankle');
    expect(find.text('Saved — waiting for gateway'), findsWidgets);
    expect(find.text('Your SOS'), findsOneWidget);
  });

  testWidgets(
    'SOS without location permission is created without coordinates',
    (tester) async {
      final app = await AppHarness.launch(
        tester,
        location: FakeLocationSource(
          permission: LocationPermissionState.denied,
        ),
      );
      await app.tapTab('SOS');
      await app.tapText('SOS');
      await tester.tap(find.text('Send SOS'));
      await app.advance(const Duration(milliseconds: 100));
      await app.settle();

      final events = (await app.run(
        () => app.container.read(sosRepositoryProvider).active(),
      ));
      expect(events.single.hasLocation, isFalse);
    },
  );

  testWidgets('resolving an SOS asks for confirmation first', (tester) async {
    final app = await AppHarness.launch(tester);
    await app.run(() => app.container.read(sosServiceProvider).trigger());
    await app.tapTab('SOS');

    await app.tapText('Resolve');
    expect(find.text('Mark as resolved?'), findsOneWidget);
    await app.tapDialog('Cancel');
    expect(
      (await app.run(() => app.container.read(sosRepositoryProvider).active())),
      hasLength(1),
    );

    await app.tapText('Resolve');
    await app.tapDialog('Resolve');
    await app.settle();
    expect(
      (await app.run(() => app.container.read(sosRepositoryProvider).active())),
      isEmpty,
    );
    expect(find.text('Resolved'), findsWidgets);
  });

  testWidgets('a failed SOS is shown as failed with a retry action', (
    tester,
  ) async {
    final app = await AppHarness.launch(tester);
    final event = await app.run(
      () => app.container.read(sosServiceProvider).trigger(),
    );
    await app.run(
      () => app.container.read(sosServiceProvider).onTransmitFailed(event.id),
    );
    await app.tapTab('SOS');

    expect(find.text('Transmission failed'), findsWidgets);
    expect(find.text('Retry sending'), findsOneWidget);
    // The SOS stays active so it can still be resolved or cancelled.
    expect(find.text('Resolve'), findsOneWidget);
  });

  testWidgets('composing a message offline saves it as queued', (tester) async {
    final app = await AppHarness.launch(tester);
    await app.tapTab('Messages');

    await app.tapText('New message');
    await tester.enterText(
      find.widgetWithText(TextField, 'Or enter a node ID'),
      'eco-abc123',
    );
    await app.tapText('Start conversation');
    expect(find.text('ECO-ABC123'), findsWidgets);

    await tester.enterText(
      find.widgetWithText(TextField, 'Write a message'),
      'Reached the camp',
    );
    await tester.tap(find.byTooltip('Send message'));
    await app.settle();

    expect(find.text('Reached the camp'), findsOneWidget);
    expect(find.text('Queued — waiting for gateway'), findsOneWidget);
    expect(find.text('Delivered (acknowledged)'), findsNothing);

    final stored = (await app.run(
      () => app.container.read(messageRepositoryProvider).search('camp'),
    ));
    expect(stored.single.status, MessageStatus.queued);
  });

  testWidgets('message becomes delivered only after the simulated ACK', (
    tester,
  ) async {
    final app = await AppHarness.launch(tester);
    await app.tapTab('Devices');
    await app.tapText('Connect simulated gateway');
    await app.advance(const Duration(milliseconds: 100));
    await app.settle();

    final nodes = (await app.run(
      () => app.container
          .read(nodeRepositoryProvider)
          .findByNodeId('SIM-RELAY-B'),
    ));
    expect(nodes, isNotNull);
    final conv = (await app.run(
      () => app.container
          .read(messageRepositoryProvider)
          .getOrCreateConversation('SIM-RELAY-B'),
    ));
    await app.run(
      () => app.container
          .read(messagingServiceProvider)
          .send(peerNodeId: 'SIM-RELAY-B', body: 'ping'),
    );
    final sent = (await app.run(
      () => app.container.read(messageRepositoryProvider).search('ping'),
    )).single;
    expect(sent.status, MessageStatus.sentToGateway);

    await app.advance(const Duration(milliseconds: 150));
    final after = (await app.run(
      () => app.container.read(messageRepositoryProvider).getMessage(sent.id),
    ));
    expect(after!.status, MessageStatus.delivered);
    expect(conv.peerNodeId, 'SIM-RELAY-B');
  });

  testWidgets('map shows a permission prompt when location is denied', (
    tester,
  ) async {
    final app = await AppHarness.launch(
      tester,
      location: FakeLocationSource(permission: LocationPermissionState.denied),
    );
    await app.tapTab('Map');
    expect(find.text('Location permission needed'), findsOneWidget);
    await app.tapText('Allow access');
    expect(app.location.requests, 1);
  });

  testWidgets(
    'sync screen reports failures while offline and success when simulated online',
    (tester) async {
      final app = await AppHarness.launch(tester);
      await app.run(() => app.container.read(sosServiceProvider).trigger());
      await app.settle();

      app.container.read(routerProvider).go('/sync');
      await app.settle();
      expect(find.text('Synchronization'), findsOneWidget);
      await app.tapText('Sync now');
      await app.advance(const Duration(milliseconds: 400));
      await app.settle();
      expect(
        find.textContaining('No Internet connection (simulated)'),
        findsWidgets,
      );
      expect(find.text('Failed'), findsWidgets);

      await app.tapText('Retry failed');
      await app.advance(const Duration(milliseconds: 400));
      await app.settle();
      expect(find.text('Uploaded'), findsWidgets);
    },
  );

  testWidgets('clear local data requires confirmation', (tester) async {
    final app = await AppHarness.launch(tester);
    await app.run(() => app.container.read(sosServiceProvider).trigger());
    app.container.read(routerProvider).go('/settings');
    await app.settle();

    await tester.scrollUntilVisible(
      find.text('Clear all local data'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await app.tapText('Clear all local data');
    expect(find.text('Clear all local data?'), findsOneWidget);
    await app.tapDialog('Cancel');
    expect(
      (await app.run(() => app.container.read(sosRepositoryProvider).active())),
      hasLength(1),
    );

    await app.tapText('Clear all local data');
    await tester.tap(find.text('Delete everything'));
    await app.settle();
    expect(
      (await app.run(() => app.container.read(sosRepositoryProvider).active())),
      isEmpty,
    );
    expect(find.text('Settings'), findsOneWidget);
  });
}

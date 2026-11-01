# EcoLink

EcoLink is the Flutter mobile app for the final-year research project **"A Hybrid RF-Based Off-Grid Communication Network with Opportunistic Cloud Synchronization for Real-Time Traveller Safety and Emergency Response."**

It is an **offline-first** app: messages, SOS events, locations and the sync queue are stored in a local SQLite database and work with no Internet. The ESP32-C3 gateway, LoRa mesh and cloud are **not integrated yet**; they are replaced by clearly labelled simulations behind interfaces, so the real implementations can be dropped in later.

## What works today

| Area | Status |
|---|---|
| Dashboard, Messages, SOS, Map, Devices tabs; Settings, Profile, Sync screens | Implemented, backed by the local database |
| Messaging with lifecycle `local → queued → sentToGateway → delivered / failed` | Implemented. `delivered` is set **only** on an ACK packet |
| SOS with confirmation, GPS capture, UUID, lifecycle timeline, resolve/cancel | Implemented |
| Location permission handling, current position, history, map, share via message / SOS | Implemented (map tiles need Internet; coordinates do not) |
| Device registry, node details, battery/RSSI, activity log | Implemented from packets the transport reports |
| Sync queue with retry tracking and failure states | Implemented |
| Gateway link | **Simulated** (`SimulatedDeviceTransport`) |
| Cloud upload | **Simulated** (`SimulatedCloudGateway`, succeeds only while "Simulate Internet" is on) |
| USB serial / ESP32-C3, LoRa, AWS IoT, MySQL, Grafana | **Not implemented** |

Anything produced by the simulator is tagged `SIMULATED` in the UI. There is no seeded demo data: a fresh install shows empty states until the (simulated) gateway reports nodes.

## Setup

```bash
export PATH="$HOME/flutter/bin:$PATH"   # Flutter 3.47.x / Dart 3.13.x
cd Mobile-app
flutter pub get
dart run build_runner build             # regenerates lib/data/database/app_database.g.dart
flutter run                             # needs an Android device or emulator
```

Android builds need a JDK 17 and the Android SDK (platform 35+, NDK, CMake; Gradle installs the missing components on first build). For a quick look without a device, `flutter run -d chrome` also works: the `web/` folder is a development convenience that carries Drift's web assets (`sqlite3.wasm`, `drift_worker.js`). Android is the supported target.

The generated `*.g.dart` file is committed-friendly but can always be rebuilt with the build_runner command above; re-run it after editing `lib/data/database/tables.dart`.

## Quality checks

```bash
dart format .
flutter analyze
flutter test
```

## Architecture

Feature-based clean architecture with Riverpod for state and GoRouter for navigation.

```
lib/
  app/            app widget, router, shell (bottom nav), providers (wiring), theme
  core/           constants, errors, protocol (JSON packets), utils
  shared/widgets/ design-system widgets (cards, pills, empty/error/loading states, dialogs)
  data/
    database/     Drift schema (tables.dart) and AppDatabase
    repositories/ Drift implementations of the domain repository interfaces
    services/     MessagingService, SosService, SyncService, GatewayCoordinator,
                  SimulatedDeviceTransport, GeolocatorLocationSource
  features/<feature>/
    domain/       models + repository / transport interfaces (no Flutter or Drift imports except trivial types)
    presentation/ screens and widgets (no database access)
```

Data flow for an outgoing message:

1. `MessagingService.send` validates, writes the message (`local`) and a `sync_queue` row in **one transaction**, then marks it `queued`.
2. If the `DeviceTransport` is connected it sends the TEXT packet and marks `sentToGateway`; otherwise it stays `queued` and is flushed on connect.
3. `GatewayCoordinator` listens to `DeviceTransport.incomingEvents`. An ACK with stage `delivered` moves the message to `delivered`; an ERROR moves it to `failed` (with a Retry action).
4. Cloud sync (`SyncService`) is independent: it uploads `sync_queue` rows through a `CloudGateway` and never changes message delivery state.

Swapping in real hardware means implementing `DeviceTransport` (see `lib/features/devices/domain/device_transport.dart`) and overriding `deviceTransportProvider`; messaging, SOS and the UI do not change. See [docs/hardware-integration.md](docs/hardware-integration.md).

## Database

Drift/SQLite, schema version 1. Tables: `users`, `nodes`, `conversations`, `messages`, `sos_events`, `location_records`, `sync_queue`, `device_logs`, `app_settings`. Key points:

- UUID primary keys; a message id doubles as the protocol `message_id`, so duplicate packets cannot create duplicate rows.
- Foreign keys are enforced (`PRAGMA foreign_keys = ON`): messages → conversations (cascade), conversations → nodes, device_logs → nodes.
- `sync_queue` is unique on (entity type, entity id, operation).
- Timestamps are stored as ISO-8601 text (millisecond precision).
- Migrations: bump `schemaVersion` in `app_database.dart` and add an `if (from < N)` block in `_upgrade`.
- "Clear all local data" wipes every table but keeps the local user row so the phone's node ID stays stable.

## Privacy

- Location history can be switched off; attaching GPS to an SOS is a separate switch. Both default to on and can be changed in Settings → Privacy.
- Coordinates are shared only after an explicit confirmation (messages) or the SOS confirmation dialog.
- Nothing leaves the phone: the "cloud" is simulated.

## Known limitations

- On-device verification is minimal: the debug build was installed and launched on a Samsung Galaxy Tab S6 Lite (SM-P625) and the Flutter engine started. GPS accuracy, runtime permission dialogs, map tiles and tablet layout have **not** been systematically verified on the device. Behaviour is otherwise covered by unit, repository and widget tests; see [docs/testing.md](docs/testing.md).
- Nothing has been tested against real hardware or a real cloud: USB serial, ESP32-C3, LoRa RA-02, AWS IoT Core, Lambda, MySQL and Grafana are not integrated and everything involving them is simulated.
- Protocol v1 has no authentication or signing. The app validates packet structure, addressing, ACK references and sender roles, but a source ID is whatever the packet says it is. Gateway trust comes from a `HELLO` received on the gateway link, so the real USB transport must only deliver packets from the connected gateway.
- Map tiles use OpenStreetMap's public tile server, which is acceptable for development and a research prototype but not for wide distribution ([tile usage policy](https://operations.osmfoundation.org/policies/tiles)); switch to a licensed or self-hosted tile source before releasing. Tiles require Internet (visited tiles are cached by flutter_map). Without tiles the map is blank but markers and coordinates still work.
- Notification settings control in-app banners only; OS push notifications are not implemented.
- Cancel/Resolve for SOS is local and synced to the (simulated) cloud. Protocol v1 has no RF cancel packet, so other nodes are not told.
- Sequence numbers are seeded from the clock rather than persisted.

# Testing and validation

## Commands

```bash
export PATH="$HOME/flutter/bin:$PATH"
flutter pub get
dart run build_runner build   # only after changing lib/data/database/tables.dart
dart format .
flutter analyze
flutter test
```

## Last verified result

Run on Linux with Flutter 3.47.7 / Dart 3.13.5:

- `dart format .` - no changes needed
- `flutter analyze` - no issues found
- `flutter test` - 132 tests passed, none skipped

## What the tests cover

| Area | File (tests) | Examples |
|---|---|---|
| Protocol | `test/core/protocol_test.dart` (14) | round trips, missing/mistyped/out-of-range fields raise `FormatException`, empty identities, ACK stages, location and bounded-int readers |
| Database | `test/data/database_test.dart` (8) | foreign keys enforced, ms-precision timestamps, sync-queue de-duplication, SOS transition rules |
| Database integrity | `test/data/database_integrity_test.dart` (16) | unique constraints, restrict / cascade / set-null deletes, transaction rollback, atomic message + sync entry, persistence across reopen, newer-schema refusal, SOS `failed` transitions |
| Simulated transport | `test/services/transport_test.dart` (9) | connect sequence, ACK sequences, ERROR on failure / unknown route, disconnect cancels pending ACKs |
| Message lifecycle | `test/services/messaging_flow_test.dart` (10) | offline queueing, flush on connect, `delivered` only after ACK, retry, `local` recovery, dedupe, search |
| Packet validation | `test/services/coordinator_validation_test.dart` (26) | ACK sender/stage/reference rules, duplicate and stale ACKs, unexpected ACK sources, gateway identity (HELLO required, STATUS cannot promote or demote), malformed packets, ERROR handling for messages and SOS, transmit failures |
| SOS and sync basics | `test/services/sos_sync_test.dart` (10) | trigger offline/online, propagation, resolve/cancel, remote SOS, sync failures + retry counts |
| Sync reliability | `test/services/sync_reliability_test.dart` (11) | exponential backoff, manual bypass, per-entity ordering, lost-response idempotency, concurrent runs, stale-payload guard, interrupted-upload recovery |
| Restart recovery | `test/services/restart_recovery_test.dart` (2) | file-backed database reopened: queued messages, `local` recovery, SOS and sync queue survive; no double send on reconnect |
| Provider wiring | `test/services/provider_wiring_test.dart` (3) | every service constructed by its provider with matching parameters |
| State and settings | `test/state/state_and_settings_test.dart` (11) | preferences persistence, profile, location controller privacy rules and error states |
| UI workflows | `test/widget/app_flow_test.dart` (12) | empty dashboard, navigation, gateway connect, SOS confirm/resolve/failed-retry, offline compose, permission-denied map, sync screen, clear data |

Safeguards were also checked by deliberately breaking them (removing the stale-payload guard, per-entity ordering, backoff, foreign-key enforcement, `local`-message recovery and the ACK sender checks) and confirming that tests failed each time. That check is manual and not part of the suite.

Widget tests boot the real app against an in-memory Drift database with a fake GPS source and a fast simulated gateway. Database work in widget tests must run in the same fake-async zone as the widgets (`AppHarness.run`); `tester.runAsync` deadlocks against live Drift streams.

## Not tested

- The debug build was installed and launched on a Samsung Galaxy Tab S6 Lite (SM-P625), but no systematic on-device testing has been recorded: real GPS, runtime permission dialogs, map tile loading and tablet layout are unverified.
- No real hardware or cloud: USB serial, ESP32-C3, LoRa multi-hop, AWS IoT, MySQL and Grafana still need integration testing once they exist.

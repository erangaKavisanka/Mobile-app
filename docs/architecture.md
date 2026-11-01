# EcoLink architecture

## Overview

EcoLink is the mobile layer of a hybrid off-grid safety system. It stores user actions locally, runs messaging and SOS logic, and talks to a gateway through an abstract `DeviceTransport`. RF forwarding, gateway firmware and cloud services are outside the app; today they are simulated.

## Layers

1. **Presentation** (`features/*/presentation`, `shared/widgets`, `app/`): Flutter widgets and Riverpod providers. No SQL and no business rules.
2. **Domain** (`features/*/domain`): plain models (`Message`, `SosEvent`, `Node`, `SyncItem`, `AppPreferences`) and the interfaces the rest of the app depends on (`MessageRepository`, `SosRepository`, `NodeRepository`, `SyncRepository`, `LocationRepository`, `DeviceTransport`, `CloudGateway`, `LocationSource`).
3. **Data** (`data/`): Drift database, repository implementations, and services that orchestrate repositories + transport (`MessagingService`, `SosService`, `SyncService`, `GatewayCoordinator`).
4. **Protocol** (`core/protocol`): `ProtocolMessage` (JSON v1), `ProtocolFactory` (builds packets, typed payload readers). Serialization is independent of UI and transport.

## State management and navigation

Riverpod providers in `app/providers.dart` expose repositories, services and Drift-backed `StreamProvider`s, so screens update reactively. GoRouter uses a `StatefulShellRoute` with five branches (Home, Messages, SOS, Map, Devices) plus root routes for Settings, Profile and Sync.

## Lifecycles

- **Message:** `local → queued → sentToGateway → delivered` or `failed` (retry returns it to `queued`). Only an ACK (`stage: delivered`) produces `delivered`. Incoming messages are stored as `delivered` (they arrived) and never trigger an ACK from the app.
- **SOS:** `triggered → sentToGateway → acknowledged → propagated → resolved | cancelled`. A gateway ERROR before acknowledgement moves it to `failed` (still active); it is re-sent by the Retry button or automatically on reconnect. The repository ignores backwards transitions, so late or duplicate ACKs are harmless; closed events never change. Events received from other nodes are stored as `propagated`.
- **Sync item:** `pending → inProgress → synced | failed`; failures keep `retryCount` and `lastError`. Automatic retries use exponential backoff (30 s doubling, capped at 1 h); "Sync now" bypasses it. Items of one entity upload in order (an update waits for its create). A row re-queued during an upload is not marked synced with the stale snapshot. Interrupted `inProgress` rows are reset on startup. `CloudGateway.push` must be idempotent per `SyncItem.idempotencyKey`.

## Offline-first guarantees

- Every user action is persisted before any transmission is attempted.
- A message/SOS and its sync-queue row are written in one transaction.
- On startup `GatewayCoordinator.start()` re-queues messages left in `local` and the next connection flushes queued messages and unsent SOS events.
- Duplicate packets (same message id / SOS id) are ignored by primary-key constraints.

## Boundaries

- Mobile application: this repository.
- RF network and gateway: ESP32-C3 + LoRa RA-02 firmware (not integrated).
- Cloud: AWS IoT Core, MySQL, Grafana (not integrated).

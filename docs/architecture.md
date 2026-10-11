# EcoLink architecture

## Overview

EcoLink is the mobile application layer in a hybrid off-grid safety system. It does not implement RF forwarding, gateway routing, or cloud telemetry directly. Instead, it focuses on collecting user actions, storing data locally, managing messaging flows, and exposing clean interfaces for external device and cloud integrations.

## Main layers

### 1. Presentation layer

- Dashboard screen for node health and safety status
- Messaging screen for conversations, queue tracking, and lifecycle states
- SOS screen for event creation, acknowledgement flow, and resolution
- Devices screen for node metadata and USB connectivity
- Settings screen for node configuration and diagnostics

### 2. State and domain layer

- Local app state manages conversations, devices, and SOS events
- Message lifecycle states represent queued, sent, received, and failed states without claiming delivery confirmation
- Domain models separate the app’s data concerns from transport and persistence concerns

### 3. Persistence layer

- SharedPreferences is used for local persistence of messages, SOS history, and local configuration
- This supports offline-first workflows and ensures the app remains useful without internet access

### 4. Protocol and transport boundary

- The JSON-based protocol models define message schema and compatibility
- USB transport and serial framing are abstracted away from app logic
- A mock transport layer simulates device messages for development and validation

### 5. Integration boundary

- Cloud synchronization is represented by status models and placeholder interfaces
- Actual gateway, MQTT, AWS IoT, and database components remain outside the phone application scope

## Data flow

1. User creates or receives a message.
2. The message is stored locally and marked with an explicit lifecycle state.
3. If the mock or hardware transport is available, the message can be sent through the serial boundary.
4. Acks are treated as the only valid proof of delivery, and a message cannot be marked as delivered without evidence.
5. Synchronization metadata is updated only when the gateway/cloud contract confirms the event.

## Boundaries

- Mobile application: EcoLink UI and local logic
- RF network: ESP32 and LoRa mesh nodes
- Gateway: internet-connected bridge that synchronizes buffered messages
- Cloud: MQTT/AWS and storage/monitoring services

EcoLink intentionally avoids claiming responsibilities outside the phone app boundary.

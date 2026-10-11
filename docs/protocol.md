# EcoLink protocol specification

## Scope

This protocol defines a simple JSON message format used between the Flutter app and the ESP32-based firmware. The design deliberately keeps transport framing independent from LoRa packet encoding.

## Protocol version

- Current version: 1
- Field: `protocol_version`
- Compatibility rule: messages with a different protocol version are rejected

## Supported message types

- HELLO
- STATUS
- TEXT
- SOS
- ACK
- ERROR

## Message schema

```json
{
  "protocol_version": 1,
  "type": "TEXT",
  "message_id": "unique-message-id",
  "source_id": "NODE_A",
  "destination_id": "NODE_C",
  "sequence_number": 1,
  "hop_limit": 4,
  "created_at": "2026-10-11T12:00:00.000Z",
  "payload": {
    "text": "Hello"
  }
}
```

## Field definitions

- `message_id`: unique sender-scoped identifier for duplicate detection and retries
- `source_id`: origin node or application identity
- `destination_id`: target node or broadcast target
- `sequence_number`: monotonically increasing per source
- `hop_limit`: maximum RF forwarding hops
- `created_at`: ISO-8601 timestamp in UTC
- `payload`: type-specific content object

## Delivery semantics

- A message is only marked delivered when an explicit ACK is received.
- Unacknowledged messages remain queued in local storage.
- Duplicate detection uses a stable message ID and sequence check.
- Retries must not create duplicate independent SOS events.

## Serial framing

- The app serializes a single protocol message as UTF-8 JSON text
- The transport layer may wrap the message with framing if needed, but the logical message remains JSON
- Maximum payload size should remain within the USB transport constraints, and the app uses a conservative upper bound of 512 bytes

## Error handling

- Malformed JSON is rejected safely
- Unsupported message types are treated as protocol errors
- Invalid or missing fields throw a `FormatException`
- Unknown protocol version triggers a compatibility failure

## Implementation notes

- Message parsing is performed in the protocol model layer
- Duplicate and retry logic sits above the serializer, not inside the UI
- The app does not claim actual RF delivery without a valid ACK signal

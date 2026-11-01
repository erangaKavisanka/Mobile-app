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
- Duplicate detection uses the stable message ID (primary key of the stored message / SOS event); `sequence_number` is carried for the firmware but is not used by the app for de-duplication.
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

## Security note

Protocol v1 has no authentication, signing or encryption. `source_id` is not proof of origin. The validation below limits what an unexpected packet can do, but it is not a substitute for link-level trust: the USB transport must only deliver packets that came from the connected gateway.

## Implementation notes

- Message parsing is performed in the protocol model layer
- Duplicate and retry logic sits above the serializer, not inside the UI
- The app does not claim actual RF delivery without a valid ACK signal

## Payloads used by the app (v1)

| Type | Direction | Payload |
|---|---|---|
| `TEXT` | both | `text` (string), optional `location: {lat, lon, accuracy?}`. `message_id` is the app's message UUID |
| `SOS` | both | `sos_id` (equals `message_id`), optional `location`, optional `note` |
| `ACK` | gateway/node → app | `ack_for` (message id), `stage` = `gateway` (accepted for RF), `delivered` (destination confirmed a TEXT), `propagated` (SOS re-broadcast), optional `nodes_reached` |
| `STATUS` | gateway/node → app | `name`, `role` (`gateway`/`relay`/`traveller`), `online`, optional `battery` (0-100), optional `rssi` (dBm) |
| `HELLO` | gateway → app | `name`, `role`, optional `firmware` |
| `ERROR` | gateway → app | `ref` (message id), `code`, optional `detail` |

Missing optional readings (battery, RSSI) are shown as "-" in the UI, never as zero.

## Validation performed by the app

Packets that fail any check are dropped and recorded as a warning in the device activity log; they never change a stored message, SOS event or node.

- Structure: `source_id`/`destination_id` non-empty strings, `sequence_number`/`hop_limit` non-negative integers, payload a non-empty object.
- Identity: packets whose `source_id` is this phone's own node ID are ignored. ACK and ERROR must be addressed directly to this phone; STATUS, HELLO, TEXT and SOS may also be broadcast.
- Payloads: required fields present and typed; `battery` 0-100, `rssi` -150..0, `role` one of `gateway`/`relay`/`traveller`, coordinates within range, SOS `sos_id` equal to `message_id`.
- Gateway identity: only a `HELLO` with `role: gateway` can introduce a gateway; a `STATUS` cannot promote a node to gateway, and nothing can change an established gateway's role. Gateway status is what authorises gateway-stage ACKs, propagation ACKs and ERRORs.
- ACK references must name one of this phone's own outgoing messages or SOS events. Allowed senders per stage: `gateway` and `propagated` only from a node known to be a gateway; `delivered` only from the message's recipient, and only for messages. `propagated` applies only to SOS events.
- ERROR must come from a gateway and reference one of this phone's messages (-> `failed`) or SOS events (-> SOS `failed`).
- Duplicate or stale ACK/ERROR packets are safe: state only moves forward (an explicit ACK can still upgrade a `failed` item) and nothing is logged for a no-op.

Messages are limited to 512 bytes of UTF-8 JSON (`AppConstants.maxMessageBytes`); longer messages are rejected before they are stored.

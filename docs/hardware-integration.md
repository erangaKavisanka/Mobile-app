# Hardware integration notes

## ESP32-C3 expectations

The EcoLink prototype assumes the connected hardware is an ESP32-C3 based node or gateway companion board capable of USB serial communication and local message buffering. Hardware capabilities should be confirmed by the firmware team.

## USB serial assumptions

- USB port is used for app-to-firmware data exchange
- The firmware is expected to translate between JSON protocol messages and LoRa packet representations
- The app does not assume every board exposes the same USB configuration
- The app distinguishes between demo mode and real hardware mode explicitly

## Android permissions

The app is structured for future USB permission handling on Android. In a real device deployment, the Android manifest and USB permission flow must be validated against the final hardware interface and USB device vendor/product IDs.

## Firmware contract

The firmware should:

- report device identity and status
- accept JSON TEXT and SOS payloads
- emit ACK and ERROR messages
- maintain local queueing and retry semantics
- refrain from claiming end-to-end delivery without a valid ACK

## Physical hardware tests still required

- USB enumeration on an ESP32-C3 board
- Serial data exchange over the selected cable and board configuration
- ACK processing for TEXT and SOS flows
- RF forwarding and node-to-node message propagation tests
- Gateway and cloud synchronization validation with the actual network path

This app currently exposes mock behavior and safe placeholders for these features without claiming they have been verified on real hardware.

## Adding the real USB transport

1. Implement `DeviceTransport` (`lib/features/devices/domain/device_transport.dart`) with a USB serial plugin: open the port in `connect()`, frame each `ProtocolMessage.toEncodedJson()` as one line, and parse inbound lines with `ProtocolMessage.fromEncodedJson` (drop and log lines that throw `FormatException`).
2. Set `isSimulated` to `false`. The UI then hides simulation badges and controls automatically.
3. Override `deviceTransportProvider` in `lib/app/providers.dart`.
4. Add the USB device filter and permission flow to the Android manifest (the optional `android.hardware.usb.host` feature is already declared).

`MessagingService`, `SosService`, `GatewayCoordinator` and all screens depend only on the interface. `SimulatedDeviceTransport` documents the expected packet sequence: HELLO + STATUS on connect, ACK(`gateway`) then ACK(`delivered`) or ERROR for a TEXT, ACK(`gateway`) then ACK(`propagated`) for an SOS.

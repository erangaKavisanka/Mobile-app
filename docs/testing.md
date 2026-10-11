# Testing and validation

## Checks executed

The following commands were run in the workspace:

```bash
export PATH="/home/erangak/flutter/bin:$PATH"
cd "/home/erangak/Uni works/FYP/Mobile app"
dart format .
flutter analyze
flutter test
flutter run -d chrome --debug
```

## Results

- `flutter analyze`: passed with no issues
- `flutter test`: passed, 1 test passed
- `flutter run -d chrome --debug`: launched successfully on the available Chrome target

## Mocked behavior

- Demo-mode USB simulation
- Mock cloud synchronization status
- Local offline queueing and persistence
- Shelter for SOS acknowledgement workflows without live hardware confirmations

## Hardware tests required

- ESP32-C3 USB serial connection
- RF network message propagation in a three-node testbed
- Gateway queue synchronization to MQTT and AWS IoT
- MySQL and Grafana pipeline verification

The application intentionally separates these real-world integration paths from the mobile UI logic until the hardware and backend systems are validated separately.

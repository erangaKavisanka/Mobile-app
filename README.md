# EcoLink

EcoLink is a Flutter-based traveller safety application designed for off-grid communication, emergency response workflows, and opportunistic synchronization. It is built as a mobile-first prototype for the final-year research project: “A Hybrid RF-Based Off-Grid Communication Network with Opportunistic Cloud Synchronization for Real-Time Traveller Safety and Emergency Response.”

## Features

- Material 3 dashboard with a nature-inspired theme
- USB connection and RF status placeholders with explicit demo-hardware states
- Offline-first messaging and conversation history
- SOS activation, history, and resolution workflow
- Device registry and node metadata tracking
- Local persistence with delayed sync semantics
- Protocol models for JSON over USB serial
- Mock synchronization status and cloud integration interfaces

## Prerequisites

- Flutter SDK 3.47.7 or newer
- Dart SDK included with Flutter
- Android Studio / Android SDK for Android builds
- Chrome for web validation in this environment

## Setup

```bash
export PATH="/home/erangak/flutter/bin:$PATH"
cd "/home/erangak/Uni works/FYP/Mobile app"
flutter pub get
```

## Run

Current environment:

```bash
export PATH="/home/erangak/flutter/bin:$PATH"
cd "/home/erangak/Uni works/FYP/Mobile app"
flutter run -d chrome --debug
```

When Android SDK tooling is installed, the app can also be run with:

```bash
flutter run
```

## Test and validation

```bash
flutter analyze
flutter test
```

## Current limitations

- No Android SDK was available in this environment, so Android device or emulator validation was not possible here.
- Real ESP32-C3 hardware, USB serial routing, LoRa mesh forwarding, and gateway/cloud synchronization are intentionally represented as mock and interface layers rather than live system integrations.
- The app does not claim automated emergency calls or direct cloud connectivity without the external gateway and backend components.

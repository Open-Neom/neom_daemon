<p align="center">
  <img src="doc/assets/banner.jpg" alt="Neom Daemon Banner" width="100%" />
</p>

# ⚙️ Neom Daemon (`neom_daemon`)

[![Pub Version](https://img.shields.io/badge/pub-v0.1.0-blue.svg)](https://pub.dev)
[![Dart SDK](https://img.shields.io/badge/Dart-3.0+-0175C2.svg)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux%20%7C%20Windows%20%7C%20Web%20%7C%20Mobile%20%7C%20Docker-purple.svg)]()
[![License](https://img.shields.io/badge/License-MIT-green.svg)]()

> **Neom Daemon** is a universal, open background server and autonomous task execution engine for **Dart & Flutter** applications across the entire **Neom Ecosystem** (Itzli, Neom DAW, PDF Readers, EEG Processors, Games, VR/AR, Commerce, and Cloud Nodes).

---

## 🌟 Why Neom Daemon?

Building background services, cross-device controllers, or local AI agent nodes in Flutter currently requires stitching together multiple unintegrated packages. **Neom Daemon** provides a turnkey, production-ready solution that turns any Dart or Flutter process into a secure, multi-platform background node server.

### Core Features
- 🔌 **Configurable Port Binding**: Run on the default port (`8392`), bind to any custom user-defined port, or specify port `0` for dynamic OS assignment.
- 🛡️ **Defense-in-Depth Security (`DaemonCommandRouter`)**: Built-in safety checks blocking dangerous system commands before execution.
- 📊 **Telemetry & Health Checks**: Exposes `/status` and `/health` JSON endpoints reporting CPU, RAM, active task count, and uptime.
- 🚀 **Decoupled Architecture**: Clean separation between server/host runtime (`neom_daemon`) and remote control client UI (`neom_rc`).
- 🌐 **Multi-Platform Pure Dart Engine**: Runs seamlessly on Desktop, Mobile, Headless Linux Servers, Docker Containers, and Standalone VR Headsets (Android kernel).

---

## 📦 Installation

Add `neom_daemon` to your `pubspec.yaml`:

```yaml
dependencies:
  neom_daemon:
    git:
      url: git@github.com:Open-Neom/neom_daemon.git
```

Or via pub.dev once published:

```yaml
dependencies:
  neom_daemon: ^0.1.0
```

---

## 🚀 Quick Start

### 1. Basic Server Startup (Default Port `8392`)

```dart
import 'package:neom_daemon/neom_daemon.dart';

void main() async {
  final daemon = NeomDaemonServer();
  final success = await daemon.start();

  if (success) {
    print('Neom Daemon running on port: ${daemon.port}');
  }
}
```

### 2. Custom Port Binding

```dart
void main() async {
  // Bind to a user-selected port (e.g. 9090)
  final daemon = NeomDaemonServer(port: 9090);
  await daemon.start(customPort: 9090);

  print('Neom Daemon running on custom port: ${daemon.port}');
}
```

### 3. Dynamic Port Allocation (OS Auto-Assign)

```dart
void main() async {
  // Pass port 0 to let the OS assign an available port automatically
  final daemon = NeomDaemonServer(port: 0);
  await daemon.start(customPort: 0);

  print('Neom Daemon active on dynamic port: ${daemon.port}');
}
```

---

## 💻 Multi-Platform Capabilities Matrix

| Platform | Primary Capabilities & Use Cases |
| :--- | :--- |
| **Desktop** *(macOS, Win, Linux)* | Local AI agent node, shell execution, VST audio sandboxing, GGUF model warm-loading. |
| **Mobile** *(Android, iOS)* | BLE biometric sensor relay, background offline transaction sync, notification queue. |
| **Server / Cloud** *(Docker, Linux)* | Headless node server, vector RAG database indexer (`saia_turbovec`), API gateway. |
| **VR / AR** *(Meta Quest, Android-based)* | Spatial head tracking & 6DoF controller telemetry streaming (`vrlizate`). |
| **IoT / Embedded** *(Raspberry Pi)* | Physical GPIO pin hardware control, sensor monitoring, ambient environment integration. |

---

## 📐 Architecture: `neom_daemon` vs `neom_rc`

```
┌─────────────────────────────────────────────────────────────────────────┐
│                            NEOM ECOSYSTEM                               │
├────────────────────────────────────┬────────────────────────────────────┤
│            neom_daemon             │              neom_rc               │
│     (Server / Host / Runtime)      │     (Client / Remote Controller)   │
├────────────────────────────────────┼────────────────────────────────────┤
│ • Headless background service      │ • User remote control UI           │
│ • Local CLI & task execution       │ • QR Code Scanner & Handshake      │
│ • Hardware telemetry & health      │ • Virtual Touchpad & Voice Remote  │
│ • Configurable HTTP/IPC Listener   │ • Transport Adapters (Firestore)   │
└────────────────────────────────────┴────────────────────────────────────┘
```

---

## 🛣️ Expanded Implementation Roadmap

### 📍 Phase 1: Core Foundation (`v0.1.0`) — *Current Release*
- [x] Pure Dart HTTP/IPC server on configurable custom/dynamic ports.
- [x] Basic security command router (`DaemonCommandRouter`) with anti-destructive filters.
- [x] Hardware telemetry JSON endpoints (`/status`, `/health`).
- [x] Integration with `neom_cli` shell executor.

### 📍 Phase 2: Discovery & Real-Time Communications (`v0.2.0`)
- [ ] **mDNS / ZeroConf Auto-Discovery**: Automatic network broadcasting (`_neom-daemon._tcp.local`) so mobile & desktop clients discover daemon instances without manual IP/port configuration.
- [ ] **Real-Time WebSockets (`/ws/logs`, `/ws/telemetry`)**: Stream `stdout`/`stderr` logs and CPU/RAM usage live to connected client apps.
- [ ] **mTLS & HMAC Token Handshake**: Encrypted client-daemon authentication pairing protocol.

### 📍 Phase 3: Domain & Sensor Integrations (`v0.3.0`)
- [ ] **Audio & VST Plugin Sandboxing (`neom_vst` / `neom_sound`)**: Isolated worker processes for VST/AU audio plugins to prevent DAW main UI crashes.
- [ ] **BLE Sensor & Biometric Streaming (`neom_ble` / `neom_biochip`)**: Stream EEG, heart-rate, and gyroscope sensor data via OSC/WebSockets.
- [ ] **VR & Spatial Tracking Relay (`vrlizate`)**: Broadcast 6DoF spatial head-tracking data from standalone VR headsets to desktop rendering nodes.

### 📍 Phase 4: Enterprise & AI Operations (`v0.4.0`)
- [ ] **Vector RAG & Memory Server (`saia_turbovec`)**: Background vector embedding and indexing of chat logs, codebases, and documents (< 10ms semantic queries).
- [ ] **Offline Sync & Transaction Queue (`neom_commerce`)**: Resilient background transaction queueing with automatic cloud conflict resolution.
- [ ] **Model Warm-Loading & GGUF Cache Manager**: Background warm-loading of GGUF/Ollama neural models into unified system RAM.

### 📍 Phase 5: Production Maturity (`v1.0.0`)
- [ ] **Declarative Security Sandboxing**: Pre-packaged permission profiles (`ReadOnly`, `RestrictedWorkspace`, `FullControl`).
- [ ] **Isolate Worker Pool Manager**: Multi-threaded isolate pool orchestration leveraging Apple Silicon M-series & multi-core CPUs.
- [ ] **Official pub.dev Package Publication**.

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

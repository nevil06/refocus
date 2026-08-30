# 🎯 Refocus Again

> A production-quality, privacy-first Android focus and digital wellbeing application that reliably locks distracting apps during timed study sessions.

---

## 📖 Overview

**Refocus Again** is built to help students, developers, and professionals reclaim deep concentration. Unlike apps that rely purely on frontend timers, **Refocus Again** uses a dual-engine architecture: a calm, modern Flutter interface powered by a dedicated, resilient Kotlin native background blocking service.

---

## ✨ Features (Phase 1 — Core Product)

### 🔒 Resilient Native App Blocker
- Intercepts launch attempts of user-selected distracting apps during active focus sessions.
- **Event-Driven Interception**: Uses Android's `AccessibilityService` (`TYPE_WINDOW_STATE_CHANGED`) for instant detection without wasteful polling loops.
- **Native Block Shield**: Displays a full-screen `BlockActivity` overlay showing remaining time and a direct "Back to Focus" action, functioning even if the Flutter UI process is killed or backgrounded.
- **Critical System Safeguards**: Never blocks phone dialers, emergency services, or essential device settings.

### ⏱️ Timestamp-Based Focus Timer
- Calculates remaining time dynamically using timestamps (`plannedEndTime - currentTimeMillis()`), eliminating timer drift, pausing, or corruption when the screen is locked or the device goes to sleep.
- Custom and preset durations (15m, 25m, 45m, 1h, 1h 30m, 2h).
- Optional session tagging (e.g., *Physics*, *Calculus*, *Deep Coding*).

### 🛡️ Strict Focus Mode
- **Normal Mode**: Standard confirmation before ending a session early.
- **Strict Mode**: Introduces deliberate friction to curb impulsive cancellations—including a mandatory 5-second countdown and typed confirmation ("STOP").

### 📊 Local History & Streak Tracking
- **100% Offline & Private**: All data is stored locally in SQLite.
- Daily focus time totals and current streak tracking.
- Grouped chronological history of completed and interrupted sessions.

### 🔐 Privacy-First Architecture
- Accessibility service configured with `canRetrieveWindowContent="false"`.
- **Zero data collection**: No keystrokes, screen text, passwords, or personal messages are accessed or recorded.
- No third-party tracking, analytics SDKs, or cloud dependencies.

---

## 🏗️ Architecture

```
                 REFOCUS AGAIN
                       │
                Flutter Application (Dart)
                       │
          ┌────────────┴────────────┐
          ▼                         ▼
      Flutter UI              Kotlin Native
  (Riverpod + SQLite)               │
                    ┌───────────────┼───────────────┐
                    ▼               ▼               ▼
              Accessibility    Foreground      Persistent
                 Service        Service           State
          (Event Interceptor) (Notification) (SharedPrefs + SQLite)
                    │
                    ▼
             Block Controller
                    │
                    ▼
              BlockActivity
             (Native Screen)
```

| Layer | Technology | Purpose |
| :--- | :--- | :--- |
| **Frontend Framework** | **Flutter 3.x** | Navigation, UI screens, reactive state management |
| **State Management** | **Flutter Riverpod** | Reactive, compile-time safe state architecture |
| **Local Storage** | **SQLite (sqflite)** | Local persistence of sessions, history, and streak stats |
| **Native Android** | **Kotlin** | Accessibility service, foreground service, native overlay |
| **Native Bridge** | **MethodChannel** | Type-safe communication between Flutter and Kotlin |

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.24+ recommended)
- Android Studio / Android SDK (API Level 26+)
- JDK 17+

### Installation & Run

1. **Clone the repository**:
   ```bash
   git clone https://github.com/nevil06/refocus.git
   cd refocus/refocus
   ```

2. **Install Flutter dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run Unit Tests**:
   ```bash
   flutter test
   ```

4. **Build and Run on Android**:
   ```bash
   flutter run
   ```

5. **Build Debug APK**:
   ```bash
   flutter build apk --debug
   ```

---

## 📱 Android Permissions Explained

| Permission | Reason |
| :--- | :--- |
| `BIND_ACCESSIBILITY_SERVICE` | Required to detect foreground package changes and trigger the blocking shield when a distracting app is launched. |
| `FOREGROUND_SERVICE_SPECIAL_USE` | Keeps the focus session countdown alive in the background and presents an ongoing status notification. |
| `RECEIVE_BOOT_COMPLETED` | Restores active focus sessions if the device reboots during a session. |
| `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | Prevents OEM aggressive battery managers from killing the blocker when idle. |

---

## 🗺️ Product Roadmap

- [x] **Phase 1: Core Focus & Resilient App Blocking** *(Completed)*
- [ ] **Phase 2**: Pomodoro cycles, interval breaks, custom goals, and advanced study analytics.
- [ ] **Phase 3**: Study rooms, friend leaderboards, and real-time social presence.
- [ ] **Phase 4**: iOS implementation via Apple Screen Time & FamilyControls APIs.
- [ ] **Phase 5**: AI Study Coach & personalized preparation plans.
- [ ] **Phase 6**: Verified study rooms and campus/exam communities.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
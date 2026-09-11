# 🎯 Refocus

<p align="center">
  <img src="assets/images/logo.png" alt="Refocus Logo" width="160" />
</p>

> A production-quality, privacy-first Android focus and productivity application that reliably locks distracting apps, mutes disruptive notifications, and pins your device during deep study sessions.

---

## 📖 Overview

**Refocus** is built to help students, developers, and professionals reclaim deep concentration. Unlike apps that rely purely on frontend timers, **Refocus** uses a dual-engine architecture: a calm, modern Flutter interface powered by a resilient, event-driven Kotlin native background blocking service with native screen pinning and uninstall protection.

---

## ✨ Features

### 📊 Track Your Focus & Analytics
- **Interactive 7-Day Focus Graph**: Real-time weekly bar charts (Mon–Sun) tracking focused minutes against daily goals.
- **Focus Mastery Score (0–100)**: Visual arc gauge measuring study consistency, streak retention, and session completion rate.
- **Peak Performance Window**: Hourly distribution analysis across Morning, Afternoon, Evening, and Night.
- **Distraction Shield Metrics**: Track blocked distracting apps and completed vs interrupted sessions.

### 🔒 Resilient Native App Blocker
- Intercepts launch attempts of user-selected distracting apps during active focus sessions.
- **Event-Driven Interception**: Uses Android's `AccessibilityService` (`TYPE_WINDOW_STATE_CHANGED`) for instant detection without wasteful polling loops.
- **Native Block Shield**: Displays a full-screen `BlockActivity` overlay showing remaining time and a direct "Back to Focus" action, functioning even if the Flutter UI process is killed or backgrounded.
- **Critical System Safeguards**: Never blocks phone dialers, emergency services, or essential device settings.

### 🔕 Notification Silencing & Muting
- **NotificationListenerService Integration**: Automatically intercepts and suppresses incoming notifications, banners, sounds, and vibration alerts from blocked apps during active focus sessions.
- **Selective & Safe**: Critical communications (phone calls, emergency alerts, alarms) are always delivered without interruption.
- Integrated directly into the onboarding setup and configurable from Settings.

### 📌 Screen Pinning (Full-Phone Focus Lock)
- **Per-Session Commitment Choice**: Opt to lock your phone strictly to Refocus for the duration of the session via Android's native Lock Task Mode (`startLockTask()`).
- **Home & Recents Restricted**: Disables the home button, recents overview, and status bar pull-down to eliminate reflex phone checks.
- **Safety Valve Intact**: Fully preserves Android's standard physical exit gesture (holding Back + Overview / swipe up & hold) to ensure emergency access at all times; gesture unpinning is gracefully logged as an interrupted session.
- **Automatic Release**: Automatically unpins the device upon natural session completion.

### 🛡️ Uninstall Protection (Device Admin)
- **Anti-Bypass Commitment**: Prevents compulsive uninstallation of the app mid-session via standard Android `DevicePolicyManager` and `DeviceAdminReceiver`.
- **One-Time Consent**: Transparent opt-in with a pre-consent explainer dialog before opening Android's system `ACTION_ADD_DEVICE_ADMIN` screen.
- **Zero Anti-Removal Abuse**: Standard Android system deactivation (*Settings → Security → Device Admin apps → Refocus → Deactivate*) remains 100% accessible and untouched at all times.

### ⏱️ Timestamp-Based Focus Timer & 3-Tier Strict Mode
- Calculates remaining time dynamically using timestamps (`plannedEndTime - currentTimeMillis()`), eliminating timer drift when the screen is locked or the device sleeps.
- **3 Strictness Tiers**:
  - **Off (Normal Mode)**: Standard session with immediate cancellation option.
  - **Friction Mode**: Requires a mandatory 5-second countdown and typing "STOP" to cancel early.
  - **Locked Mode**: No cancellation UI; runs until the timer completes naturally.

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
                    REFOCUS
                       │
                Flutter Application (Dart)
                       │
          ┌────────────┴────────────┐
          ▼                         ▼
      Flutter UI              Kotlin Native
  (Riverpod + SQLite)               │
                    ┌───────────────┼────────────────────────┐
                    ▼               ▼                        ▼
              Accessibility    Notification             Foreground
                 Service         Listener                 Service
           (Event Interceptor) (Mute Alerts)           (Status Notif)
                    │               │                        │
                    ▼               ▼                        ▼
              Block Controller  Device Admin           Screen Pinning
                    │          (Uninstall Shield)     (Lock Task Mode)
                    ▼
              BlockActivity
             (Native Screen)
```

| Layer | Technology | Purpose |
| :--- | :--- | :--- |
| **Frontend Framework** | **Flutter 3.x** | Navigation, UI screens, reactive state management |
| **State Management** | **Flutter Riverpod** | Reactive, compile-time safe state architecture |
| **Local Storage** | **SQLite (sqflite)** | Local persistence of sessions, history, and streak stats |
| **Native Android** | **Kotlin** | Accessibility service, notification listener, device admin, lock task mode, native overlay |
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
| `BIND_NOTIFICATION_LISTENER_SERVICE` | Intercepts and mutes notifications and banner alerts from user-selected blocked apps during focus. |
| `BIND_DEVICE_ADMIN` | Prevents the app from being uninstalled during active focus sessions to uphold commitment (optional opt-in). |
| `FOREGROUND_SERVICE_SPECIAL_USE` | Keeps the focus session countdown alive in the background and presents an ongoing status notification. |
| `RECEIVE_BOOT_COMPLETED` | Restores active focus sessions if the device reboots during a session. |
| `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | Prevents OEM aggressive battery managers from killing the blocker when idle. |

---

## 🗺️ Product Roadmap

- [x] **Phase 1: Core Focus & Resilient App Blocking** *(Completed)*
- [x] **Phase 1.5: Locked Mode, Screen Pinning & Device Admin Protection** *(Completed)*
- [ ] **Phase 2**: Pomodoro cycles, interval breaks, custom goals, and advanced study analytics.
- [ ] **Phase 3**: Study rooms, friend leaderboards, and real-time social presence.
- [ ] **Phase 4**: iOS implementation via Apple Screen Time & FamilyControls APIs.
- [ ] **Phase 5**: AI Study Coach & personalized preparation plans.
- [ ] **Phase 6**: Verified study rooms and campus/exam communities.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
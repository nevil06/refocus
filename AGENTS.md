# AGENTS.md

Guidance for AI coding agents (and humans) working in this repository.

## Project

Refocus Again is a privacy-first Android focus and app-blocking app. It uses a
dual-engine architecture: a Flutter UI (Dart) plus a native Kotlin blocking
engine (Accessibility Service, foreground Service, home-screen widget). The
native side is the source of truth for the active session so blocking survives
the Flutter process being killed.

- Flutter UI and state: `lib/`
- Native Android engine: `android/app/src/main/kotlin/com/refocusagain/refocus_again/`
- Branding assets and logo generator: `assets/branding/`

## Golden rules

1. Do not use emojis anywhere: not in source, comments, UI strings, commit
   messages, or docs. Use Material icons or vector drawables for iconography.
2. Do not use em dashes or en dashes in code, UI strings, or docs. Use commas,
   periods, or parentheses instead. Plain ASCII punctuation only.
3. Keep the app fully offline. No analytics, no third-party tracking, no network
   calls that transmit user data.
4. Privacy: the Accessibility Service may read only the package name of the
   active window. Never read or log screen text, fields, or content.
5. Never block critical system packages (dialer, emergency, launcher, settings,
   system UI, input methods). See `SYSTEM_EXEMPT_PACKAGES` in
   `BlockController.kt` and never weaken that list.
6. Timing is always timestamp-based (`plannedEndTime - now`). Never introduce a
   drifting per-second counter as the source of truth.

## HARD RULES: blocking enforcement (do not weaken)

These are correctness invariants. Breaking one reintroduces the inconsistent
blocking bugs that were fixed.

1. A blocked app must NEVER remain in the foreground during an active session.
2. Enforcement must run from the `AccessibilityService` context. Android 10 and
   later SILENTLY DROP background activity launches from a plain `Service`, so
   launching `BlockActivity` from `FocusBlockerService` does not work. Always
   pass the accessibility service into
   `BlockController.checkAndBlock(context, pkg, service)`.
3. The primary foreground watchdog lives in `RefocusAccessibilityService`, not in
   `FocusBlockerService`. The service loop is only a delegating safety net and
   must never try to launch the shield itself.
4. There must always be a hard fallback. If the shield cannot be shown, or the
   blocked app is still foreground shortly after, call
   `performGlobalAction(GLOBAL_ACTION_HOME)`. This always works from an
   accessibility service and is the guarantee behind rule 1.
5. Throttling must never suppress enforcement while the shield is down.
   `BlockActivity` reports `BlockController.isShieldVisible`; only throttle
   re-launches when the shield is genuinely visible for the same package.
6. Detection must be hybrid: accessibility events plus the polling watchdog.
   Events alone miss apps that were already resident in the background and are
   resumed from Recents. Do not remove either path.
7. Strict mode polls faster and re-asserts sooner. Never make strict mode weaker
   than normal mode.

## Accessibility permission is a hard dependency

Blocking is impossible without accessibility access, so it must never fail
silently.

1. The app re-verifies accessibility every time it returns to the foreground
   (`MainShell` is a `WidgetsBindingObserver` that invalidates
   `permissionStatusProvider`).
2. Home shows a prominent red banner when access is off, stating that blocking is
   inactive, with a button that deep-links to settings.
3. Starting a session is blocked when access is off: Quick Start shows a dialog
   and the setup screen shows a snackbar with an Enable action. Never start a
   session that cannot be enforced.

### Device gotcha: the floating accessibility shortcut

Some devices add an enabled service to the system setting
`accessibility_button_targets`, which makes Android draw a floating accessibility
shortcut showing the app icon. That button belongs to the OS, not to this app, so
the app cannot give it behaviour, and on some OEM builds hiding it interferes with
the service.

Our service explicitly does NOT request it (verified via
`adb shell dumpsys accessibility`, which reports `requestA11yBtn=false`), and the
config must never add `flagRequestAccessibilityButton`.

To remove the floating shortcut on a device without disabling the service:

```bash
adb shell settings delete secure accessibility_button_targets
```

Confirm the service survived with:

```bash
adb shell settings get secure enabled_accessibility_services
```

## Consistency rules

0. The chosen (blocked) apps are persisted in SQLite and
   `selectedBlockedPackagesProvider` in `lib/core/providers/core_providers.dart`
   is the SINGLE SOURCE OF TRUTH for that selection. Rules:
   - Never read the selection from an in-memory copy when starting a session.
     `session_setup_screen` and Quick Start both read the persisted list from the
     database at the moment the session starts.
   - Every mutation must be AWAITED before returning, so a choice survives the
     app being killed immediately afterwards. Fire-and-forget writes lose data.
   - Select All / Deselect All must use `AppDatabase.setAppsBlockedBatch`, which
     writes in a single transaction rather than issuing many independent writes.
   - After any mutation, invalidate `selectedBlockedPackagesProvider` and
     `blockedAppsCountProvider` so Settings, Home and session setup all refresh.
   - A saved package that is not in the discovered installed-app list must still
     be shown as chosen. Never silently drop a saved selection.

1. Any data shown in the UI that depends on sessions must recompute when session
   state changes. Riverpod providers that read the database must
   `ref.watch(focusSessionProvider)` (see `homeStatsProvider`,
   `historyProvider`). A provider that reads the DB once will show stale totals.
2. In-progress (`active`) sessions are excluded from History and from Recent
   Sessions. They are counted only once completed.
3. Colors must come from `AppColors`, which resolves per system brightness.
   Because those are runtime getters, widgets holding them cannot be `const`.
4. Native XML colors (`values/colors.xml`, `values-night/colors.xml`) must stay
   visually in sync with `AppColors` for both light and dark.
5. Dialogs that contain a text field must use a normal centered `AlertDialog`
   with `scrollable: true`. Screens behind such dialogs that use `Spacer` should
   set `resizeToAvoidBottomInset: false` to avoid keyboard overflow.

## Architecture conventions

- State management: Riverpod. Feature state lives in
  `lib/features/<feature>/providers/`. Shared providers in
  `lib/core/providers/`.
- Navigation: `go_router`. The three primary destinations (Home, History,
  Settings) live in a `StatefulShellRoute` with a persistent bottom
  `NavigationBar` (`lib/app/main_shell.dart`). Full-screen flows (focus setup,
  active timer, app selection) are top-level routes pushed above the shell.
- Local storage: SQLite via `sqflite` (`lib/core/database/app_database.dart`).
  Native session state uses `SharedPreferences` via `SessionStateManager.kt`.
- Flutter <-> Kotlin bridge: a single `MethodChannel`
  (`com.refocusagain.app/bridge`). Dart side: `NativeBridgeService`. Kotlin
  side: `RefocusNativeBridge`. Keep method names in sync on both sides.

## UI and theme

- All colors come from `AppColors` in `lib/app/theme.dart`. Do not hardcode hex
  colors in widgets; add a named color if needed.
- Native XML colors live in `res/values/colors.xml` and must be kept visually in
  sync with `AppColors`.
- The brand mark is the vector `AppLogo` widget (`lib/app/app_logo.dart`). The
  SVG source and PNG/launcher generator live in `assets/branding/`.
- Respect system insets: use `SafeArea` and `MediaQuery.viewPaddingOf` so
  content clears both gesture and 3-button navigation bars. The app runs
  edge-to-edge (see `main.dart`).
- Prefer `Color.withValues(alpha: ...)` over the deprecated `withOpacity`.

## Native blocking

- Detection is hybrid: accessibility events plus a foreground watchdog poll in
  `FocusBlockerService` so apps already resident in the background are blocked
  when switched to. Do not remove the watchdog.
- The ongoing notification and the home-screen widget both use a system
  Chronometer count-down so they tick without per-second CPU wakeups.

## Build, run, and verify

- Install dependencies: `flutter pub get`
- Analyze: `flutter analyze`
- Test: `flutter test`
- Debug build: `flutter build apk --debug`
- Regenerate the launcher icon after changing the logo:
  `python assets/branding/render_logo.py` then `dart run flutter_launcher_icons`

Always run `flutter analyze` and `flutter build apk --debug` before considering a
change complete. Add or update tests for new behavior.

## Do not

- Do not commit secrets or add cloud dependencies.
- Do not weaken the system-package safety list.
- Do not introduce emojis or em/en dashes.

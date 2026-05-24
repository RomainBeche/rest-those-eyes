# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test

Use the Xcode MCP tools — they are always preferred over running `xcodebuild` on the command line.

- **Build**: `BuildProject`
- **Run all tests**: `RunAllTests`
- **Run a single test**: `RunSomeTests` with the test identifier
- **Check for compiler issues quickly**: `XcodeRefreshCodeIssuesInFile` on the changed file
- **Inspect build errors**: `GetBuildLog`

Tests use the Swift Testing framework (`@Test`, `#expect`). The test target is `RestThoseEyesTests`.

## Architecture

RestThoseEyes is a **macOS-only menu bar app** (no iOS target). It has two scenes:

- **`MenuBarExtra`** — the popover shown when clicking the menu bar icon. Hosts `MenuView`.
- **`Settings`** — the standard macOS Settings window. Hosts `SettingsView`.

### Shared state

All observable state uses `@MainActor @Observable` classes injected via SwiftUI's `.environment()` / `@Environment(Type.self)`:

| Class | Owns | Singleton? |
|---|---|---|
| `SettingsManager` | All user preferences, persisted to `UserDefaults` | Yes (`SettingsManager.shared`) |
| `TimerManager` | The work/break state machine, session stats | No (owned by `RestThoseEyesApp`) |
| `CircularProgressionBarViewModel` | A single countdown timer driving one progress ring | No (created and replaced by `TimerManager`) |

`RestThoseEyesApp` creates both singletons and injects them. Views that need bindings (e.g. `Stepper`, `Toggle`) declare `@Bindable var x = x` at the top of `body` to derive `$x.property`.

### Timer state machine

`TimerManager` drives phase transitions. It creates a new `CircularProgressionBarViewModel` for every phase (work → break → work …). Communication from the VM back up to the manager uses two `@ObservationIgnored` callbacks set by `TimerManager.setupTimerLoop()`:

- `onTick` — called every second to update `currentPhaseElapsed`
- `onCompletion` — called when the countdown reaches zero; triggers stats save and phase switch

`CircularProgressionBarViewModel` uses a Foundation `Timer` (not Swift Concurrency) because it needs `RunLoop` integration for reliable 1-second ticks with tolerance. The timer closure hops to `@MainActor` via `Task { @MainActor in }`.

### Settings window workaround

`SettingsWindowView` (an `NSView` subclass inside `WindowConfigurator: NSViewRepresentable`) is a deliberate AppKit workaround. It uses `viewDidMoveToWindow()` to configure the window's title bar and lock the `NavigationSplitView` sidebar at a fixed width after the SwiftUI layout pass completes. There is no SwiftUI-only way to achieve this.

### Notifications

`NotificationDelegate` holds a weak reference to `TimerManager` and handles the "Snooze" notification action. It is set as the `UNUserNotificationCenter` delegate in `RestThoseEyesApp.init()`. Notification categories are also registered there synchronously; the authorization request runs asynchronously in a `.task` modifier.

## Localization

The app supports **English and French**. `Localizable.xcstrings` is the string catalog.

There are two coexisting localization patterns — both are intentional:

1. **Manual-keyed strings** (reverse-DNS keys like `timer.work_message`): accessed via the `Localization` enum hierarchy in `LocalizationStructure.swift` using `NSLocalizedString`. Format strings use `%d`/`%lld` placeholders (e.g. `formattedWorkMessage(minutes:)`).

2. **Auto-extracted strings** (plain English keys like `"Work interval:"`): used directly as string literals in SwiftUI views and picked up by Xcode's automatic extraction.

When adding new user-facing strings, prefer the manual-keyed approach for strings with format arguments; use plain literals for static labels. Always add both English and French translations to the catalog.

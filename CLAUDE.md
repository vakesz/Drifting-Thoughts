# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**CORE PHILOSOPHY: Keep the codebase SIMPLE. Avoid over-engineering, unnecessary abstractions, and complex patterns.**

## Project Overview

**Drifting Thoughts** — iOS 18+ minimalist micro-journaling and poetry app

- **Tech Stack**: Swift 6, SwiftUI, SwiftData, strict concurrency, XcodeGen
- **Architecture**: Direct SwiftData access, no repository/service layer
- **Platforms**: iOS 26+ (iPhone only)
- **Goal**: Fully on-device, no backend, no accounts, no external dependencies

## Commands

```bash
# Prerequisites
brew install xcodegen xcbeautify swiftlint

# Common commands
make help              # Show all commands
make build             # Generate + build (Debug)
make build-release     # Generate + build (Release)
make format-lint       # Format + lint (run before commits)
make generate          # Regenerate project (after project.yml changes)
make open              # Open Xcode project
make clean             # Clean build artifacts
make clean-all         # Full clean including generated project

# For VS Code/Neovim LSP support
brew install xcode-build-server
make generate-sourcekit
```

No test target exists. No external package dependencies.

## Swift 6 Patterns (REQUIRED)

| Modern (Use) | Legacy (Never) |
|--------------|----------------|
| `@Observable` | `ObservableObject`, `@Published` |
| `@Bindable` | `@ObservedObject`, `@StateObject` |
| `async/await` | `DispatchQueue`, completion handlers |

**NO COMBINE** — Never use `import Combine`, `@Published`, `AnyCancellable`, or `sink`. Enforced by SwiftLint custom rule.

## Architecture

### Data Flow

```
View → ViewModel → SwiftData (ModelContext)
 ↑
 @Query (direct model binding)
```

**NEVER add:** Repository layers, service layers, API clients, caching abstractions. Views use `@Query` directly for reading and `ModelContext` for writes.

### Settings (Global Singleton)

`AppSettings.shared` — `@Observable` with manual `UserDefaults` via `didSet`. Private init.

### UserDefaults Keys

All keys use the `drift.` prefix with dot-separated `camelCase`:

```
drift.<module>.<property>
```

| Pattern | Example |
|---------|---------|
| Compose | `drift.compose.autoKeyboard` |
| Cards | `drift.cards.showWatermark` |
| Profile | `drift.profile.authorName`, `drift.profile.showAuthor`, `drift.profile.didOnboard` |

### Feature Module Structure

```
Features/Compose/
├── ComposeView.swift          # @State private var viewModel
└── ComposeViewModel.swift     # @MainActor @Observable final class
```

### ViewModel Pattern

```swift
// Declaration order: @MainActor then @Observable (SwiftLint enforces attribute placement)
@MainActor
@Observable
final class ComposeViewModel {
    var title: String = ""
    var text: String = ""

    // No stored singletons — access AppSettings.shared directly in methods
}
```

**View usage:** `@State private var viewModel = SomeViewModel()` — ViewModels are owned by views via `@State`.

### Theme System

- `CardStyle` (midnight/parchment/sunset) — MeshGradient backgrounds
- `CardFontStyle` (serif/rounded/monospaced/classic) — typography
- `CardThemeOverrides` — per-thought customizations stored as JSON in the `Thought` model
- `CardThemeResolver` — merges style defaults with overrides into `ResolvedCardTheme`

### Design System

- **Layout constants**: `DriftLayout.spacingXS/SM/MD/LG/XL`, `DriftLayout.cornerRadiusSM/LG`, `DriftLayout.cardAspectRatio`
- **Character limits**: `DriftLayout.maxCharacterCount` (500), `DriftLayout.maxTitleCount` (50), `DriftLayout.maxAuthorNameCount` (50)
- **Colors**: `Color.brandAccent`, `Color.backgroundPrimary`, `Color.textPrimary`, `Color.textSecondary`, `Color.textPlaceholder`, `Color.cardShadow` — all from asset catalog

## Code Style

### Logging

Never use `print()`, `debugPrint()`, or `NSLog()` — SwiftLint warns. Use `os.Logger` instead.

### Code Quality

Run `make format-lint` before commits. Key rules:
- **ERROR** on `force_cast` / `force_try`
- **WARNING** on `force_unwrapping`
- Line limit: 150 warning, 200 error
- **Trailing commas mandatory** in multi-line collections
- **Sorted imports** enforced

**Attribute placement** (SwiftLint enforced):
- Same line: `@Environment`, `@State`, `@Binding`, `@Bindable`, `@Query`
- Line above: `@MainActor`, `@Observable`, `@Sendable`, `@ViewBuilder`, `@discardableResult`, `@available`, `@ObservationIgnored`

## Directory Structure

```
App/              # Entry point (SwiftData container, root TabView, onboarding gate)
Core/             # Shared infrastructure
├── DesignSystem/ # Color extensions, layout constants (DriftLayout)
├── Models/       # Thought (@Model), CardStyle, CardThemeOverrides, CardFontStyle
└── Settings/     # AppSettings singleton
Features/         # Feature modules (View + ViewModel per feature)
├── Compose/      # Text input with character limits
├── CardPreview/  # Card rendering, styling, sharing (ImageRenderer export)
├── Timeline/     # Thought list, search, favorites, streak tracking
├── Settings/     # User preferences
└── Onboarding/   # First-run profile setup
Resources/        # Asset catalog
Supporting/       # Generated Info.plist
```

## Project Configuration

### XcodeGen (project.yml)

All config in `project.yml` — never edit `.xcodeproj` directly. After changes, run `make generate`.

Key settings: Swift 6.0, iOS 26.0 deployment target, strict concurrency (`complete`), warnings as errors.

## Critical Rules

1. **Run `make format-lint` before every commit**
2. **No Combine** — use async/await and @Observable
3. **No print** — use os.Logger
4. **After `project.yml` changes**: Run `make generate`
5. **No repository/service layers** — keep data access direct via SwiftData
6. **No external dependencies** — use only Apple frameworks

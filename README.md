# Drifting Thoughts

![Platform](https://img.shields.io/badge/iOS-18.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-6.0-orange)
![Xcode](https://img.shields.io/badge/Xcode-16%2B-147EFB)
![SwiftLint](https://img.shields.io/badge/SwiftLint-Enabled-yellow)

A minimalist micro-journal and poetry app. Write a small thought, style it as a beautiful card, share it anywhere. No accounts, no backend, no friction — everything stays on-device.

*"Let your words drift"*

## Quick Start

```bash
# Prerequisites
brew install xcodegen xcbeautify swiftlint

make generate && make open   # Xcode
make generate-sourcekit      # VS Code, Neovim, etc.
```

## Architecture

### Data Flow

```text
View → ViewModel → SwiftData (local only)
```

No repositories, no API services, no caching layers. SwiftData is the single source of truth.

### Project Structure

```text
├── App/                    # SwiftUI App entry point
├── Core/                   # Shared infrastructure
│   ├── DesignSystem/          # Colors, spacing constants, reusable UI components
│   ├── Models/                # SwiftData models (Thought, Mood, CardStyle)
│   └── Settings/              # AppSettings (UserDefaults singleton)
├── Features/               # Feature modules
│   ├── Compose/               # Text input, auto-detected tags
│   ├── CardPreview/           # Styled card preview, style picker, share
│   ├── Timeline/              # Browse past thoughts, search, favorites
│   └── Settings/              # User preferences, about
├── Resources/              # Asset catalog
└── Supporting/             # Generated Info.plist
```

## Development

### Requirements

- **Xcode 16+** (iOS 18 SDK)
- **iOS 18.0+** minimum deployment target
- **Homebrew packages**: `xcodegen`, `xcbeautify`, `swiftlint`

### Makefile Commands

```bash
# Build & Project
make open               # Open the Xcode project
make generate           # Generate Xcode project using XcodeGen
make generate-sourcekit # Generate SourceKit-LSP configuration
make check-sourcekit    # Check if SourceKit-LSP configuration is valid
make build              # Generate + build (Debug)
make build-release      # Generate + build (Release)
make clean              # Clean build artifacts (keeps .xcodeproj)
make clean-all          # Full clean including generated project

# Code Quality
make lint               # Run SwiftLint (check only)
make format             # Auto-fix Swift code with SwiftLint --fix
make format-lint        # Format code then run SwiftLint
```

Project configuration is defined in `project.yml` using XcodeGen.

### Editor Setup (SourceKit-LSP)

For editors that use SourceKit-LSP (VS Code, Neovim, Cursor, etc.):

```bash
brew install xcode-build-server
make generate-sourcekit
```

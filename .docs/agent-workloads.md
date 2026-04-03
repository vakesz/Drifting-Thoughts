# Agent Workloads

## Start Here

- Read [CLAUDE.md](../CLAUDE.md) first. It contains all architecture, rules, and commands.
- Run `make build` to validate changes. Do not trust LSP diagnostics.
- Run `make format-lint` before every commit.

## Task Routing

| Task | What to do |
| ---- | ---------- |
| Add a new feature | Create `Features/<Name>/<Name>View.swift`. Add a ViewModel only if the view has write logic or complex state. Register in `ContentView` if it needs a tab. |
| Add a new setting | Add property to `AppSettings` with `didSet` persisting to `UserDefaults` using `drift.<module>.<property>` key. Initialize from `UserDefaults` in `private init()`. |
| Add a new card style | Add case to `CardStyle` enum. Add matching color assets (`<Name>GradientStart`, `<Name>GradientEnd`, `<Name>Text`) in `Assets.xcassets`. |
| Add a new card font | Add case to `CardFontStyle` enum with matching `Font.Design`. |
| Change the data model | Edit `Thought` in `Core/Models/Thought.swift`. SwiftData handles lightweight migrations automatically. |
| Add a shared UI component | Place in `Core/DesignSystem/`. Use `DriftLayout` constants for spacing and sizing. |
| Change project config | Edit `project.yml`, then run `make generate`. Never edit `.xcodeproj` directly. |
| Fix a lint error | Run `make format` to auto-fix. If that doesn't resolve it, fix manually, then run `make lint` to verify. |
| Add localized strings | Use `String(localized:)` in code. Strings are managed via `Supporting/Localizable.xcstrings`. |
| Export/share a card | Follow the pattern in `CardDetailViewModel.makeShareURL()` using `ImageRenderer`. |

## Fast Reminders

- `make format-lint` before every commit
- `make build` to validate, not LSP
- No Combine, no print, no force_cast, no force_try
- No external dependencies
- No repository/service/API layers
- `@Observable` not `ObservableObject`; `@Bindable` not `@ObservedObject`
- `@Query` for reads, `ModelContext` for writes
- `AppSettings.shared` accessed directly, never injected
- Imports must be sorted alphabetically
- Trailing commas mandatory in multi-line collections
- `@State`/`@Binding`/`@Environment`/`@Query` on same line as declaration
- `@MainActor`/`@Observable`/`@ViewBuilder` on line above declaration
- Commit messages: imperative mood, sentence-case, no prefixes, no Co-Authored-By
- Warnings are errors in both GCC and Swift compiler settings

## Verification Shortcuts

| Change type | Verify with |
| ----------- | ----------- |
| Any Swift code change | `make build` |
| Before committing | `make format-lint` |
| After editing `project.yml` | `make generate && make build` |
| Style/lint questions | `make lint` |
| Full clean rebuild | `make clean-all && make build` |
| LSP not working | `make generate-sourcekit` |

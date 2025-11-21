# iOS General Rules — 20.11.25

These guidelines apply to all of our iOS repositories. Project-specific rules (such as Hat Game’s DesignBook requirements) are documented alongside the repo.

## Code Style
- Define views using `struct SomeView: View { var body: some View { ... } }`.
- Prefer computed properties/extensions for subviews and helpers to keep the main body small.
- Remove `return` when a single expression is sufficient (including control-flow expressions).
- Keep imports sorted.
- Never add extra blank lines at the end of files; each file must end exactly on its last character (no trailing newline).
- Use the current date in file headers for newly created source files; never edit headers on existing files.
- Localization keys must use camelCase or dot.notation (e.g., `wordInput.title`, not `word_input.title`).
- Add MARK comments for file-level extensions (e.g., `// MARK: - Private` before `private extension SomeView`).

## SwiftUI Patterns
- Use the Observation framework instead of `ObservableObject`.
- Inject dependencies via `@Environment`.
- Use `@State` for local state and `@Binding` for two-way communication.
- Prefer reusable view modifiers for repeated styling (e.g., `setDefaultBackground()`).
- Extract shared UI into components and leverage `@ViewBuilder`-based generics when helpful.

## Data Models
- Declare immutable properties (`let`) for data that should not change after initialization (e.g., IDs, names, colors).
- Keep models focused on data; track runtime state inside managers rather than models.
- Conform to `Hashable` whenever models need to be used in sets or dictionary keys.

## Architecture
- Use the `@Observable` macro for app-level managers.
- Keep business logic inside dedicated manager types (e.g., a `GameManager`), and keep configuration in separate objects (such as `AppConfiguration`/`GameConfiguration` pairs).
- Prefer dictionary-based tracking for aggregated state (`[Team: [Word]]`, etc.) when it simplifies lookups.
- Implement navigation through a central navigator/route enum pattern to maintain a single source of truth for flows.

## Git
- Commit using the `khizanag@gmail.com` identity.
- Write descriptive commit messages that explain the “why,” not just the “what.”

## Testing & Tooling
- Use configuration objects (such as `AppConfiguration`) to enable test modes or pre-filled data when appropriate.
- Ensure new behavior is testable; prefer dependency injection for anything that otherwise requires global state.
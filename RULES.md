## HatGame Working Rules

Keep this file up-to-date—add any new conventions, UX decisions, or tooling notes as they come up so future tasks can reference a single source of truth.

### Coding Conventions
- Prefer `struct SomeView: View { ... }` over adding the conformance in an extension.
- When a view body can omit `return`, do so (SwiftUI single-expression style).
- Use the Observation framework (`@Observable`, `@Environment`) instead of `ObservableObject`.
- Move complex view sub-components into private computed properties/extensions to keep bodies short.
- Keep imports sorted alphabetically.
- Add appropriate MARK comments to file-level extensions (e.g., `// MARK: - Private`).

### Styling
- Use the `DesignBook` tokens for all colors, fonts, spacing, sizes, etc. Do **not** introduce ad-hoc values. If a new design value is required, add it to `DesignBook` with a generic, reusable name (e.g., `Color.Text.Status.error`).
- Avoid trailing empty lines at the ends of files and extra blank lines elsewhere.

### UI Composition
- Default background should use `DesignBook.Color.Background.primary` with `.ignoresSafeArea()` when a full-screen experience is intended.
- Extract reusable card/button patterns into dedicated views (e.g., `GameCard`, `PrimaryButton`, `SecondaryButton`) and keep them consistent across screens.
- When presenting sheets or alerts, centralize bindings and builder logic in private helpers for readability.

### Navigation & Flow
- Use `Navigator` helpers (`push`, `dismiss`, etc.) consistently; avoid manual `NavigationPath` mutations outside that type.
- For modal flows (like team editing/add player), prefer `sheet(isPresented:)` with computed bindings to keep state handling in one place.

### Testing & Misc
- When changing gameplay logic (scores, timers, rounds), verify that `GameManager` state transitions remain valid and update previews where helpful.
- When in doubt about future reuse, document behavior in this file for quick recall.


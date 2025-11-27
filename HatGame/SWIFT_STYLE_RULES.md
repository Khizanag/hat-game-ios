# Swift Style Rules

This document defines the Swift coding style conventions for the Hat Game project.

> **Note:** This file is automatically updated whenever new style conventions or technical suggestions are adopted. Each rule includes rationale and examples to help maintain consistent code quality.

## Optional Handling

### Use Optional Chaining for Optional Closures

When calling an optional closure or function, use optional chaining instead of if-let unwrapping.

**Preferred:**
```swift
content?()
onComplete?()
closure?()
```

**Not Preferred:**
```swift
if let content {
    content()
}

if let onComplete {
    onComplete()
}
```

**Rationale:** Optional chaining is more concise and clearly expresses the intent. It eliminates unnecessary unwrapping when you just want to call the optional if it exists.

**Example:**
```swift
struct CustomButton: View {
    let action: (() -> Void)?

    var body: some View {
        Button("Tap") {
            action?()  // Clean and clear
        }
    }
}
```

**Note:** This applies specifically to optional closures/functions where you're just calling them. If you need to use the unwrapped value for other operations, use if-let:
```swift
// Still use if-let when you need the unwrapped value
if let user = currentUser {
    print("Name: \(user.name)")
    updateUI(for: user)
}
```

## Conditional Statements

### Use Comma-Separated Conditions

**Preferred:**
```swift
if condition1, condition2 {
    // code
}

guard condition1, condition2 else {
    return
}

while condition1, condition2 {
    // code
}
```

**Not Preferred:**
```swift
if condition1 && condition2 {
    // code
}

guard condition1 && condition2 else {
    return
}

while condition1 && condition2 {
    // code
}
```

**Rationale:** Using comma-separated conditions is more idiomatic Swift and provides better readability. It also allows for optional binding and pattern matching in the same statement.

**Example:**
```swift
// Good
if let user = currentUser, user.isActive {
    print("Active user: \(user.name)")
}

// Not preferred
if let user = currentUser && user.isActive {  // This won't even compile
    print("Active user: \(user.name)")
}
```

**Note:** For boolean expressions in return statements or assignments, continue to use `&&` and `||`:
```swift
return !trimmedName.isEmpty && playerCount > 0  // Correct
let isValid = name.isEmpty && age > 18          // Correct
```

### Use Positive Logic in Conditionals

When writing if-else statements, prefer positive conditions over negated ones for better readability.

**Preferred:**
```swift
if hasConfirmedPlayerCount {
    showPlayerCountSummary()
    showTeamsList()
} else {
    showPlayerCountSelection()
}

if isValid {
    processData()
} else {
    showError()
}
```

**Not Preferred:**
```swift
if !hasConfirmedPlayerCount {
    showPlayerCountSelection()
} else {
    showPlayerCountSummary()
    showTeamsList()
}

if !isValid {
    showError()
} else {
    processData()
}
```

**Rationale:** Positive logic is easier to understand and reduces cognitive load. Reading "if something is true, do X, otherwise do Y" is more natural than "if something is not true, do Y, otherwise do X."

**Example:**
```swift
// Good - positive logic flows naturally
if user.isAuthenticated {
    showDashboard()
} else {
    showLoginScreen()
}

// Not preferred - negation makes it harder to follow
if !user.isAuthenticated {
    showLoginScreen()
} else {
    showDashboard()
}
```

**Note:** This rule applies specifically to if-else statements. For simple guard statements or single-branch conditions, negative logic may still be appropriate:
```swift
guard !name.isEmpty else { return }  // Fine for guard with early return
if items.isEmpty { showEmptyState() }  // Fine for single-branch condition
```

## Additional Style Guidelines

### Naming Conventions
- Use `lowerCamelCase` for variables, functions, and properties
- Use `UpperCamelCase` for types and protocols
- Use descriptive names that clearly indicate purpose

### Spacing
- Use 4 spaces for indentation (no tabs)
- Add blank lines to separate logical sections
- No trailing whitespace

### SwiftUI Specifics
- Use DesignBook constants for all sizing, spacing, colors, and opacities
- Create reusable components for repeated UI patterns
- Prefer computed properties over functions for simple view builders

### General Principles
- Favor clarity over brevity
- Avoid nested ternary operators
- Use guard statements for early returns
- Keep functions focused and single-purpose

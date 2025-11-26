# Swift Style Rules

This document defines the Swift coding style conventions for the Hat Game project.

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

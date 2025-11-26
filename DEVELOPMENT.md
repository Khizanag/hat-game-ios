# Development Guide

> **Last Updated:** 2025-11-26
>
> This document contains all technical details, code style guidelines, and development practices for the Hat Game iOS project. It is updated regularly to reflect the latest decisions and conventions.

## Table of Contents

- [Technical Stack](#technical-stack)
- [Project Architecture](#project-architecture)
- [Code Style Guidelines](#code-style-guidelines)
- [Testing Infrastructure](#testing-infrastructure)
- [State Management](#state-management)
- [Navigation](#navigation)
- [Design System](#design-system)
- [Localization](#localization)
- [Git Workflow](#git-workflow)
- [Common Patterns](#common-patterns)
- [Development Rules](#development-rules)

---

## Technical Stack

### Requirements
- **iOS:** 15.0+
- **Swift:** 5.9+
- **Xcode:** 15.0+
- **Framework:** SwiftUI (pure implementation, no external dependencies)

### Key Technologies
- **SwiftUI:** Modern declarative UI framework
- **Observation Framework:** `@Observable` macro for state management (NOT `@ObservableObject`)
- **UserDefaults:** Settings persistence
- **Swift Concurrency:** async/await for asynchronous operations
- **Combine:** Minimal usage for specific reactive scenarios

---

## Project Architecture

### MVVM Pattern
- **Views:** SwiftUI views that observe state changes
- **Managers:** Business logic and state management using `@Observable`
- **Models:** Pure data structures (Team, Player, Word, GameRound)

### Directory Structure

```
HatGame/
├── Configuration/        # App-wide configuration
├── Managers/            # Business logic (@Observable classes)
├── Model/               # Data models (structs/enums)
├── View/                # SwiftUI views
│   ├── Home/
│   ├── Setup/
│   ├── Play/
│   ├── Settings/
│   ├── Developer/
│   └── Component/       # Reusable UI components
├── Navigation/          # Navigation logic
├── DesignBook/          # Design system
├── Extensions/          # Swift extensions
├── Localization/        # String resources
└── Assets.xcassets/     # Images and colors
```

### Key Components

#### GameManager
**Purpose:** Core game state and flow management

**Responsibilities:**
- Game configuration and initialization
- Team rotation logic
- Word management (remaining words, current word)
- Time tracking per team
- Round progression
- Integration with HistoryManager

**Key Features:**
- Test mode support: Auto-loads mock configuration when `AppConfiguration.shared.isTestMode` is enabled
- Time preservation: Saves and restores team remaining time across rounds
- Proper cleanup when rounds transition

#### HistoryManager
**Purpose:** Score tracking and statistics

**Responsibilities:**
- Track guessed words per team per round
- Calculate scores and rankings
- Maintain round-by-round history

#### Navigator
**Purpose:** Centralized navigation management

**Pattern:** Page-based routing with type-safe navigation
- Uses `NavigationStack` with path binding
- Supports both push and full-screen presentation
- Publisher-based dismiss mechanism

#### DesignBook
**Purpose:** Centralized design system

**Contains:**
- Colors (Text, Background, Status)
- Typography (Font styles)
- Spacing (Consistent padding/margins)
- Sizes (Component dimensions)
- Shadows (Elevation system)
- Opacity (Disabled states, overlays)

---

## Code Style Guidelines

### Swift Style

#### 1. Naming Conventions

**Variables:** camelCase
```swift
var currentTeamIndex: Int
var remainingWords: Set<Word>
var teamRemainingTimes: [UUID: Int]
```

**Types:** PascalCase
```swift
struct Team
class GameManager
enum GameRound
```

**Functions:** Descriptive verb phrases
```swift
func prepareForNewPlay()
func saveRemainingTime(_ seconds: Int, for team: Team)
func commitWordGuess()
```

**Booleans:** Use "is", "has", "should" prefixes
```swift
var isGameFinished: Bool
var hasRemainingTime: Bool
var shouldResetTeams: Bool
```

#### 2. MARK Comments

Organize code sections with MARK comments:
```swift
// MARK: - Properties
// MARK: - Initialization
// MARK: - Lifecycle
// MARK: - Actions
// MARK: - Private
```

#### 3. Explicit Result Handling

Always use `_ =` when intentionally discarding return values:
```swift
// Good
_ = withAnimation(.spring()) {
    playerWords.remove(at: index)
}

// Avoid (causes warnings)
withAnimation(.spring()) {
    playerWords.remove(at: index)
}
```

#### 4. Optional Handling

Avoid force unwrapping (`!`) unless absolutely necessary:
```swift
// Good
guard let currentWord = gameManager.currentWord else { return }

// Avoid
let word = gameManager.currentWord!
```

#### 5. Code Comments

**Why, not what:** Explain reasoning, not obvious actions
```swift
// Good: Explains reasoning
// Only save time if round is ending to prevent 0-second starts
if gameManager.currentWord == nil && remainingSeconds > 0 {
    gameManager.saveRemainingTime(remainingSeconds, for: team)
}

// Avoid: States the obvious
// Save remaining time
gameManager.saveRemainingTime(remainingSeconds, for: team)
```

**TODOs:** Mark incomplete work clearly
```swift
// TODO: Implement final results animation
func finishGame() {
    // Implementation pending
}
```

### SwiftUI Specific

#### 1. View Composition

Extract complex views into computed properties:
```swift
var body: some View {
    VStack {
        headerView
        contentView
        footerView
    }
}

var headerView: some View {
    // Complex header implementation
}
```

#### 2. View Size Limits

- Keep views under **200 lines**
- Extract reusable components to `View/Component/`
- Break down large views into smaller, focused views

#### 3. DesignBook Usage

**Always use DesignBook** for design tokens:
```swift
// Good
.padding(DesignBook.Spacing.md)
.foregroundColor(DesignBook.Color.Text.primary)
.font(DesignBook.Font.headline)

// Avoid
.padding(16)
.foregroundColor(.black)
.font(.system(size: 17, weight: .semibold))
```

#### 4. Animations

Use `withAnimation` with explicit discard when needed:
```swift
_ = withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
    playerWords.append(trimmedWord)
}
```

---

## Testing Infrastructure

### Test Mode

**Purpose:** Quick setup for testing game flow without manual data entry

**How to Enable:**
1. Go to Settings → Developer Info
2. Toggle "Test Mode" ON
3. Start new game → Teams and words are pre-configured

**Implementation:**
- `GameManager` checks `AppConfiguration.shared.isTestMode` on initialization
- When enabled, uses `GameConfiguration.mockForTesting`
- Mock includes 2 pre-configured teams with players and test words

### Word Database

**File:** `Managers/WordDatabase.swift`

**Contents:** 200 sorted Georgian words for testing and quick-fill

**Usage:**
```swift
// Get random subset
let words = WordDatabase.randomWords(count: 10)

// Get all words shuffled
let allWords = WordDatabase.allWordsShuffled()
```

**Auto-Fill Feature:**
- Available in WordInputView
- One-click button to fill remaining words
- Uses random words from database
- Respects "Allow Duplicate Words" setting

**Duplicate Words Setting:**
- Located in Settings → Defaults → Allow Duplicate Words
- Default: **Disabled** (ensures unique words per game)
- When **Disabled:**
  - Auto-fill gives each player unique words
  - Tracks all used words across all players in the game
  - Prevents duplicate words between players
- When **Enabled:**
  - Auto-fill can give the same words to different players
  - Only prevents duplicates within the same player's list
  - Useful when word database is small relative to game size

**Implementation Details:**
- `AppConfiguration.allowDuplicateWords` - User preference
- `GameManager.getAllUsedWords()` - Returns all words added by all players
- Auto-fill logic filters based on setting and used words

---

## State Management

### Observation Framework

**Use `@Observable` macro** for all managers and view models:
```swift
@Observable
final class GameManager {
    var configuration: GameConfiguration
    var currentRound: GameRound?
    // ...
}
```

**NOT `@ObservableObject`** - we use the modern Observation framework

### View State

**Local State:** `@State`
```swift
@State private var currentWord: String = ""
@State private var isExpanded: Bool = false
```

**Environment:** `@Environment`
```swift
@Environment(GameManager.self) private var gameManager
@Environment(Navigator.self) private var navigator
```

**Focus State:** `@FocusState`
```swift
@FocusState private var isWordFieldFocused: Bool
```

### State Ownership

- Views own their **local UI state** (`@State`)
- Managers own **business state** (`@Observable`)
- No global mutable state
- Pass dependencies through `@Environment`

---

## Navigation

### Page Enum

All screens defined in `Page` enum:
```swift
enum Page: Hashable {
    case home
    case teamSetup
    case wordInput
    case play(round: GameRound)
    case nextTeam(round: GameRound, team: Team)
    // ...
}
```

### Navigator Class

Centralized navigation management:
```swift
@Environment(Navigator.self) private var navigator

// Push to navigation stack
navigator.push(.wordInput)

// Full-screen presentation
navigator.present(.teamSetup)

// Dismiss
navigator.dismiss()
```

### Navigation Hierarchy

```
Home (NavigationView root)
├── Settings
│   ├── App Icon Selection
│   └── Defaults Settings
├── Developer Info
└── Team Setup (full-screen)
    ├── Word Settings
    ├── Timer Settings
    ├── Word Input
    ├── Randomization
    └── Game Flow
        ├── Play (round)
        ├── Team Turn Results
        ├── Next Team
        └── Final Results
```

---

## Design System

### DesignBook Structure

All design tokens centralized in `DesignBook`:

#### Colors
```swift
DesignBook.Color.Text.primary      // Main text
DesignBook.Color.Text.secondary    // Supporting text
DesignBook.Color.Text.tertiary     // Subtle text
DesignBook.Color.Text.accent       // Brand accent

DesignBook.Color.Background.primary
DesignBook.Color.Background.secondary

DesignBook.Color.Status.success
DesignBook.Color.Status.error
DesignBook.Color.Status.warning
```

#### Typography
```swift
DesignBook.Font.largeTitle
DesignBook.Font.title
DesignBook.Font.title2
DesignBook.Font.title3
DesignBook.Font.headline
DesignBook.Font.body
DesignBook.Font.bodyBold
DesignBook.Font.caption
```

#### Spacing
```swift
DesignBook.Spacing.xs    // 4pt
DesignBook.Spacing.sm    // 8pt
DesignBook.Spacing.md    // 16pt
DesignBook.Spacing.lg    // 24pt
DesignBook.Spacing.xl    // 32pt
DesignBook.Spacing.xxl   // 48pt
```

#### Component Sizes
```swift
DesignBook.Size.cardCornerRadius
DesignBook.Size.smallCardCornerRadius
DesignBook.Size.badgeSize
DesignBook.Size.floatingButtonSize
```

### Custom Components

Located in `View/Component/`:

#### Buttons
- `PrimaryButton`: Main action button
- `SecondaryButton`: Secondary actions
- `DestructiveButton`: Destructive actions (red)

#### Cards
- `GameCard`: Standard game content card
- `HeaderCard`: Card with title and description
- `FoldableCard`: Expandable/collapsible card
- `NavigationCard`: Card that leads to another screen

#### Other
- `SegmentedSelectionView`: Custom segmented control
- `LegendTag`: Small colored tag for legends

---

## Localization

### String Resources

**File:** `Localization/Localizable.xcstrings`

**Languages:**
- English (en) - primary
- Georgian (ka) - translated

### Adding New Strings

1. Add to `Localizable.xcstrings`:
```json
"key.name": {
  "comment": "Description of the string",
  "localizations": {
    "en": {
      "stringUnit": {
        "state": "translated",
        "value": "English Text"
      }
    },
    "ka": {
      "stringUnit": {
        "state": "translated",
        "value": "ქართული ტექსტი"
      }
    }
  }
}
```

2. Use in code:
```swift
Text("key.name")
// or
String(localized: "key.name")
```

### String Naming Convention

Use dot notation for hierarchy:
- `home.title`
- `wordInput.addWord`
- `game.turnResults.timeUp`
- `common.buttons.continue`

---

## Git Workflow

### Commit Messages

**Format:**
```
Short descriptive title (imperative mood)

- Bullet points describing changes
- Focus on what and why, not how
- Keep lines under 72 characters

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Examples:**
```
Add testing infrastructure and word auto-fill feature

Fix team rotation bug in prepareForNewPlay

Update README with comprehensive game rules
```

### Branch Naming

- `feature/*` - New features
- `bugfix/*` - Bug fixes
- `hotfix/*` - Critical production fixes
- `refactor/*` - Code refactoring

### Pull Requests

- Keep PRs focused and reviewable
- Include description of changes
- Reference related issues
- Ensure all tests pass

---

## Common Patterns

### Manager Initialization

Managers use `@Observable` and proper initialization:
```swift
@Observable
final class GameManager {
    var configuration: GameConfiguration

    init(configuration: GameConfiguration? = nil) {
        if let configuration {
            self.configuration = configuration
        } else if AppConfiguration.shared.isTestMode {
            self.configuration = GameConfiguration.mockForTesting
        } else {
            self.configuration = GameConfiguration()
        }
    }
}
```

### View Lifecycle

Common lifecycle patterns:
```swift
var body: some View {
    content
        .onAppear {
            // Setup when view appears
        }
        .onDisappear {
            // Cleanup when view disappears
        }
        .onChange(of: someValue) { oldValue, newValue in
            // React to changes
        }
}
```

### Error Handling

Prefer graceful degradation over crashes:
```swift
// Good
guard let currentWord = gameManager.currentWord else {
    print("Warning: No current word available")
    return
}

// Avoid
guard let currentWord = gameManager.currentWord else {
    fatalError("No current word")
}
```

### Async Operations

Use DispatchQueue for UI updates:
```swift
DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
    isWordFieldFocused = true
}
```

---

## Development Rules

### Core Principles

1. **SwiftUI First:** Use SwiftUI for all UI components
2. **No External Dependencies:** Keep the project dependency-free
3. **Type Safety:** Leverage Swift's type system
4. **Composition Over Inheritance:** Build complex views from simple components
5. **Single Responsibility:** Each component has one clear purpose

### Code Quality

1. **No Force Unwrapping:** Use proper optional handling
2. **No Magic Numbers:** Use DesignBook constants
3. **No Hardcoded Strings:** Use localization
4. **Explicit Typing:** Clear type annotations where helpful
5. **Meaningful Names:** Self-documenting code

### Performance

1. **Lazy Loading:** Use lazy initialization where appropriate
2. **View Optimization:** Keep view body computations light
3. **Avoid Premature Optimization:** Measure first, optimize second

### Testing

1. **Test Business Logic:** Unit tests for managers
2. **Test User Flows:** UI tests for critical paths
3. **Test Edge Cases:** Empty states, max values, errors

### Documentation

1. **Update This Document:** Keep DEVELOPMENT.md current
2. **Comment Complex Logic:** Explain non-obvious decisions
3. **Update README:** Keep user-facing docs accurate
4. **Use TODOs:** Mark incomplete work clearly

---

## Notes

**This document is a living guide.** It will be updated regularly to reflect:
- New architectural decisions
- Code style refinements
- Development best practices
- Lessons learned

**Review this document before:**
- Starting new features
- Making architectural changes
- Code reviews
- Onboarding new developers

**Last Major Update:** 2025-11-26 - Added unique words per game feature with duplicate words setting

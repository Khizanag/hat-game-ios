# Hat Game (iOS)

A fun and interactive party game for iOS built with SwiftUI. Players explain words to their teammates within a time limit across multiple rounds, making it perfect for gatherings and parties.

> **For Developers:** See [DEVELOPMENT.md](DEVELOPMENT.md) for comprehensive technical details, code style guidelines, and development practices.

## Table of Contents

- [Game Rules](#game-rules)
- [Features](#features)
- [Technical Overview](#technical-overview)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Development Guidelines](#development-guidelines)
- [Code Style Rules](#code-style-rules)
- [Architecture](#architecture)
- [Documentation](#documentation)

## Game Rules

### Setup Phase
1. **Create Teams**: Set up teams with 2 players each (configurable)
2. **Enter Words**: Each player enters N words (default: 10, configurable)
3. **Start Game**: Game begins with the first team

### Gameplay Flow

#### Playing a Turn
1. One player from the active team explains words
2. Another player from the same team guesses
3. When a word is guessed correctly, it's marked and a new word appears
4. Each turn has a timer (default: 60 seconds, configurable)
5. Timer runs out or player gives up → turn ends

#### Team Rotation
- After each turn, the next team plays
- Teams continue rotating until **all words are gone from the hat**
- When all words are guessed, the round is complete

#### Round System
There are **3 rounds** in total:

**Round 1**: Explain words freely (any description allowed)

**Round 2**: Same words are re-added to the hat - different explanation style

**Round 3**: Same words again - final round

#### Special Rules
- **Time Preservation**: If a team gets the last word of a round with time remaining (e.g., 45 seconds left), that team starts the next round with the remaining time
- **Team Continuity**: The team that finishes a round continues into the next round (no team reset between rounds)
- **Normal Turns**: If a team's timer expires during a normal turn, they get the full duration on their next turn

### Winning
After all 3 rounds are complete, the team with the highest total score wins!

## Features

- Clean, modern SwiftUI interface
- Configurable game settings:
  - Words per player (default: 10)
  - Round duration (default: 60 seconds)
  - Number of teams and players
- Team customization with colors
- Real-time score tracking
- Round-by-round standings
- Pause/Resume functionality during gameplay
- Time preservation across rounds
- Multiple app icons (Classic, Minimal, Vintage, Neon, Sunset)
- Dark mode support
- Localization support
- History tracking for completed games

## Technical Overview

### Requirements
- **Platform**: iOS 15.0+
- **Language**: Swift 5.9+
- **Framework**: SwiftUI
- **Xcode**: 15.0+

### Dependencies
- No external dependencies (pure SwiftUI implementation)

### Key Technologies
- **SwiftUI**: Modern declarative UI framework
- **Observation Framework**: State management (@Observable)
- **UserDefaults**: Settings persistence
- **Combine**: Reactive programming (minimal usage)

## Project Structure

```
HatGame/
├── HatGame/
│   ├── HatGameApp.swift          # App entry point
│   ├── Configuration/            # App-wide configuration
│   │   ├── AppConfiguration.swift
│   │   ├── AppColorScheme.swift
│   │   └── AppIcon.swift
│   ├── Managers/                 # Business logic managers
│   │   ├── GameManager.swift     # Core game logic
│   │   ├── GameConfiguration.swift
│   │   ├── HistoryManager.swift
│   │   └── TeamDefaultColorGenerator.swift
│   ├── Model/                    # Data models
│   │   ├── Team.swift
│   │   ├── Player.swift
│   │   ├── Word.swift
│   │   └── GameRound.swift
│   ├── View/                     # UI components
│   │   ├── Home/                 # Home screen
│   │   ├── Setup/                # Game setup screens
│   │   ├── Play/                 # Gameplay screens
│   │   ├── Settings/             # Settings screens
│   │   ├── Developer/            # Developer info
│   │   └── Component/            # Reusable UI components
│   ├── Navigation/               # Navigation logic
│   │   ├── Navigator.swift
│   │   ├── NavigationView.swift
│   │   └── Page.swift
│   ├── DesignBook/               # Design system
│   │   ├── DesignBook.swift
│   │   ├── DesignBook+Color.swift
│   │   ├── DesignBook+Typography.swift
│   │   ├── DesignBook+Spacing.swift
│   │   ├── DesignBook+Size.swift
│   │   ├── DesignBook+Shadow.swift
│   │   └── DesignBook+Opacity.swift
│   ├── Extensions/               # Swift extensions
│   │   ├── View+Padding.swift
│   │   ├── View+Background.swift
│   │   ├── View+CloseButtonToolbar.swift
│   │   └── Color+Comparison.swift
│   ├── Localization/             # Localized strings
│   └── Assets.xcassets/          # Images and colors
├── HatGameTests/                 # Unit tests
└── HatGameUITests/               # UI tests
```

## Getting Started

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/hat-game-ios.git
cd hat-game-ios
```

2. Open the project:
```bash
open HatGame/HatGame.xcodeproj
```

3. Select your target device/simulator

4. Build and run (⌘R)

### First Run

1. Launch the app
2. Tap "New Game"
3. Set up your teams
4. Configure game settings (optional)
5. Enter words for each player
6. Start playing!

## Development Guidelines

### Core Principles

1. **SwiftUI First**: Use SwiftUI for all UI components
2. **Observation Framework**: Use `@Observable` for state management (not `@ObservableObject`)
3. **MVVM Pattern**: Separate business logic from views
4. **Composition**: Build complex views from smaller, reusable components
5. **Type Safety**: Leverage Swift's type system for safety

### State Management

- Use `@Observable` macro for managers and view models
- Use `@State` for view-local state
- Use `@Environment` to inject dependencies
- Avoid global mutable state

### Navigation

- Centralized navigation through `Navigator` class
- Page-based routing system
- Type-safe page definitions

## Code Style Rules

### General Guidelines

1. **Explicit Discarding**: Always use `_ =` when intentionally discarding return values
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

2. **No Force Unwrapping**: Avoid `!` unless absolutely necessary
   ```swift
   // Good
   guard let currentWord = gameManager.currentWord else { return }

   // Avoid
   let word = gameManager.currentWord!
   ```

3. **MARK Comments**: Use MARK comments to organize code
   ```swift
   // MARK: - Properties
   // MARK: - Lifecycle
   // MARK: - Actions
   // MARK: - Private
   ```

### SwiftUI Specific

1. **ViewBuilder**: Extract complex views into computed properties or functions
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

2. **Avoid Massive Views**: Keep views under 200 lines
3. **Extract Reusable Components**: Create components in `View/Component/`
4. **Use DesignBook**: All design tokens come from DesignBook
   ```swift
   // Good
   .padding(DesignBook.Spacing.md)
   .foregroundColor(DesignBook.Color.Text.primary)

   // Avoid
   .padding(16)
   .foregroundColor(.black)
   ```

### Manager Classes

1. **Single Responsibility**: Each manager handles one domain
2. **Observable**: All managers use `@Observable` macro
3. **Private by Default**: Expose only necessary public API
4. **Pure Functions**: Prefer pure functions for business logic

### Naming Conventions

1. **Variables**: camelCase
   ```swift
   var currentTeamIndex: Int
   var remainingWords: Set<Word>
   ```

2. **Types**: PascalCase
   ```swift
   struct Team
   class GameManager
   enum GameRound
   ```

3. **Functions**: Descriptive verb phrases
   ```swift
   func prepareForNewPlay()
   func saveRemainingTime(_ seconds: Int, for team: Team)
   func commitWordGuess()
   ```

4. **Booleans**: Use "is", "has", "should" prefixes
   ```swift
   var isGameFinished: Bool
   var hasRemainingTime: Bool
   var shouldResetTeams: Bool
   ```

### Comments

1. **Why, Not What**: Explain why, not what the code does
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

2. **TODOs**: Mark incomplete work
   ```swift
   // TODO: Implement final results screen
   func finishGame() {
       // Implementation pending
   }
   ```

### Testing

1. Write unit tests for business logic
2. Write UI tests for critical user flows
3. Test edge cases (empty states, max values, etc.)

### Git Workflow

1. **Descriptive Commits**: Clear, concise commit messages
   ```
   Add time preservation across rounds
   Fix team skipping bug in prepareForNewPlay
   Update README with game rules
   ```

2. **Branch Naming**: feature/*, bugfix/*, hotfix/*
3. **Small PRs**: Keep pull requests focused and reviewable

## Architecture

### Game Flow

```
Home → Team Setup → Word Input → Randomization → Game Play ↔ Results → Final Results
                                                      ↓
                                                  Next Team
                                                      ↓
                                                  Next Round
```

### Key Components

#### GameManager
- Core game state management
- Team rotation logic
- Word management
- Time tracking per team
- Round progression

#### HistoryManager
- Score tracking
- Round history
- Rankings calculation

#### Navigator
- Centralized navigation
- Page-based routing
- Type-safe navigation

#### DesignBook
- Centralized design system
- Colors, typography, spacing
- Consistent UI across app

## Documentation

### Primary Documents

- **[README.md](README.md)** - You are here! Game rules, features, and quick start guide
- **[DEVELOPMENT.md](DEVELOPMENT.md)** - Comprehensive technical guide including:
  - Detailed architecture documentation
  - Complete code style guidelines
  - Testing infrastructure
  - State management patterns
  - Navigation system
  - Design system reference
  - Common patterns and best practices
  - Development rules and principles

### When to Use Each Document

- **New to the project?** Start with README.md to understand the game and basic setup
- **Ready to contribute?** Read DEVELOPMENT.md for technical details and coding standards
- **Making changes?** Check DEVELOPMENT.md to ensure your code follows project conventions
- **Need a reference?** DEVELOPMENT.md is the single source of truth for all technical decisions

## Contributing

1. Fork the repository
2. Create your feature branch
3. Follow code style rules
4. Write tests for new features
5. Ensure all tests pass
6. Submit a pull request

## License

[Add your license here]

## Author

Giga Khizanishvili

## Acknowledgments

Built with SwiftUI and passion for party games!

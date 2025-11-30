//
//  Page+App.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI
import Navigation

// MARK: - App Pages
extension Page {
    static var home: Page<HomeView> {
        Page<HomeView>(id: "home") {
            HomeView()
        }
    }

    static var settings: Page<SettingsView> {
        Page<SettingsView>(id: "settings") {
            SettingsView()
        }
    }

    static var developerInfo: Page<DeveloperInfoView> {
        Page<DeveloperInfoView>(id: "developerInfo") {
            DeveloperInfoView()
        }
    }

    static var appIconSelection: Page<AppIconSelectionView> {
        Page<AppIconSelectionView>(id: "appIconSelection") {
            AppIconSelectionView()
        }
    }

    static var defaultsSettings: Page<DefaultsSettingsView> {
        Page<DefaultsSettingsView>(id: "defaultsSettings") {
            DefaultsSettingsView()
        }
    }

    static var teamSetup: Page {
        Page(id: "teamSetup") {
//            NavigationView {
                TeamSetupView()
//            }
//            .environment(GameManager())
//            .needsCloseButton()
        }
    }

    static var wordSettings: Page<WordSettingsView> {
        Page<WordSettingsView>(id: "wordSettings") {
            WordSettingsView()
        }
    }

    static var timerSettings: Page<TimerSettingsView> {
        Page<TimerSettingsView>(id: "timerSettings") {
            TimerSettingsView()
        }
    }

    static var wordInput: Page<WordInputView> {
        Page<WordInputView>(id: "wordInput") {
            WordInputView()
        }
    }

    static var randomization: Page<RandomizationView> {
        Page<RandomizationView>(id: "randomization") {
            RandomizationView()
        }
    }

    static func play(round: GameRound) -> Page<GameView> {
        Page<GameView>(id: "play-\(round.rawValue)") {
            GameView(round: round)
        }
    }

    static func teamTurnResults(guessedWords: [Word], completionReason: PlayCompletionReason) -> Page<TeamTurnResultsView> {
        Page<TeamTurnResultsView>(id: "teamTurnResults-\(guessedWords.hashValue)") {
            TeamTurnResultsView(guessedWords: guessedWords, completionReason: completionReason)
        }
    }

    static func nextTeam(round: GameRound, team: Team) -> Page<NextTeamView> {
        Page<NextTeamView>(id: "nextTeam-\(round.rawValue)-\(team.id)") {
            NextTeamView(round: round, team: team)
        }
    }

    static var roundResults: Page<ResultsView> {
        Page<ResultsView>(id: "roundResults") {
            ResultsView()
        }
    }

    static var finalResults: Page<ResultsView> {
        Page<ResultsView>(id: "finalResults") {
            ResultsView()
        }
    }
}

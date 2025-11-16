//
//  Page.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import Foundation
import SwiftUI

enum Page: Hashable {
    case welcome
    case developerInfo

    case teamSetup
    case wordSettings
    case timerSettings
    case wordInput
    case randomization

    case play(round: GameRound)
    case teamTurnResults(guessedWords: [Word])
    case nextTeam(round: GameRound, team: Team)
    case roundResults(round: GameRound)

    case finalResults
}

// MARK: - Identifiable
extension Page: Identifiable {
    var id: Page {
        self
    }
}

// MARK: - View
extension Page {
    @ViewBuilder
    func view() -> some View {
        switch self {
        case .welcome:
            WelcomeView()
        case .teamSetup:
            NavigationView {
                TeamSetupView()
            }
            .environment(GameManager())
            .needsCloseButton()
        case .wordSettings:
            WordSettingsView()
        case .timerSettings:
            TimerSettingsView()
        case .wordInput:
            WordInputView()
        case .randomization:
            RandomizationView()
        case .play(let round):
            GameView(round: round)
        case .teamTurnResults(let guessedWords):
            TeamTurnResultsView(guessedWords: guessedWords)
        case .nextTeam(let round, let team):
            NextTeamView(round: round, team: team)
        case .roundResults(let round):
            ResultsView(round: round, isFinal: false)
        case .finalResults:
            ResultsView(round: nil, isFinal: true)
        case .developerInfo:
            DeveloperInfoView()
        }
    }
}

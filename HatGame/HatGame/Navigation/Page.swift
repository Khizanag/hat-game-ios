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
    case teamSetup
    case wordSettings
    case timerSettings
    case wordInput
    case randomization
    case playing(round: GameRound, currentTeamIndex: Int)
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
            .needsCloseButton()
        case .wordSettings:
            WordSettingsView()
        case .timerSettings:
            TimerSettingsView()
        case .wordInput:
            WordInputView()
        case .randomization:
            RandomizationView()
        case .playing(let round, let teamIndex):
            GameView(round: round, teamIndex: teamIndex)
        case .roundResults(let round):
            ResultsView(round: round, isFinal: false)
        case .finalResults:
            ResultsView(round: nil, isFinal: true)
        }
    }
}

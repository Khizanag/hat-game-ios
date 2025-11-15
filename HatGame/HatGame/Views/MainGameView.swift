//
//  MainGameView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct MainGameView: View {
    @State private var gameManager = GameManager()
    
    var body: some View {
        Group {
            switch gameManager.state {
            case .welcome:
                WelcomeView(gameManager: gameManager)
            case .teamSetup:
                TeamSetupView(gameManager: gameManager)
            case .wordInput:
                WordInputView(gameManager: gameManager)
            case .randomization:
                RandomizationView(gameManager: gameManager)
            case .playing:
                GameView(gameManager: gameManager)
            case .roundResults:
                ResultsView(gameManager: gameManager, isFinal: false)
            case .finalResults:
                ResultsView(gameManager: gameManager, isFinal: true)
            }
        }
        .animation(.easeInOut, value: gameManager.state)
    }
}

#Preview {
    MainGameView()
}


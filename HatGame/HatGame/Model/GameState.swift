//
//  GameState.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import Foundation

enum GameState: Codable, Equatable {
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


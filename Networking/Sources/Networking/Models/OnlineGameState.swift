//
//  OnlineGameState.swift
//  Networking
//
//  Created by Giga Khizanishvili on 22.12.24.
//

import Foundation

public enum GamePhase: String, Codable, Sendable {
    case teamPrep
    case playing
    case turnResults
    case roundResults
    case finished
}

public enum OnlineGameRound: Int, Codable, CaseIterable, Sendable {
    case first = 1
    case second = 2
    case third = 3
}

public struct OnlineGameState: Codable, Sendable {
    public var currentRound: OnlineGameRound
    public var currentTeamIndex: Int
    public var currentExplainerIndex: Int
    public var currentWordId: String?
    public var remainingWordIds: [String]
    public var allWordIds: [String]
    public var scores: [String: [OnlineGameRound: Int]]
    public var phase: GamePhase
    public var activePlayerId: String?
    public var timerStartedAt: Date?
    public var roundDuration: Int

    public init(
        currentRound: OnlineGameRound = .first,
        currentTeamIndex: Int = 0,
        currentExplainerIndex: Int = 0,
        currentWordId: String? = nil,
        remainingWordIds: [String] = [],
        allWordIds: [String] = [],
        scores: [String: [OnlineGameRound: Int]] = [:],
        phase: GamePhase = .teamPrep,
        activePlayerId: String? = nil,
        timerStartedAt: Date? = nil,
        roundDuration: Int = 60
    ) {
        self.currentRound = currentRound
        self.currentTeamIndex = currentTeamIndex
        self.currentExplainerIndex = currentExplainerIndex
        self.currentWordId = currentWordId
        self.remainingWordIds = remainingWordIds
        self.allWordIds = allWordIds
        self.scores = scores
        self.phase = phase
        self.activePlayerId = activePlayerId
        self.timerStartedAt = timerStartedAt
        self.roundDuration = roundDuration
    }

    public func getScore(for teamId: String, in round: OnlineGameRound) -> Int {
        scores[teamId]?[round] ?? 0
    }

    public func getTotalScore(for teamId: String) -> Int {
        scores[teamId]?.values.reduce(0, +) ?? 0
    }
}

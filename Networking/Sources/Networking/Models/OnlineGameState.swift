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

    public var next: OnlineGameRound? {
        switch self {
        case .first: .second
        case .second: .third
        case .third: nil
        }
    }
}

public struct OnlineGameState: Codable, Sendable {
    public var currentRound: OnlineGameRound
    public var currentTeamIndex: Int
    /// Per-team explainer index. Each team rotates its own explainer
    /// independently of other teams.
    public var teamExplainerIndices: [String: Int]
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
        teamExplainerIndices: [String: Int] = [:],
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
        self.teamExplainerIndices = teamExplainerIndices
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

    public func explainerIndex(for teamId: String) -> Int {
        teamExplainerIndices[teamId] ?? 0
    }
}

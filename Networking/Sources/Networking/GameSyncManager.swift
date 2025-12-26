//
//  GameSyncManager.swift
//  Networking
//
//  Created by Giga Khizanishvili on 22.12.24.
//

import Foundation
import Observation
import FirebaseDatabase

@MainActor
@Observable
public final class GameSyncManager {
    public private(set) var isLoading: Bool = false
    public private(set) var error: Error?

    private let firebaseService = FirebaseService.shared

    public init() {}

    // MARK: - Game Initialization

    public func initializeGame(for roomId: String, teams: [OnlineTeam], words: [OnlineWord], roundDuration: Int) async throws -> OnlineGameState {
        let wordIds = words.map { $0.id }
        let shuffledWordIds = wordIds.shuffled()

        var initialScores: [String: [OnlineGameRound: Int]] = [:]
        for team in teams {
            initialScores[team.id] = [
                .first: 0,
                .second: 0,
                .third: 0
            ]
        }

        let firstTeam = teams.first
        let firstPlayerId = firstTeam?.playerIds.first

        let gameState = OnlineGameState(
            currentRound: .first,
            currentTeamIndex: 0,
            currentExplainerIndex: 0,
            currentWordId: shuffledWordIds.first,
            remainingWordIds: shuffledWordIds,
            allWordIds: shuffledWordIds,
            scores: initialScores,
            phase: .teamPrep,
            activePlayerId: firstPlayerId,
            roundDuration: roundDuration
        )

        try await firebaseService.updateGameState(gameState, forRoomId: roomId)
        return gameState
    }

    // MARK: - Turn Management

    public func startTurn(roomId: String, gameState: OnlineGameState) async throws {
        var newState = gameState
        newState.phase = .playing
        newState.timerStartedAt = Date()
        try await firebaseService.updateGameState(newState, forRoomId: roomId)
    }

    public func endTurn(roomId: String, gameState: OnlineGameState, guessedWordIds: [String]) async throws {
        var newState = gameState

        // Update scores
        let currentTeamId = getCurrentTeamId(from: gameState, teams: [])
        if let teamId = currentTeamId {
            var teamScores = newState.scores[teamId] ?? [:]
            let currentRoundScore = teamScores[gameState.currentRound] ?? 0
            teamScores[gameState.currentRound] = currentRoundScore + guessedWordIds.count
            newState.scores[teamId] = teamScores
        }

        // Remove guessed words
        newState.remainingWordIds.removeAll { guessedWordIds.contains($0) }

        newState.phase = .turnResults
        newState.timerStartedAt = nil

        try await firebaseService.updateGameState(newState, forRoomId: roomId)
    }

    public func advanceToNextTurn(roomId: String, gameState: OnlineGameState, teams: [OnlineTeam]) async throws {
        var newState = gameState

        // Check if round is over (no more words)
        if newState.remainingWordIds.isEmpty {
            // Move to next round or end game
            try await advanceToNextRound(roomId: roomId, gameState: &newState)
        } else {
            // Move to next team
            newState.currentTeamIndex = (newState.currentTeamIndex + 1) % teams.count

            // Rotate explainer within the team
            let currentTeam = teams[newState.currentTeamIndex]
            newState.currentExplainerIndex = (newState.currentExplainerIndex + 1) % max(1, currentTeam.playerIds.count)

            // Set active player
            if !currentTeam.playerIds.isEmpty {
                let explainerIndex = newState.currentExplainerIndex % currentTeam.playerIds.count
                newState.activePlayerId = currentTeam.playerIds[explainerIndex]
            }
        }

        newState.phase = .teamPrep
        newState.currentWordId = newState.remainingWordIds.first

        try await firebaseService.updateGameState(newState, forRoomId: roomId)
    }

    private func advanceToNextRound(roomId: String, gameState: inout OnlineGameState) async throws {
        switch gameState.currentRound {
        case .first:
            gameState.currentRound = .second
            gameState.remainingWordIds = gameState.allWordIds.shuffled()
            gameState.phase = .roundResults
        case .second:
            gameState.currentRound = .third
            gameState.remainingWordIds = gameState.allWordIds.shuffled()
            gameState.phase = .roundResults
        case .third:
            gameState.phase = .finished
            try await firebaseService.updateRoomStatus(.finished, forRoomId: roomId)
        }
    }

    // MARK: - Word Actions

    public func markWordGuessed(roomId: String, gameState: OnlineGameState, wordId: String, teams: [OnlineTeam]) async throws {
        var newState = gameState

        // Update score for current team
        let currentTeam = teams[safe: newState.currentTeamIndex]
        if let teamId = currentTeam?.id {
            var teamScores = newState.scores[teamId] ?? [:]
            let currentRoundScore = teamScores[gameState.currentRound] ?? 0
            teamScores[gameState.currentRound] = currentRoundScore + 1
            newState.scores[teamId] = teamScores
        }

        // Remove word from remaining
        newState.remainingWordIds.removeAll { $0 == wordId }

        // Set next word or end round
        if newState.remainingWordIds.isEmpty {
            // All words guessed - round complete
            newState.currentWordId = nil
        } else {
            newState.currentWordId = newState.remainingWordIds.first
        }

        try await firebaseService.updateGameState(newState, forRoomId: roomId)
    }

    public func skipWord(roomId: String, gameState: OnlineGameState) async throws {
        var newState = gameState

        // Move current word to end of remaining words
        if let currentWordId = newState.currentWordId,
           let index = newState.remainingWordIds.firstIndex(of: currentWordId) {
            newState.remainingWordIds.remove(at: index)
            newState.remainingWordIds.append(currentWordId)
        }

        // Get next word
        newState.currentWordId = newState.remainingWordIds.first

        try await firebaseService.updateGameState(newState, forRoomId: roomId)
    }

    // MARK: - Phase Management

    public func setPhase(_ phase: GamePhase, roomId: String, gameState: OnlineGameState) async throws {
        var newState = gameState
        newState.phase = phase
        try await firebaseService.updateGameState(newState, forRoomId: roomId)
    }

    public func continueFromRoundResults(roomId: String, gameState: OnlineGameState) async throws {
        var newState = gameState
        newState.phase = .teamPrep
        try await firebaseService.updateGameState(newState, forRoomId: roomId)
    }

    // MARK: - Explainer Selection

    public func setExplainer(roomId: String, gameState: OnlineGameState, playerIndex: Int, teams: [OnlineTeam]) async throws {
        var newState = gameState
        newState.currentExplainerIndex = playerIndex

        // Set active player
        let currentTeam = teams[safe: newState.currentTeamIndex]
        if let playerIds = currentTeam?.playerIds, playerIndex < playerIds.count {
            newState.activePlayerId = playerIds[playerIndex]
        }

        try await firebaseService.updateGameState(newState, forRoomId: roomId)
    }

    // MARK: - Helpers

    private func getCurrentTeamId(from gameState: OnlineGameState, teams: [OnlineTeam]) -> String? {
        guard gameState.currentTeamIndex < teams.count else { return nil }
        return teams[gameState.currentTeamIndex].id
    }
}

// MARK: - Array Extension
private extension Array {
    subscript(safe index: Int) -> Element? {
        guard index >= 0, index < count else { return nil }
        return self[index]
    }
}

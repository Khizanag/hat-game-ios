//
//  GameManager.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import Foundation
import Observation
import SwiftUI

@Observable
final class GameManager {
    // MARK: - Configuration
    var configuration: GameConfiguration

    // MARK: - History
    let historyManager = HistoryManager()

    // MARK: - Rounds
    private var roundIterator = GameConfiguration.rounds.makeIterator()
    var currentRound: GameRound?

    var isGameFinished: Bool { currentRound == nil } // or currentWord == nil

    // MARK: - Words
    private var remainingWords: Set<Word> = []
    var remainingWordCount: Int { remainingWords.count }
    var currentWord: Word?

    // MARK: - Teams
    var currentTeam: Team { configuration.teams[currentTeamIndex] }
    private var currentTeamIndex: Int = 0

    // MARK: - Time Tracking
    private var teamRemainingTimes: [UUID: Int] = [:]

    // MARK: - Initialization
    init(configuration: GameConfiguration? = nil) {
        if let configuration {
            self.configuration = configuration
        } else if AppConfiguration.shared.isTestMode {
            self.configuration = GameConfiguration.mockForTesting
        } else {
            self.configuration = GameConfiguration()
        }
    }

    // MARK: - Functions
    func start() {
        historyManager.setUp(configuration: configuration)
        historyManager.prepareForNewRound(.first)

        remainingWords = Set(configuration.words)
        currentRound = roundIterator.next()
        currentWord = remainingWords.randomElement()
    }

    func commitWordGuess() {
        guard let currentWord, let currentRound else { fatalError("No current word") }

        historyManager.saveThatTeamGuessedWord(word: currentWord, for: currentTeam, round: currentRound)

        remainingWords.remove(currentWord)

        self.currentWord = remainingWords.randomElement()
    }

    func prepareForNewPlay() {
        if currentWord != nil { // Current round is not finished
            setNextTeam()
        } else { // Current round is finished
            setUpNextRound()
        }
    }

    func saveRemainingTime(_ seconds: Int, for team: Team) {
        teamRemainingTimes[team.id] = seconds
    }

    func getRemainingTime(for team: Team) -> Int? {
        teamRemainingTimes[team.id]
    }

    func clearRemainingTime(for team: Team) {
        teamRemainingTimes.removeValue(forKey: team.id)
    }
}

// MARK: - Setup
extension GameManager {
    func addWords(_ words: [String], by player: Player) {
        configuration.words.append(
            contentsOf: words.map {
                .init(text: $0)
            }
        )
    }

    func addTeam(_ team: Team) {
        configuration.teams.append(team)
    }

    func removeTeam(_ team: Team) {
        configuration.teams.removeAll { $0.id == team.id }
    }
}

// MARK: - Scores
extension GameManager {
    func getScore(for team: Team, in round: GameRound) -> Int {
        guard let ranking = historyManager.rankingForRound(round) else {
            return 0
        }
        return ranking.first(where: { $0.0.id == team.id })?.1 ?? 0
    }

    func getTotalScore(for team: Team) -> Int {
        let ranking = historyManager.totalRanking()
        return ranking.first(where: { $0.0.id == team.id })?.1 ?? 0
    }

    func getSortedTeamsByRoundScore(for round: GameRound) -> [Team] {
        historyManager.rankingForRound(round)?.map { $0.0 } ?? []
    }

    func getSortedTeamsByTotalScore() -> [Team] {
        historyManager.totalRanking().map { $0.0 }
    }

    func getCompletedRounds() -> [GameRound] {
        guard let currentRound = currentRound else {
            return GameRound.allCases
        }
        return GameRound.allCases.filter { $0.rawValue < currentRound.rawValue }
    }

    func getStartedRounds() -> [GameRound] {
        guard let currentRound = currentRound else {
            return GameRound.allCases
        }
        return GameRound.allCases.filter { $0.rawValue <= currentRound.rawValue }
    }
}

// MARK: - Private
private extension GameManager {
    func setUpNextRound() {
        resetWords()
        // Preserve current team's remaining time if they finished the round early
        // Clear all other teams' times
        let currentTeamTime = teamRemainingTimes[currentTeam.id]
        resetTeamTimes()
        if let currentTeamTime {
            teamRemainingTimes[currentTeam.id] = currentTeamTime
        }

        currentRound = roundIterator.next()

        if let currentRound {
            historyManager.prepareForNewRound(currentRound)
        } else {
            finishGame()
        }

        currentWord = remainingWords.randomElement()
    }

    func setNextTeam() {
        currentTeamIndex = (currentTeamIndex + 1) % configuration.teams.count
    }

    func resetWords() {
        remainingWords = Set(configuration.words)
    }

    func resetTeamTimes() {
        teamRemainingTimes.removeAll()
    }

    func finishGame() {
        // TODO: Implement
    }
}

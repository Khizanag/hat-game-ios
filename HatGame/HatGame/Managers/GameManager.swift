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
    var configuration = GameConfiguration.mockForTesting

    // MARK: - History
    let historyManager = HistoryManager()

    // MARK: - Rounds
    private static let rounds: [GameRound] = [.first, .second, .third]
    private var roundIterator = rounds.makeIterator()
    var currentRound: GameRound?

    var isGameFinished: Bool { currentRound == nil } // or currentWord == nil

    // MARK: - Words
    private var remainingWords: Set<Word> = []
    var remainingWordCount: Int { remainingWords.count }
    var currentWord: Word?

    // MARK: - Teams
    var currentTeam: Team { configuration.teams[currentTeamIndex] }
    private var currentTeamIndex: Int = 0
    
    // MARK: - Scores
    // TODO: Replace with actual score tracking from HistoryManager
    private var dummyScores: [Team: [GameRound: Int]] = [:]
    private var dummyTotalScores: [Team: Int] = [:]

    // MARK: - Functions
    func start() {
        historyManager.setUp()
        remainingWords = Set(configuration.words)
        currentRound = roundIterator.next()
        currentWord = remainingWords.randomElement()
        initializeDummyScores()
    }

    func commitWordGuess() {
        guard let currentWord, let currentRound else { fatalError("No current word") }

        historyManager.saveThatTeamGuessedWord(word: currentWord, for: currentTeam, round: currentRound)

        remainingWords.remove(currentWord)

        self.currentWord = remainingWords.randomElement()

        if self.currentWord == nil {
            setUpNextRound()
        }
    }

    func commitPlayFinish() {
        if currentWord != nil { // Round is not finished
            currentTeamIndex = (currentTeamIndex + 1) % configuration.teams.count
        } else { // Round is finished
            setUpNextRound()
        }
    }

    func setNextTeam() {

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

    func removeTeamById(_ id: UUID) {
        configuration.teams.removeAll { $0.id == id }
    }
}

// MARK: - Scores
extension GameManager {
    func getScore(for team: Team, in round: GameRound) -> Int {
        dummyScores[team]?[round] ?? 0
    }
    
    func getTotalScore(for team: Team) -> Int {
        dummyTotalScores[team] ?? 0
    }
    
    func getSortedTeamsByRoundScore(for round: GameRound) -> [Team] {
        configuration.teams.sorted { team1, team2 in
            let score1 = getScore(for: team1, in: round)
            let score2 = getScore(for: team2, in: round)
            if score1 != score2 {
                return score1 > score2
            }
            return team1.name < team2.name
        }
    }
    
    func getSortedTeamsByTotalScore() -> [Team] {
        configuration.teams.sorted { team1, team2 in
            let score1 = getTotalScore(for: team1)
            let score2 = getTotalScore(for: team2)
            if score1 != score2 {
                return score1 > score2
            }
            return team1.name < team2.name
        }
    }
    
    private func initializeDummyScores() {
        var scores: [Team: [GameRound: Int]] = [:]
        var totalScores: [Team: Int] = [:]
        
        for team in configuration.teams {
            var roundScores: [GameRound: Int] = [:]
            var total = 0
            
            for round in GameRound.allCases {
                let score = Int.random(in: 5...25)
                roundScores[round] = score
                total += score
            }
            
            scores[team] = roundScores
            totalScores[team] = total
        }
        
        dummyScores = scores
        dummyTotalScores = totalScores
    }
}

// MARK: - Private
private extension GameManager {
    func setUpNextRound() {
        currentRound = roundIterator.next()

        if currentRound == nil {
            finishGame()
        }

        currentWord = remainingWords.randomElement()
    }

    func finishGame() {
        // TODO: Implement
    }
}
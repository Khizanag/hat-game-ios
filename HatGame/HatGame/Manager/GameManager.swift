//
//  GameManager.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

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

    // MARK: - Team Roles
    private var teamExplainerIndices: [UUID: Int] = [:]
    private var teamsWithLockedRoles: Set<UUID> = [] // Teams that have played at least once
    private var shouldRotateRoles: Bool = true

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
    func start(startingTeamIndex: Int = 0) {
        currentTeamIndex = startingTeamIndex
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
        // Rotate roles if needed (when time ran out, not when words completed early)
        if shouldRotateRoles {
            rotateExplainer(for: currentTeam)
        }

        if currentWord != nil { // Current round is not finished
            setNextTeam()
            currentWord = remainingWords.randomElement()
            shouldRotateRoles = true // Reset for next team
        } else { // Current round is finished
            setUpNextRound()
            shouldRotateRoles = true // Reset for next round
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

    func getAllUsedWords() -> Set<String> {
        Set(configuration.words.map { $0.text })
    }

    // MARK: - Role Management

    func setExplainer(playerIndex: Int, for team: Team) {
        teamExplainerIndices[team.id] = playerIndex
        // Lock roles for this team - they can never select again
        teamsWithLockedRoles.insert(team.id)
    }

    func getExplainerIndex(for team: Team) -> Int? {
        teamExplainerIndices[team.id]
    }

    /// Returns true if this is the team's first play and roles can be selected
    /// After the first play, roles are locked and auto-rotated only
    func canSelectRoles(for team: Team) -> Bool {
        !teamsWithLockedRoles.contains(team.id)
    }

    func getExplainer(for team: Team) -> Player? {
        guard let index = teamExplainerIndices[team.id],
              index < team.players.count else {
            return nil
        }
        return team.players[index]
    }

    func getGuessers(for team: Team) -> [Player] {
        guard let explainerIndex = teamExplainerIndices[team.id] else {
            return Array(team.players.dropFirst())
        }
        return team.players.enumerated()
            .filter { $0.offset != explainerIndex }
            .map { $0.element }
    }

    func rotateExplainer(for team: Team) {
        guard !team.players.isEmpty else { return }

        let currentIndex = teamExplainerIndices[team.id] ?? 0
        let nextIndex = (currentIndex + 1) % team.players.count
        teamExplainerIndices[team.id] = nextIndex
    }

    func markPlayEndedWithTimeRemaining() {
        shouldRotateRoles = false
    }

    func markPlayEndedWithTimeOut() {
        shouldRotateRoles = true
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

    func moveTeam(from source: IndexSet, to destination: Int) {
        configuration.teams.move(fromOffsets: source, toOffset: destination)
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

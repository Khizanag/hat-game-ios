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
    var configuration = GameConfiguration()
    
    var shuffledWords: [Word] = []
    var currentWordIndex: Int = 0

    var roundStartTime: Date?
    var roundEndTime: Date?

    var startingTeamIndex: Int = 0
    var currentRound: GameRound?
    var currentTeamIndex: Int?
    
    var currentTurnStartWordIndex: Int = 0
    var currentTeamTurnIndex: Int = 0
    var currentTurnNumber: Int = 0
    
    private var testWordsByPlayer: [UUID: [String]] = [:]
    
    var currentWord: Word? {
        let unguessedWords = shuffledWords.filter { !$0.guessed }
        guard !unguessedWords.isEmpty else { return nil }
        guard currentWordIndex < shuffledWords.count else { return unguessedWords.first }
        let word = shuffledWords[currentWordIndex]
        return word.guessed ? unguessedWords.first : word
    }
    
    var remainingWords: [Word] {
        shuffledWords.filter { !$0.guessed }
    }
    
    var allWordsGuessed: Bool {
        shuffledWords.allSatisfy { $0.guessed }
    }

    // MARK: - Init
    init() {
        // TODO: Refactor
        if UserDefaults.standard.bool(forKey: "HatGame.isTestMode") {
            applyTestData()
        }
    }

    func addTeam(name: String) {
        guard configuration.teams.count < configuration.maxTeams else { return }
        let team = Team(name: name, colorIndex: configuration.teams.count)
        configuration.teams.append(team)
    }
    
    func addPlayer(name: String, to teamId: UUID, limit: Int? = nil) {
        guard let teamIndex = configuration.teams.firstIndex(where: { $0.id == teamId }) else { return }
        let maxLimit = limit ?? configuration.maxTeamMembers
        if configuration.teams[teamIndex].players.count >= maxLimit {
            return
        }
        let player = Player(name: name, teamId: teamId)
        configuration.teams[teamIndex].players.append(player)
    }
    
    func updateTeamName(teamId: UUID, name: String) {
        guard let teamIndex = configuration.teams.firstIndex(where: { $0.id == teamId }) else { return }
        configuration.teams[teamIndex].name = name
    }
    
    func updatePlayerName(playerId: UUID, name: String) {
        for teamIndex in configuration.teams.indices {
            if let playerIndex = configuration.teams[teamIndex].players.firstIndex(where: { $0.id == playerId }) {
                let player = configuration.teams[teamIndex].players[playerIndex]
                configuration.teams[teamIndex].players[playerIndex] = Player(
                    id: player.id,
                    name: name,
                    teamId: player.teamId
                )
                break
            }
        }
    }
    
    func removeTeam(_ teamId: UUID) {
        configuration.teams.removeAll { $0.id == teamId }
    }
    
    func removePlayer(_ playerId: UUID) {
        for index in configuration.teams.indices {
            configuration.teams[index].players.removeAll { $0.id == playerId }
        }
    }
    
    func addWords(_ words: [String], for playerId: UUID) {
        let newWords = words.map { Word(text: $0) }
        configuration.words.append(contentsOf: newWords)
    }
    
    func shuffleWords() {
        shuffledWords = configuration.words.shuffled()
        currentWordIndex = 0
    }
    
    func startRound(_ round: GameRound, startingTeamIndex: Int) {
        self.startingTeamIndex = startingTeamIndex
        self.currentRound = round
        self.currentTeamIndex = startingTeamIndex
        roundStartTime = Date()
        resetWordGuessedState()
        currentTeamTurnIndex = 0
        currentTurnStartWordIndex = shuffledWords.filter { $0.guessed }.count
    }
    
    func resetWordGuessedState() {
        for index in shuffledWords.indices {
            shuffledWords[index].guessed = false
            shuffledWords[index].guessedByTeamId = nil
            shuffledWords[index].guessedInRound = nil
        }
    }
    
    func markWordAsGuessed(by teamId: UUID) {
        guard currentWordIndex < shuffledWords.count else { return }
        shuffledWords[currentWordIndex].guessed = true
        shuffledWords[currentWordIndex].guessedByTeamId = teamId
        if let round = currentRound {
            shuffledWords[currentWordIndex].guessedInRound = round.rawValue
        }
        
        updateTeamScore(teamId: teamId)
    }
    
    func skipToNextWord() {
        let unguessedWords = shuffledWords.filter { !$0.guessed }
        guard !unguessedWords.isEmpty else { return }
        
        guard currentWordIndex < shuffledWords.count else {
            if let firstUnguessed = unguessedWords.first, let index = shuffledWords.firstIndex(where: { $0.id == firstUnguessed.id }) {
                currentWordIndex = index
            }
            return
        }
        
        let currentWordAtIdx = shuffledWords[currentWordIndex]
        if currentWordAtIdx.guessed {
            if let firstUnguessed = unguessedWords.first, let index = shuffledWords.firstIndex(where: { $0.id == firstUnguessed.id }) {
                currentWordIndex = index
            }
        } else {
            var nextIndex = (currentWordIndex + 1) % shuffledWords.count
            var attempts = 0
            while shuffledWords[nextIndex].guessed && attempts < shuffledWords.count {
                nextIndex = (nextIndex + 1) % shuffledWords.count
                attempts += 1
            }
            if !shuffledWords[nextIndex].guessed {
                currentWordIndex = nextIndex
            }
        }
    }
    
    func moveToNextTeam() {
        guard let currentIndex = currentTeamIndex else { return }
        let nextIndex = (currentIndex + 1) % configuration.teams.count
        currentTeamIndex = nextIndex
        currentTeamTurnIndex += 1
        currentTurnStartWordIndex = shuffledWords.filter { $0.guessed }.count
    }
    
    func getWordsGuessedInCurrentTurn(by teamId: UUID) -> [Word] {
        // Get words guessed by this team since the turn started
        // currentTurnStartWordIndex tracks how many words were guessed total when turn started
        let wordsGuessedThisTurn = shuffledWords.filter { word in
            word.guessed && word.guessedByTeamId == teamId
        }
        // Since we can't track exact order, return all words guessed by this team
        // that were guessed in the current round
        // This is an approximation - in a real scenario we'd need to track turn numbers
        return wordsGuessedThisTurn.filter { $0.guessedInRound == currentRound?.rawValue }
    }
    
    func startTeamTurn() {
        currentTurnStartWordIndex = shuffledWords.filter { $0.guessed }.count
    }
    
    func getExplainingPlayer(for teamIndex: Int) -> Player? {
        guard teamIndex < configuration.teams.count else { return nil }
        let team = configuration.teams[teamIndex]
        guard team.players.count == 2 else { return team.players.first }
        // Alternate between players based on turn index
        return team.players[currentTeamTurnIndex % 2]
    }
    
    func getGuessingPlayer(for teamIndex: Int) -> Player? {
        guard teamIndex < configuration.teams.count else { return nil }
        let team = configuration.teams[teamIndex]
        guard team.players.count == 2 else { return nil }
        // The other player is guessing
        let explainingIndex = currentTeamTurnIndex % 2
        return team.players[(explainingIndex + 1) % 2]
    }
    
    func finishRound() {
        roundEndTime = Date()
    }
    
    func startNextRound() {
        guard let currentRound = currentRound else { return }
        
        if currentRound == .third {
            self.currentRound = nil
            self.currentTeamIndex = nil
        } else {
            let nextRound = GameRound(rawValue: currentRound.rawValue + 1)!
            let nextTeamIndex = (startingTeamIndex + 1) % configuration.teams.count
            startRound(nextRound, startingTeamIndex: nextTeamIndex)
        }
    }
    
    func updateTeamScore(teamId: UUID) {
        guard let teamIndex = configuration.teams.firstIndex(where: { $0.id == teamId }) else { return }
        configuration.teams[teamIndex].score += 1
    }
    
    func resetGame() {
        currentRound = nil
        currentTeamIndex = nil
        configuration.teams = []
        configuration.words = []
        shuffledWords = []
        currentWordIndex = 0
        roundStartTime = nil
        roundEndTime = nil
        configuration.wordsPerPlayer = 10
        configuration.roundDuration = 60
        startingTeamIndex = 0
        testWordsByPlayer = [:]
    }
    
    func getTeamScore(teamId: UUID) -> Int {
        configuration.teams.first(where: { $0.id == teamId })?.score ?? 0
    }
    
    func getSortedTeamsByScore() -> [Team] {
        configuration.teams.sorted { $0.score > $1.score }
    }
    
    func getWinner() -> Team? {
        guard !configuration.teams.isEmpty else { return nil }
        let sorted = getSortedTeamsByScore()
        guard let topScore = sorted.first?.score, topScore > 0 else { return nil }
        return sorted.first
    }
    
    func defaultWords(for playerId: UUID) -> [String]? {
        testWordsByPlayer[playerId]
    }
    
    func updateDefaultWords(_ words: [String], for playerId: UUID) {
        testWordsByPlayer[playerId] = words
    }
}

// MARK: - Test
private extension GameManager {
    func applyTestData() {
        resetGame()
        configuration.wordsPerPlayer = 5
        configuration.roundDuration = 5

        let sampleTeams = [
            ("Orion", ["Alex", "Maya"]),
            ("Nova", ["Leo", "Sara"])
        ]

        var generatedTeams: [Team] = []
        let wordPool = [
            "Galaxy","Comet","Nebula","Orbit","Meteor",
            "Starlight","Eclipse","Gravity","Rocket","Cosmos",
            "Aurora","Planet","Photon","Quasar","Launch",
            "Module","Astro","Signal","Beacon","Zenith",
            "Lunar","Solar","Module","Vector","Halo",
            "Pulse","Nova","Drift","Horizon","Spark"
        ]
        var poolIndex = 0

        for (index, sample) in sampleTeams.enumerated() {
            let teamId = UUID()
            let players = sample.1.map { Player(name: $0, teamId: teamId) }
            let team = Team(id: teamId, name: sample.0, players: players, colorIndex: index)
            generatedTeams.append(team)

            for player in players {
                var words: [String] = []
                for _ in 0..<configuration.wordsPerPlayer {
                    let word = wordPool[poolIndex % wordPool.count]
                    words.append(word)
                    poolIndex += 1
                }
                testWordsByPlayer[player.id] = words
            }
        }

        configuration.teams = generatedTeams
    }
}


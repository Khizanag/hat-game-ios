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
    
    // Track word guessing state
    private var guessedWords: Set<UUID> = []
    private var guessedByTeam: [UUID: UUID] = [:]
    private var guessedInRound: [UUID: Int] = [:]
    
    var currentWord: Word? {
        let unguessedWords = shuffledWords.filter { !guessedWords.contains($0.id) }
        guard !unguessedWords.isEmpty else { return nil }
        guard currentWordIndex < shuffledWords.count else { return unguessedWords.first }
        let word = shuffledWords[currentWordIndex]
        return guessedWords.contains(word.id) ? unguessedWords.first : word
    }
    
    var remainingWords: [Word] {
        shuffledWords.filter { !guessedWords.contains($0.id) }
    }
    
    var allWordsGuessed: Bool {
        shuffledWords.allSatisfy { guessedWords.contains($0.id) }
    }
    
    func isWordGuessed(_ word: Word) -> Bool {
        guessedWords.contains(word.id)
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
        let color = configuration.teamColor(for: configuration.teams.count)
        let team = Team(name: name, color: color)
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
        currentTurnStartWordIndex = guessedWords.count
    }
    
    func resetWordGuessedState() {
        guessedWords.removeAll()
        guessedByTeam.removeAll()
        guessedInRound.removeAll()
    }
    
    func markWordAsGuessed(by teamId: UUID) {
        guard currentWordIndex < shuffledWords.count else { return }
        let wordId = shuffledWords[currentWordIndex].id
        guessedWords.insert(wordId)
        guessedByTeam[wordId] = teamId
        if let round = currentRound {
            guessedInRound[wordId] = round.rawValue
        }
        
        updateTeamScore(teamId: teamId)
    }
    
    func skipToNextWord() {
        let unguessedWords = shuffledWords.filter { !guessedWords.contains($0.id) }
        guard !unguessedWords.isEmpty else { return }
        
        guard currentWordIndex < shuffledWords.count else {
            if let firstUnguessed = unguessedWords.first, let index = shuffledWords.firstIndex(where: { $0.id == firstUnguessed.id }) {
                currentWordIndex = index
            }
            return
        }
        
        let currentWordAtIdx = shuffledWords[currentWordIndex]
        if guessedWords.contains(currentWordAtIdx.id) {
            if let firstUnguessed = unguessedWords.first, let index = shuffledWords.firstIndex(where: { $0.id == firstUnguessed.id }) {
                currentWordIndex = index
            }
        } else {
            var nextIndex = (currentWordIndex + 1) % shuffledWords.count
            var attempts = 0
            while guessedWords.contains(shuffledWords[nextIndex].id) && attempts < shuffledWords.count {
                nextIndex = (nextIndex + 1) % shuffledWords.count
                attempts += 1
            }
            if !guessedWords.contains(shuffledWords[nextIndex].id) {
                currentWordIndex = nextIndex
            }
        }
    }
    
    func moveToNextTeam() {
        guard let currentIndex = currentTeamIndex else { return }
        let nextIndex = (currentIndex + 1) % configuration.teams.count
        currentTeamIndex = nextIndex
        currentTeamTurnIndex += 1
        currentTurnStartWordIndex = guessedWords.count
    }
    
    func getWordsGuessedInCurrentTurn(by teamId: UUID) -> [Word] {
        // Get words guessed by this team since the turn started
        // currentTurnStartWordIndex tracks how many words were guessed total when turn started
        let wordsGuessedThisTurn = shuffledWords.filter { word in
            guessedWords.contains(word.id) && guessedByTeam[word.id] == teamId
        }
        // Since we can't track exact order, return all words guessed by this team
        // that were guessed in the current round
        // This is an approximation - in a real scenario we'd need to track turn numbers
        guard let currentRoundValue = currentRound?.rawValue else { return [] }
        return wordsGuessedThisTurn.filter { guessedInRound[$0.id] == currentRoundValue }
    }
    
    func startTeamTurn() {
        currentTurnStartWordIndex = guessedWords.count
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
        guessedWords.removeAll()
        guessedByTeam.removeAll()
        guessedInRound.removeAll()
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
            let color = configuration.teamColor(for: index)
            let team = Team(id: teamId, name: sample.0, players: players, color: color)
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


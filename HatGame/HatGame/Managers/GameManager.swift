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
    
    // Track explaining player index for each team
    private var explainingPlayerIndexByTeam: [Team: Int] = [:]
    
    private var currentTurnStartWordIndex: Int = 0
    private var currentTeamTurnIndex: Int = 0
    
    // Track word guessing state
    // guessedWords: words guessed in the current round (reset each round)
    private var guessedWords: Set<Word> = []
    // guessedByTeam: tracks which team guessed each word in current round
    private var guessedByTeam: [Word: Team] = [:]
    // guessedInRounds: tracks which rounds each word was guessed in (persists across rounds)
    private var guessedInRounds: [Word: Set<Int>] = [:]
    
    var currentWord: Word? {
        let unguessedWords = shuffledWords.filter { !guessedWords.contains($0) }
        guard !unguessedWords.isEmpty else { return nil }
        guard currentWordIndex < shuffledWords.count else { return unguessedWords.first }
        let word = shuffledWords[currentWordIndex]
        return guessedWords.contains(word) ? unguessedWords.first : word
    }
    
    var remainingWords: [Word] {
        shuffledWords.filter { !guessedWords.contains($0) }
    }
    
    var allWordsGuessed: Bool {
        shuffledWords.allSatisfy { guessedWords.contains($0) }
    }
    
    func isWordGuessed(_ word: Word) -> Bool {
        guessedWords.contains(word)
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
    
    func addPlayer(name: String, to team: Team, limit: Int? = nil) {
        guard let teamIndex = configuration.teams.firstIndex(where: { $0.id == team.id }) else { return }
        let maxLimit = limit ?? configuration.maxTeamMembers
        if configuration.teams[teamIndex].players.count >= maxLimit {
            return
        }
        let player = Player(name: name, teamId: team.id)
        configuration.teams[teamIndex].players.append(player)
    }
    
    func updateTeamName(team: Team, name: String) {
        guard let teamIndex = configuration.teams.firstIndex(where: { $0.id == team.id }) else { return }
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
    
    func removeTeam(_ team: Team) {
        configuration.teams.removeAll { $0.id == team.id }
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
    
    // MARK: - Word Management
    
    func shuffleWords() {
        shuffledWords = configuration.words.shuffled()
        currentWordIndex = 0
    }
    
    func nextWord() {
        skipToNextWord()
    }
    
    func startRound(_ round: GameRound, startingTeamIndex: Int) {
        self.startingTeamIndex = startingTeamIndex
        self.currentRound = round
        self.currentTeamIndex = startingTeamIndex
        roundStartTime = Date()
        resetWordGuessedState()
        currentTeamTurnIndex = 0
        currentTurnStartWordIndex = guessedWords.count
        initializeExplainingPlayerIndex()
    }
    
    private func initializeExplainingPlayerIndex() {
        guard let teamIndex = currentTeamIndex,
              teamIndex < configuration.teams.count else { return }
        let team = configuration.teams[teamIndex]
        // Initialize explaining player index to 0 if not set
        if explainingPlayerIndexByTeam[team] == nil {
            explainingPlayerIndexByTeam[team] = 0
        }
    }
    
    func resetWordGuessedState() {
        // Only clear current round's guesses, keep history of rounds
        guessedWords.removeAll()
        guessedByTeam.removeAll()
        // guessedInRounds persists across rounds to track all rounds a word was guessed
    }
    
    // MARK: - Gameplay
    
    func markCurrentWordAsGuessed(by team: Team) {
        guard currentWordIndex < shuffledWords.count else { return }
        let word = shuffledWords[currentWordIndex]
        guessedWords.insert(word)
        guessedByTeam[word] = team
        if let round = currentRound {
            // Track that this word was guessed in this round
            if guessedInRounds[word] == nil {
                guessedInRounds[word] = []
            }
            guessedInRounds[word]?.insert(round.rawValue)
        }
        
        updateTeamScore(team: team)
    }
    
    func skipToNextWord() {
        let unguessedWords = shuffledWords.filter { !guessedWords.contains($0) }
        guard !unguessedWords.isEmpty else { return }
        
        guard currentWordIndex < shuffledWords.count else {
            if let firstUnguessed = unguessedWords.first, let index = shuffledWords.firstIndex(of: firstUnguessed) {
                currentWordIndex = index
            }
            return
        }
        
        let currentWordAtIdx = shuffledWords[currentWordIndex]
        if guessedWords.contains(currentWordAtIdx) {
            if let firstUnguessed = unguessedWords.first, let index = shuffledWords.firstIndex(of: firstUnguessed) {
                currentWordIndex = index
            }
        } else {
            var nextIndex = (currentWordIndex + 1) % shuffledWords.count
            var attempts = 0
            while guessedWords.contains(shuffledWords[nextIndex]) && attempts < shuffledWords.count {
                nextIndex = (nextIndex + 1) % shuffledWords.count
                attempts += 1
            }
            if !guessedWords.contains(shuffledWords[nextIndex]) {
                currentWordIndex = nextIndex
            }
        }
    }
    
    func finishTeamTurn() {
        guard let currentIndex = currentTeamIndex,
              currentIndex < configuration.teams.count else { return }
        
        // Increment explaining player index for current team
        let currentTeam = configuration.teams[currentIndex]
        let currentExplainingIndex = explainingPlayerIndexByTeam[currentTeam] ?? 0
        let nextExplainingIndex = (currentExplainingIndex + 1) % max(currentTeam.players.count, 1)
        explainingPlayerIndexByTeam[currentTeam] = nextExplainingIndex
        
        // Move to next team
        let nextIndex = (currentIndex + 1) % configuration.teams.count
        moveToNextTeam(nextIndex)
    }
    
    private func moveToNextTeam(_ nextIndex: Int) {
        currentTeamIndex = nextIndex
        currentTeamTurnIndex += 1
        currentTurnStartWordIndex = guessedWords.count
        initializeExplainingPlayerIndex()
    }
    
    func getWordsGuessedInCurrentTurn(by team: Team) -> [Word] {
        // Get words guessed by this team since the turn started
        // currentTurnStartWordIndex tracks how many words were guessed total when turn started
        let wordsGuessedThisTurn = shuffledWords.filter { word in
            guessedWords.contains(word) && guessedByTeam[word]?.id == team.id
        }
        // Return words guessed by this team in the current round
        guard let currentRoundValue = currentRound?.rawValue else { return [] }
        return wordsGuessedThisTurn.filter { guessedInRounds[$0]?.contains(currentRoundValue) == true }
    }
    
    func wasWordGuessedInRound(_ word: Word, round: GameRound) -> Bool {
        guessedInRounds[word]?.contains(round.rawValue) ?? false
    }
    
    func getRoundsWordWasGuessed(_ word: Word) -> Set<Int> {
        guessedInRounds[word] ?? []
    }
    
    func startTeamTurn() {
        currentTurnStartWordIndex = guessedWords.count
        initializeExplainingPlayerIndex()
    }
    
    func getExplainingPlayer(for teamIndex: Int) -> Player? {
        guard teamIndex < configuration.teams.count else { return nil }
        let team = configuration.teams[teamIndex]
        guard !team.players.isEmpty else { return nil }
        
        let explainingIndex = explainingPlayerIndexByTeam[team] ?? 0
        return team.players[explainingIndex % team.players.count]
    }
    
    func getGuessingPlayer(for teamIndex: Int) -> Player? {
        guard teamIndex < configuration.teams.count else { return nil }
        let team = configuration.teams[teamIndex]
        guard team.players.count >= 2 else { return nil }
        
        let explainingIndex = explainingPlayerIndexByTeam[team] ?? 0
        let guessingIndex = (explainingIndex + 1) % team.players.count
        return team.players[guessingIndex]
    }
    
    var currentExplainingPlayer: Player? {
        guard let teamIndex = currentTeamIndex else { return nil }
        return getExplainingPlayer(for: teamIndex)
    }
    
    var currentGuessingPlayer: Player? {
        guard let teamIndex = currentTeamIndex else { return nil }
        return getGuessingPlayer(for: teamIndex)
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
    
    func updateTeamScore(team: Team) {
        guard let teamIndex = configuration.teams.firstIndex(where: { $0.id == team.id }) else { return }
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
        guessedWords.removeAll()
        guessedByTeam.removeAll()
        guessedInRounds.removeAll()
        explainingPlayerIndexByTeam.removeAll()
        currentTeamTurnIndex = 0
    }
    
    func getTeamScore(team: Team) -> Int {
        configuration.teams.first(where: { $0.id == team.id })?.score ?? 0
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
                addWords(words, for: player.id)
            }
        }

        configuration.teams = generatedTeams
    }
}
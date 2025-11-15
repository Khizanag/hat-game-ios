//
//  GameManager.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import Foundation
import Observation

@Observable
final class GameManager {
    var state: GameState = .welcome
    var teams: [Team] = []
    var allWords: [Word] = []
    var shuffledWords: [Word] = []
    var currentWordIndex: Int = 0
    var roundStartTime: Date?
    var roundEndTime: Date?
    var wordsPerPlayer: Int = 10
    var startingTeamIndex: Int = 0
    
    var currentRound: GameRound? {
        if case .playing(let round, _) = state {
            return round
        }
        if case .roundResults(let round) = state {
            return round
        }
        return nil
    }
    
    var currentTeamIndex: Int? {
        if case .playing(_, let index) = state {
            return index
        }
        return nil
    }
    
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
    
    func addTeam(name: String) {
        let team = Team(name: name)
        teams.append(team)
    }
    
    func addPlayer(name: String, to teamId: UUID) {
        guard let teamIndex = teams.firstIndex(where: { $0.id == teamId }) else { return }
        let player = Player(name: name, teamId: teamId)
        teams[teamIndex].players.append(player)
    }
    
    func removeTeam(_ teamId: UUID) {
        teams.removeAll { $0.id == teamId }
    }
    
    func removePlayer(_ playerId: UUID) {
        for index in teams.indices {
            teams[index].players.removeAll { $0.id == playerId }
        }
    }
    
    func addWords(_ words: [String], for playerId: UUID) {
        let newWords = words.map { Word(text: $0) }
        allWords.append(contentsOf: newWords)
    }
    
    func shuffleWords() {
        shuffledWords = allWords.shuffled()
        currentWordIndex = 0
    }
    
    func startRound(_ round: GameRound, startingTeamIndex: Int) {
        self.startingTeamIndex = startingTeamIndex
        roundStartTime = Date()
        state = .playing(round: round, currentTeamIndex: startingTeamIndex)
        resetWordGuessedState()
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
        let nextIndex = (currentIndex + 1) % teams.count
        
        if case .playing(let round, _) = state {
            state = .playing(round: round, currentTeamIndex: nextIndex)
        }
    }
    
    func finishRound() {
        roundEndTime = Date()
        if let round = currentRound {
            state = .roundResults(round: round)
        }
    }
    
    func startNextRound() {
        guard let currentRound = currentRound else { return }
        
        if currentRound == .three {
            state = .finalResults
        } else {
            let nextRound = GameRound(rawValue: currentRound.rawValue + 1)!
            let nextTeamIndex = (startingTeamIndex + 1) % teams.count
            startRound(nextRound, startingTeamIndex: nextTeamIndex)
        }
    }
    
    func updateTeamScore(teamId: UUID) {
        guard let teamIndex = teams.firstIndex(where: { $0.id == teamId }) else { return }
        teams[teamIndex].score += 1
    }
    
    func resetGame() {
        state = .welcome
        teams = []
        allWords = []
        shuffledWords = []
        currentWordIndex = 0
        roundStartTime = nil
        roundEndTime = nil
        wordsPerPlayer = 10
        startingTeamIndex = 0
    }
    
    func getTeamScore(teamId: UUID) -> Int {
        teams.first(where: { $0.id == teamId })?.score ?? 0
    }
    
    func getSortedTeamsByScore() -> [Team] {
        teams.sorted { $0.score > $1.score }
    }
    
    func getWinner() -> Team? {
        guard !teams.isEmpty else { return nil }
        let sorted = getSortedTeamsByScore()
        guard let topScore = sorted.first?.score, topScore > 0 else { return nil }
        return sorted.first
    }
}


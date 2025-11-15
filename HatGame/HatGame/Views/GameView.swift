//
//  GameView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct GameView: View {
    @Bindable var gameManager: GameManager
    @State private var timer: Timer?
    @State private var remainingSeconds: Int = 0
    @State private var showingResults: Bool = false
    @State private var showingTeamTurnResults: Bool = false
    @State private var showingNextTeam: Bool = false
    @State private var nextTeamIndex: Int?
    
    var currentTeam: Team? {
        guard let index = gameManager.currentTeamIndex, index < gameManager.teams.count else { return nil }
        return gameManager.teams[index]
    }
    
    var currentRound: GameRound? {
        gameManager.currentRound
    }
    
    var body: some View {
        ZStack {
            DesignBook.Color.Background.primary
                .ignoresSafeArea()
            
            VStack(spacing: DesignBook.Spacing.lg) {
                if let round = currentRound, let team = currentTeam {
                    GameCard {
                        VStack(spacing: DesignBook.Spacing.md) {
                            Text(round.title)
                                .font(DesignBook.Font.title3)
                                .foregroundColor(DesignBook.Color.Text.primary)
                            
                            Text(round.description)
                                .font(DesignBook.Font.body)
                                .foregroundColor(DesignBook.Color.Text.secondary)
                                .multilineTextAlignment(.center)
                            
                            Text("Current Team: \(team.name)")
                                .font(DesignBook.Font.headline)
                                .foregroundColor(DesignBook.Color.Team.color(for: gameManager.currentTeamIndex ?? 0))
                            
                            Text("Time left: \(formatTime(remainingSeconds))")
                                .font(DesignBook.Font.bodyBold)
                                .foregroundColor(DesignBook.Color.Text.accent)
                        }
                    }
                    .padding(.horizontal, DesignBook.Spacing.lg)
                    .padding(.top, DesignBook.Spacing.lg)
                    
                    if let word = gameManager.currentWord, !word.guessed {
                        GameCard {
                            VStack(spacing: DesignBook.Spacing.xl) {
                                Text(word.text)
                                    .font(DesignBook.Font.largeTitle)
                                    .foregroundColor(DesignBook.Color.Text.primary)
                                    .multilineTextAlignment(.center)
                                    .frame(minHeight: 200)
                                
                                PrimaryButton(title: "Got It!") {
                                    markAsGuessed()
                                }
                                .padding(.horizontal, DesignBook.Spacing.lg)
                            }
                        }
                        .padding(.horizontal, DesignBook.Spacing.lg)
                    } else if gameManager.allWordsGuessed {
                        GameCard {
                            VStack(spacing: DesignBook.Spacing.md) {
                                Text("🎉")
                                    .font(.system(size: 80))
                                
                                Text("All words guessed!")
                                    .font(DesignBook.Font.title2)
                                    .foregroundColor(DesignBook.Color.Text.primary)
                                
                                let timeUsed = max(gameManager.roundDuration - remainingSeconds, 0)
                                Text("Time: \(formatTime(timeUsed))")
                                    .font(DesignBook.Font.headline)
                                    .foregroundColor(DesignBook.Color.Text.secondary)
                            }
                        }
                        .padding(.horizontal, DesignBook.Spacing.lg)
                        
                        PrimaryButton(title: "Finish Round") {
                            finishRound()
                        }
                        .padding(.horizontal, DesignBook.Spacing.lg)
                    }
                    
                    GameCard {
                        VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                            HStack {
                                Text("Progress")
                                    .font(DesignBook.Font.headline)
                                    .foregroundColor(DesignBook.Color.Text.primary)
                                
                                Spacer()
                                
                                Text("\(gameManager.shuffledWords.filter { $0.guessed }.count)/\(gameManager.shuffledWords.count)")
                                    .font(DesignBook.Font.headline)
                                    .foregroundColor(DesignBook.Color.Text.accent)
                            }
                            
                            ProgressView(
                                value: Double(gameManager.shuffledWords.filter { $0.guessed }.count),
                                total: Double(gameManager.shuffledWords.count)
                            )
                            .tint(DesignBook.Color.Text.accent)
                            
                            Button(action: {
                                showingResults = true
                            }) {
                                HStack {
                                    Image(systemName: "chart.bar.fill")
                                    Text("View Results")
                                }
                                .font(DesignBook.Font.body)
                                .foregroundColor(DesignBook.Color.Text.accent)
                            }
                        }
                    }
                    .padding(.horizontal, DesignBook.Spacing.lg)
                }
                
                Spacer()
            }
        }
        .onAppear {
            gameManager.startTeamTurn()
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .onChange(of: gameManager.currentTeamIndex) { _, _ in
            restartTimer()
        }
        .sheet(isPresented: $showingResults) {
            ResultsView(gameManager: gameManager, isFinal: false)
        }
        .fullScreenCover(isPresented: $showingTeamTurnResults) {
            if let current = currentTeam,
               let currentIndex = gameManager.currentTeamIndex,
               let round = currentRound {
                let guessedWords = gameManager.getWordsGuessedInCurrentTurn(by: current.id)
                TeamTurnResultsView(
                    team: current,
                    teamIndex: currentIndex,
                    guessedWords: guessedWords,
                    round: round,
                    onContinue: {
                        showNextTeam()
                    }
                )
            }
        }
        .fullScreenCover(isPresented: $showingNextTeam) {
            Group {
                if let nextIndex = nextTeamIndex,
                   nextIndex < gameManager.teams.count,
                   let round = currentRound {
                    let nextTeam = gameManager.teams[nextIndex]
                    let wordsRemaining = gameManager.remainingWords.count
                    
                    // Safely get players - compute outside ViewBuilder
                    NextTeamViewWrapper(
                        nextTeam: nextTeam,
                        nextIndex: nextIndex,
                        round: round,
                        wordsRemaining: wordsRemaining,
                        gameManager: gameManager,
                        onContinue: {
                            proceedToNextTeam()
                        }
                    )
                } else {
                    // Fallback view if conditions aren't met
                    ZStack {
                        DesignBook.Color.Background.primary
                            .ignoresSafeArea()
                        Text("Error loading next team")
                            .foregroundColor(DesignBook.Color.Text.primary)
                    }
                }
            }
        }
    }
    
    private func startTimer() {
        stopTimer()
        remainingSeconds = gameManager.roundDuration
        guard gameManager.currentTeamIndex != nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            tickTimer()
        }
    }
    
    private func restartTimer() {
        startTimer()
    }
    
    private func tickTimer() {
        guard remainingSeconds > 0 else {
            stopTimer()
            timeExpired()
            return
        }
        remainingSeconds -= 1
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainder = seconds % 60
        return String(format: "%02d:%02d", minutes, remainder)
    }
    
    private func timeExpired() {
        if gameManager.allWordsGuessed {
            finishRound()
        } else {
            // Show results for current team's turn
            showingTeamTurnResults = true
        }
    }
    
    private func showNextTeam() {
        // Calculate next team index first
        guard let currentIndex = gameManager.currentTeamIndex else { return }
        let nextIndex = (currentIndex + 1) % gameManager.teams.count
        nextTeamIndex = nextIndex
        
        // Dismiss first cover
        showingTeamTurnResults = false
        
        // Show next team view after a brief delay to ensure smooth transition
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            showingNextTeam = true
        }
    }
    
    private func proceedToNextTeam() {
        guard nextTeamIndex != nil else { return }
        showingNextTeam = false
        gameManager.moveToNextTeam()
        gameManager.startTeamTurn()
        gameManager.currentWordIndex = 0
        nextTeamIndex = nil
        startTimer()
    }
    
    private func markAsGuessed() {
        guard let team = currentTeam else { return }
        gameManager.markWordAsGuessed(by: team.id)
        
        if gameManager.allWordsGuessed {
            stopTimer()
            finishRound()
        } else {
            gameManager.skipToNextWord()
        }
    }
    
    private func finishRound() {
        stopTimer()
        gameManager.finishRound()
    }
}

private struct NextTeamViewWrapper: View {
    let nextTeam: Team
    let nextIndex: Int
    let round: GameRound
    let wordsRemaining: Int
    let gameManager: GameManager
    let onContinue: () -> Void
    
    private var explainingPlayer: Player {
        if nextTeam.players.count >= 2 {
            return gameManager.getExplainingPlayer(for: nextIndex) ?? nextTeam.players[0]
        } else if nextTeam.players.count == 1 {
            return nextTeam.players[0]
        } else {
            return Player(name: "Player 1", teamId: nextTeam.id)
        }
    }
    
    private var guessingPlayer: Player {
        if nextTeam.players.count >= 2 {
            return gameManager.getGuessingPlayer(for: nextIndex) ?? nextTeam.players[1]
        } else if nextTeam.players.count == 1 {
            return nextTeam.players[0]
        } else {
            return Player(name: "Player 2", teamId: nextTeam.id)
        }
    }
    
    var body: some View {
        NextTeamView(
            team: nextTeam,
            teamIndex: nextIndex,
            round: round,
            wordsRemaining: wordsRemaining,
            explainingPlayer: explainingPlayer,
            guessingPlayer: guessingPlayer,
            onContinue: onContinue
        )
    }
}

#Preview {
    let manager = GameManager()
    manager.addTeam(name: "Team 1")
    manager.shuffledWords = [Word(text: "Test")]
    manager.state = .playing(round: .one, currentTeamIndex: 0)
    return GameView(gameManager: manager)
}


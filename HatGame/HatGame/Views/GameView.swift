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
    @State private var elapsedTime: TimeInterval = 0
    @State private var showingResults: Bool = false
    
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
                                
                                HStack(spacing: DesignBook.Spacing.lg) {
                                    SecondaryButton(title: "Pass") {
                                        passToNextTeam()
                                    }
                                    
                                    PrimaryButton(title: "Got It!") {
                                        markAsGuessed()
                                    }
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
                                
                                Text("Time: \(formatTime(elapsedTime))")
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
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .sheet(isPresented: $showingResults) {
            ResultsView(gameManager: gameManager, isFinal: false)
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            elapsedTime += 0.1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func markAsGuessed() {
        guard let team = currentTeam else { return }
        gameManager.markWordAsGuessed(by: team.id)
        
        if gameManager.allWordsGuessed {
            stopTimer()
            finishRound()
        } else {
            gameManager.skipToNextWord()
            if gameManager.currentWord == nil {
                passToNextTeam()
            }
        }
    }
    
    private func passToNextTeam() {
        if gameManager.allWordsGuessed {
            stopTimer()
            finishRound()
        } else {
            gameManager.moveToNextTeam()
        }
    }
    
    private func finishRound() {
        stopTimer()
        gameManager.finishRound()
    }
}

#Preview {
    let manager = GameManager()
    manager.addTeam(name: "Team 1")
    manager.shuffledWords = [Word(text: "Test")]
    manager.state = .playing(round: .one, currentTeamIndex: 0)
    return GameView(gameManager: manager)
}


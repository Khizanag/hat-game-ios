//
//  WordInputView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct WordInputView: View {
    @Bindable var gameManager: GameManager
    @State private var currentPlayerIndex: Int = 0
    @State private var wordsPerPlayer: Int = 10
    @State private var playerWords: [String] = []
    @State private var currentWord: String = ""
    
    var currentPlayer: Player? {
        guard currentPlayerIndex < allPlayers.count else { return nil }
        return allPlayers[currentPlayerIndex]
    }
    
    var allPlayers: [Player] {
        gameManager.teams.flatMap { $0.players }
    }
    
    var progress: Double {
        guard !allPlayers.isEmpty else { return 0 }
        return Double(currentPlayerIndex) / Double(allPlayers.count)
    }
    
    var body: some View {
        ZStack {
            DesignBook.Color.Background.primary
                .ignoresSafeArea()
            
            VStack(spacing: DesignBook.Spacing.lg) {
                GameCard {
                    VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                        Text("Add Words")
                            .font(DesignBook.Font.title2)
                            .foregroundColor(DesignBook.Color.Text.primary)
                        
                        if let player = currentPlayer {
                            Text("\(player.name) - Add \(wordsPerPlayer) words")
                                .font(DesignBook.Font.body)
                                .foregroundColor(DesignBook.Color.Text.secondary)
                        }
                        
                        ProgressView(value: progress)
                            .tint(DesignBook.Color.Text.accent)
                    }
                }
                .padding(.horizontal, DesignBook.Spacing.lg)
                .padding(.top, DesignBook.Spacing.lg)
                
                if currentPlayer != nil {
                    GameCard {
                        VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                            Text("Words added: \(playerWords.count)/\(wordsPerPlayer)")
                                .font(DesignBook.Font.headline)
                                .foregroundColor(DesignBook.Color.Text.primary)
                            
                            HStack {
                                TextField("Enter a word", text: $currentWord)
                                    .textFieldStyle(.plain)
                                    .font(DesignBook.Font.body)
                                    .foregroundColor(DesignBook.Color.Text.primary)
                                    .padding(DesignBook.Spacing.md)
                                    .background(DesignBook.Color.Background.secondary)
                                    .cornerRadius(DesignBook.Size.smallCardCornerRadius)
                                    .onSubmit {
                                        addWord()
                                    }
                                
                                Button(action: addWord) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(DesignBook.Color.Button.primary)
                                }
                                .disabled(currentWord.isEmpty)
                            }
                            
                            ScrollView {
                                LazyVStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
                                    ForEach(Array(playerWords.enumerated()), id: \.offset) { index, word in
                                        HStack {
                                            Text(word)
                                                .font(DesignBook.Font.body)
                                                .foregroundColor(DesignBook.Color.Text.secondary)
                                            
                                            Spacer()
                                            
                                            Button(action: {
                                                playerWords.remove(at: index)
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(DesignBook.Color.Status.error)
                                            }
                                        }
                                        .padding(DesignBook.Spacing.sm)
                                        .background(DesignBook.Color.Background.secondary)
                                        .cornerRadius(DesignBook.Size.smallCardCornerRadius)
                                    }
                                }
                            }
                            .frame(maxHeight: 300)
                        }
                    }
                    .padding(.horizontal, DesignBook.Spacing.lg)
                }
                
                Spacer()
                
                if playerWords.count >= wordsPerPlayer {
                    PrimaryButton(title: currentPlayerIndex < allPlayers.count - 1 ? "Next Player" : "Finish") {
                        saveWordsAndContinue()
                    }
                    .padding(.horizontal, DesignBook.Spacing.lg)
                    .padding(.bottom, DesignBook.Spacing.lg)
                }
            }
        }
        .onAppear {
            gameManager.wordsPerPlayer = wordsPerPlayer
            if currentPlayer != nil {
                playerWords = []
            }
        }
    }
    
    private func addWord() {
        guard !currentWord.isEmpty, playerWords.count < wordsPerPlayer else { return }
        let trimmedWord = currentWord.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedWord.isEmpty, !playerWords.contains(trimmedWord) else { return }
        playerWords.append(trimmedWord)
        currentWord = ""
    }
    
    private func saveWordsAndContinue() {
        guard let player = currentPlayer else { return }
        gameManager.addWords(playerWords, for: player.id)
        
        if currentPlayerIndex < allPlayers.count - 1 {
            currentPlayerIndex += 1
            playerWords = []
        } else {
            gameManager.state = .randomization
        }
    }
}

#Preview {
    let manager = GameManager()
    manager.addTeam(name: "Team 1")
    manager.addPlayer(name: "Player 1", to: manager.teams[0].id)
    return WordInputView(gameManager: manager)
}


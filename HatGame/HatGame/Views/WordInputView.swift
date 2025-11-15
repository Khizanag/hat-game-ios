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
    @State private var playerWords: [String] = []
    @State private var currentWord: String = ""
    @FocusState private var isWordFieldFocused: Bool
    
    var currentPlayer: Player? {
        guard currentPlayerIndex < allPlayers.count else { return nil }
        return allPlayers[currentPlayerIndex]
    }
    
    var nextPlayerName: String? {
        let nextIndex = currentPlayerIndex + 1
        guard nextIndex < allPlayers.count else { return nil }
        return allPlayers[nextIndex].name
    }
    
    var wordsPerPlayer: Int {
        gameManager.wordsPerPlayer
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
                    if playerWords.count < wordsPerPlayer {
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
                                        .focused($isWordFieldFocused)
                                        .onSubmit {
                                            addWord()
                                        }
                                    
                                    Button(action: addWord) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 32))
                                            .foregroundColor(DesignBook.Color.Button.primary)
                                    }
                                    .disabled(currentWord.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
                    } else {
                        GameCard {
                            VStack(spacing: DesignBook.Spacing.md) {
                                Text("All words added!")
                                    .font(DesignBook.Font.headline)
                                    .foregroundColor(DesignBook.Color.Text.primary)
                                
                                if let nextPlayerName {
                                    Text("You're ready. Pass the device to \(nextPlayerName) for their turn.")
                                        .font(DesignBook.Font.body)
                                        .foregroundColor(DesignBook.Color.Text.secondary)
                                        .multilineTextAlignment(.center)
                                } else {
                                    Text("All players have entered their words. You can finish this step now.")
                                        .font(DesignBook.Font.body)
                                        .foregroundColor(DesignBook.Color.Text.secondary)
                                        .multilineTextAlignment(.center)
                                }
                            }
                        }
                        .padding(.horizontal, DesignBook.Spacing.lg)
                    }
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
            if currentPlayer != nil {
                playerWords = []
                isWordFieldFocused = true
            }
        }
    }
    
    private func addWord() {
        let trimmedWord = currentWord.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedWord.isEmpty, playerWords.count < wordsPerPlayer else { return }
        guard !trimmedWord.isEmpty, !playerWords.contains(trimmedWord) else { return }
        playerWords.append(trimmedWord)
        currentWord = ""
        isWordFieldFocused = true
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


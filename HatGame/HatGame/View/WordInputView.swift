//
//  WordInputView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct WordInputView: View {
    @Environment(GameManager.self) private var gameManager
    @Environment(AppConfiguration.self) private var appConfiguration
    @Environment(Navigator.self) private var navigator
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
            backgroundLayer
            content
        }
        .onAppear {
            prepareCurrentPlayer()
        }
        .onChange(of: currentPlayerIndex) { _, _ in
            prepareCurrentPlayer()
        }
        .navigationTitle("Add Words")
        .navigationBarTitleDisplayMode(.inline)
        .closeButtonToolbar()
    }
}

private extension WordInputView {
    var backgroundLayer: some View {
        DesignBook.Color.Background.primary
            .ignoresSafeArea()
    }
    
    var content: some View {
        VStack(spacing: DesignBook.Spacing.lg) {
            headerCard
            wordEntrySection
            Spacer()
            actionButton
        }
    }
    
    var headerCard: some View {
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
    }
    
    @ViewBuilder
    var wordEntrySection: some View {
        if currentPlayer != nil {
            if playerWords.count < wordsPerPlayer {
                wordInputCard
            } else {
                completionCard
            }
        }
    }
    
    var wordInputCard: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                Text("Words added: \(playerWords.count)/\(wordsPerPlayer)")
                    .font(DesignBook.Font.headline)
                    .foregroundColor(DesignBook.Color.Text.primary)
                
                HStack {
                    wordTextField
                    addWordButton
                }
                
                wordsList
            }
        }
        .padding(.horizontal, DesignBook.Spacing.lg)
    }
    
    var wordTextField: some View {
        TextField("Enter a word", text: $currentWord)
            .textFieldStyle(.plain)
            .font(DesignBook.Font.body)
            .foregroundColor(DesignBook.Color.Text.primary)
            .padding(DesignBook.Spacing.md)
            .background(DesignBook.Color.Background.secondary)
            .cornerRadius(DesignBook.Size.smallCardCornerRadius)
            .focused($isWordFieldFocused)
            .onSubmit {
                handleAddWord()
            }
    }
    
    var addWordButton: some View {
        Button(action: handleAddWord) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 32))
                .foregroundColor(DesignBook.Color.Button.primary)
        }
        .disabled(currentWord.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
    
    var wordsList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
                ForEach(Array(playerWords.enumerated()), id: \.offset) { index, word in
                    HStack {
                        Text(word)
                            .font(DesignBook.Font.body)
                            .foregroundColor(DesignBook.Color.Text.secondary)
                        
                        Spacer()
                        
                        Button {
                            playerWords.remove(at: index)
                            persistDefaultWords()
                        } label: {
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
    
    var completionCard: some View {
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
    
    @ViewBuilder
    var actionButton: some View {
        if playerWords.count >= wordsPerPlayer {
            PrimaryButton(title: actionButtonTitle) {
                handleSaveWords()
            }
            .padding(.horizontal, DesignBook.Spacing.lg)
            .padding(.bottom, DesignBook.Spacing.lg)
        }
    }
    
    var actionButtonTitle: String {
        currentPlayerIndex < allPlayers.count - 1 ? "Next Player" : "Finish"
    }
    
    func prepareCurrentPlayer() {
        guard currentPlayer != nil else { return }
        playerWords = []
        loadDefaultWordsIfNeeded()
        isWordFieldFocused = true
    }
    
    func loadDefaultWordsIfNeeded() {
        guard let player = currentPlayer else { return }
        guard playerWords.isEmpty else { return }
        if appConfiguration.isTestMode, let defaults = gameManager.defaultWords(for: player.id) {
            playerWords = defaults
        }
    }
    
    func persistDefaultWords() {
        guard let player = currentPlayer, appConfiguration.isTestMode else { return }
        gameManager.updateDefaultWords(playerWords, for: player.id)
    }
    
    func handleAddWord() {
        let trimmedWord = currentWord.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedWord.isEmpty, playerWords.count < wordsPerPlayer else { return }
        guard !playerWords.contains(trimmedWord) else { return }
        playerWords.append(trimmedWord)
        persistDefaultWords()
        currentWord = ""
        isWordFieldFocused = true
    }
    
    func handleSaveWords() {
        guard let player = currentPlayer else { return }
        gameManager.addWords(playerWords, for: player.id)
        
        if currentPlayerIndex < allPlayers.count - 1 {
            currentPlayerIndex += 1
            playerWords = []
        } else {
            navigator.push(.randomization)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        Page.wordInput.view()
    }
    .environment(GameManager())
    .environment(AppConfiguration())
}


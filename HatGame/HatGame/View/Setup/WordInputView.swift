//
//  WordInputView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct WordInputView: View {
    @Environment(GameManager.self) private var gameManager
    private let appConfiguration = AppConfiguration.shared
    @Environment(Navigator.self) private var navigator

    @State private var currentPlayerIndex: Int = 0
    @State private var playerWords: [String] = []
    @State private var currentWord: String = ""
    @FocusState private var isWordFieldFocused: Bool

    private var currentPlayer: Player? {
        guard currentPlayerIndex < allPlayers.count else { return nil }
        return allPlayers[currentPlayerIndex]
    }

    private var nextPlayerName: String? {
        let nextIndex = currentPlayerIndex + 1
        guard nextIndex < allPlayers.count else { return nil }
        return allPlayers[nextIndex].name
    }

    private var wordsPerPlayer: Int {
        gameManager.configuration.wordsPerPlayer
    }

    private var allPlayers: [Player] {
        gameManager.configuration.teams.flatMap { $0.players }
    }

    private var progress: Double {
        guard !allPlayers.isEmpty else { return 0 }
        return Double(currentPlayerIndex) / Double(allPlayers.count)
    }

    var body: some View {
        content
            .setDefaultStyle(title: "Add Words")
            .onAppear {
                prepareCurrentPlayer()
            }
            .onChange(of: currentPlayerIndex) { _, _ in
                prepareCurrentPlayer()
            }
    }
}

private extension WordInputView {
    var content: some View {
        ScrollView {
            VStack(spacing: DesignBook.Spacing.lg) {
                headerCard
                wordEntrySection
            }
            .paddingHorizontalDefault()
            .padding(.bottom, DesignBook.Spacing.xxl)
        }
        .safeAreaInset(edge: .bottom) {
            actionButton
                .paddingHorizontalDefault()
        }
    }

    var headerCard: some View {
        HeaderCard(
            title: "Add Words",
            description: currentPlayer.map { "\($0.name) - Add \(wordsPerPlayer) words" }
        ) {
            ProgressView(value: progress)
                .tint(DesignBook.Color.Text.accent)
        }
    }

    @ViewBuilder
    var wordEntrySection: some View {
        if currentPlayer != nil {
            if playerWords.count < wordsPerPlayer {
                wordInputCard
            } else {
                VStack(spacing: DesignBook.Spacing.md) {
                    completionCard
                    wordsListCard
                }
            }
        }
    }

    var wordInputCard: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                Text(String(format: String(localized: "Words added: %lld/%lld"), playerWords.count, wordsPerPlayer))
                    .font(DesignBook.Font.headline)
                    .foregroundColor(DesignBook.Color.Text.primary)

                HStack {
                    wordTextField
                    addWordButton
                }

                wordsList
            }
        }
    }

    var wordTextField: some View {
        TextField("wordInput.enterWord", text: $currentWord)
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
    }

    var completionCard: some View {
        GameCard {
            VStack(spacing: DesignBook.Spacing.md) {
                Text("wordInput.allWordsAdded")
                    .font(DesignBook.Font.headline)
                    .foregroundColor(DesignBook.Color.Text.primary)

                if let nextPlayerName {
                    Text(String(format: String(localized: "You're ready. Pass the device to %@ for their turn."), nextPlayerName))
                        .font(DesignBook.Font.body)
                        .foregroundColor(DesignBook.Color.Text.secondary)
                        .multilineTextAlignment(.center)
                } else {
                    Text("wordInput.allPlayersEntered")
                        .font(DesignBook.Font.body)
                        .foregroundColor(DesignBook.Color.Text.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }

    var wordsListCard: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                Text(String(format: String(localized: "Words added: %lld/%lld"), playerWords.count, wordsPerPlayer))
                    .font(DesignBook.Font.headline)
                    .foregroundColor(DesignBook.Color.Text.primary)

                wordsList
            }
        }
    }

    @ViewBuilder
    var actionButton: some View {
        // TODO: Uncomment
//        if playerWords.count >= wordsPerPlayer {
            PrimaryButton(title: actionButtonTitle, icon: actionButtonIcon) {
                handleSaveWords()
            }
//        }
    }

    var actionButtonTitle: String {
        currentPlayerIndex < allPlayers.count - 1 ? "Next Player" : "Finish"
    }

    var actionButtonIcon: String {
        currentPlayerIndex < allPlayers.count - 1 ? "arrow.right.circle.fill" : "checkmark.circle.fill"
    }

    func prepareCurrentPlayer() {
        // TODO: Uncomment
        // isWordFieldFocused = true
    }

    func handleAddWord() {
        let trimmedWord = currentWord.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedWord.isEmpty, playerWords.count < wordsPerPlayer else { return }
        guard !playerWords.contains(trimmedWord) else { return }
        playerWords.append(trimmedWord)
        currentWord = ""
        isWordFieldFocused = true
    }

    func handleSaveWords() {
        guard let player = currentPlayer else { return }
        gameManager.addWords(playerWords, by: player)

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
}

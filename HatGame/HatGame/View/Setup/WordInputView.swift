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
    @State private var shouldScrollToTextField: Bool = false
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
            .setDefaultStyle(title: String(localized: "wordInput.title"))
            .onAppear {
                prepareCurrentPlayer()
            }
            .onChange(of: currentPlayerIndex) { _, _ in
                prepareCurrentPlayer()
            }
    }
}

// MARK: - Private
private extension WordInputView {
    var content: some View {
        ScrollViewReader { proxy in
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
            .onAppear {
                scrollToTextField(proxy: proxy, delay: 0.5)
            }
            .onChange(of: isWordFieldFocused) { _, isFocused in
                if isFocused {
                    scrollToTextField(proxy: proxy, delay: 0.2)
                }
            }
            .onChange(of: playerWords.count) { _, _ in
                scrollToTextField(proxy: proxy, delay: 0.15)
            }
            .onChange(of: currentPlayerIndex) { _, _ in
                scrollToTextField(proxy: proxy, delay: 0.4)
            }
            .onChange(of: shouldScrollToTextField) { _, shouldScroll in
                if shouldScroll {
                    scrollToTextField(proxy: proxy, delay: 0.1)
                    shouldScrollToTextField = false
                }
            }
        }
    }

    func scrollToTextField(proxy: ScrollViewProxy, delay: TimeInterval = 0.2) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.easeInOut(duration: 0.3)) {
                proxy.scrollTo("wordTextField", anchor: .center)
            }
        }
    }

    var headerCard: some View {
        HeaderCard(
            title: String(localized: "wordInput.title"),
            description: currentPlayer.map { player in
                String(
                    format: String(localized: "wordInput.playerInstruction"),
                    player.name,
                    wordsPerPlayer
                )
            }
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
            VStack(alignment: .leading, spacing: DesignBook.Spacing.lg) {
                progressHeader

                if !playerWords.isEmpty {
                    wordsList
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                wordTextField
            }
        }
    }

    var progressHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.xs) {
                Text(String(format: String(localized: "wordInput.wordsAddedProgress"), playerWords.count, wordsPerPlayer))
                    .font(DesignBook.Font.headline)
                    .foregroundColor(DesignBook.Color.Text.primary)

                ProgressView(value: Double(playerWords.count), total: Double(wordsPerPlayer))
                    .tint(DesignBook.Color.Text.accent)
                    .progressViewStyle(.linear)
            }

            Spacer()

            Text("\(playerWords.count)/\(wordsPerPlayer)")
                .font(DesignBook.Font.title3)
                .foregroundColor(DesignBook.Color.Text.accent)
        }
    }

    var wordTextField: some View {
        HStack(spacing: DesignBook.Spacing.sm) {
            TextField("wordInput.enterWord", text: $currentWord)
                .textFieldStyle(.plain)
                .font(DesignBook.Font.body)
                .foregroundColor(DesignBook.Color.Text.primary)
                .padding(DesignBook.Spacing.md)
                .background(DesignBook.Color.Background.secondary)
                .cornerRadius(DesignBook.Size.smallCardCornerRadius)
                .focused($isWordFieldFocused)
                .onSubmit {
                    if !isAddWordButtonDisabled {
                        handleAddWord()
                        shouldScrollToTextField = true
                    }
                }
                .id("wordTextField")

            if !currentWord.isEmpty {
                Button {
                    handleAddWord()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(DesignBook.Color.Button.primary)
                }
                .disabled(isAddWordButtonDisabled)
                .opacity(isAddWordButtonDisabled ? DesignBook.Opacity.disabled : DesignBook.Opacity.enabled)
            }
        }
    }

    var wordsList: some View {
        VStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
            ForEach(playerWords.indices, id: \.self) { index in
                wordRow(at: index)
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
            }
        }
    }

    func wordRow(at index: Int) -> some View {
        HStack(spacing: DesignBook.Spacing.sm) {
            Text("\(index + 1)")
                .font(DesignBook.Font.caption)
                .foregroundColor(DesignBook.Color.Text.tertiary)
                .frame(width: 24, height: 24)
                .background(DesignBook.Color.Background.secondary)
                .clipShape(Circle())

            Text(playerWords[index])
                .font(DesignBook.Font.body)
                .foregroundColor(DesignBook.Color.Text.primary)

            Spacer()

            Button {
                removeWord(at: index)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(DesignBook.Color.Status.error.opacity(0.7))
            }
            .buttonStyle(.plain)
        }
        .padding(DesignBook.Spacing.md)
        .background(DesignBook.Color.Background.secondary)
        .cornerRadius(DesignBook.Size.smallCardCornerRadius)
    }

    var completionCard: some View {
        GameCard {
            VStack(spacing: DesignBook.Spacing.md) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(DesignBook.Color.Status.success)

                Text("wordInput.allWordsAdded")
                    .font(DesignBook.Font.title3)
                    .foregroundColor(DesignBook.Color.Text.primary)

                if let nextPlayerName {
                    Text(String(format: String(localized: "wordInput.readyToPass"), nextPlayerName))
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
            .padding(DesignBook.Spacing.lg)
        }
    }

    var wordsListCard: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                Text(String(format: String(localized: "wordInput.wordsAddedProgress"), playerWords.count, wordsPerPlayer))
                    .font(DesignBook.Font.headline)
                    .foregroundColor(DesignBook.Color.Text.primary)

                wordsList
            }
        }
    }

    @ViewBuilder
    var actionButton: some View {
        if playerWords.count < wordsPerPlayer {
            PrimaryButton(title: String(localized: "wordInput.addWord"), icon: "plus.circle.fill") {
                handleAddWord()
            }
            .disabled(isAddWordButtonDisabled)
            .opacity(isAddWordButtonDisabled ? DesignBook.Opacity.disabled : DesignBook.Opacity.enabled)
        } else {
            PrimaryButton(title: actionButtonTitle, icon: actionButtonIcon) {
                handleSaveWords()
            }
        }
    }

    var isAddWordButtonDisabled: Bool {
        currentWord.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var actionButtonTitle: String {
        currentPlayerIndex < allPlayers.count - 1
            ? String(localized: "wordInput.nextPlayer")
            : String(localized: "wordInput.finish")
    }

    var actionButtonIcon: String {
        currentPlayerIndex < allPlayers.count - 1 ? "arrow.right.circle.fill" : "checkmark.circle.fill"
    }

    func prepareCurrentPlayer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isWordFieldFocused = true
        }
    }

    func removeWord(at index: Int) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            playerWords.remove(at: index)
        }
    }

    func handleAddWord() {
        let trimmedWord = currentWord.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedWord.isEmpty, playerWords.count < wordsPerPlayer else { return }
        guard !playerWords.contains(trimmedWord) else { return }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            playerWords.append(trimmedWord)
        }
        
        currentWord = ""
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isWordFieldFocused = true
        }
    }

    func handleSaveWords() {
        guard let currentPlayer else { return }
        gameManager.addWords(playerWords, by: currentPlayer)

        if currentPlayerIndex != allPlayers.indices.last {
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
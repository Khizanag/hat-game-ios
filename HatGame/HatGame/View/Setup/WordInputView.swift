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
    @State private var isAutoFilling: Bool = false
    @FocusState private var isWordFieldFocused: Bool
    @Namespace private var addButtonNamespace

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
                Group {
                    if (isWordFieldFocused && playerWords.count < wordsPerPlayer) {
                        HStack {
                            Spacer()
                            floatingAddButton
                        }
                    } else {
                        actionButton
                    }
                }
                .paddingHorizontalDefault()
                .padding(.bottom, DesignBook.Spacing.sm)
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

                autoFillButton

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
                Text("wordInput.wordsAdded")
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

    var autoFillButton: some View {
        Button {
            handleAutoFillWords()
        } label: {
            HStack(spacing: DesignBook.Spacing.sm) {
                Image(systemName: isAutoFilling ? "sparkles" : "wand.and.stars")
                    .font(DesignBook.Font.body)
                    .fontWeight(.semibold)
                    .symbolEffect(.pulse, options: .repeating, isActive: isAutoFilling)

                Text(isAutoFilling ? "wordInput.autoFill.thinking" : "wordInput.autoFill")
                    .font(DesignBook.Font.body)
                    .fontWeight(.medium)
            }
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        DesignBook.Color.Text.accent,
                        DesignBook.Color.Text.accent.opacity(0.8)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .padding(.vertical, DesignBook.Spacing.md)
            .padding(.horizontal, DesignBook.Spacing.lg)
            .frame(maxWidth: .infinity)
            .background {
                ZStack {
                    // Glass effect background
                    RoundedRectangle(cornerRadius: DesignBook.Size.cardCornerRadius)
                        .fill(.ultraThinMaterial)

                    // Gradient overlay for glass effect
                    RoundedRectangle(cornerRadius: DesignBook.Size.cardCornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    DesignBook.Color.Text.accent.opacity(0.15),
                                    DesignBook.Color.Text.accent.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    // Border for glass effect
                    RoundedRectangle(cornerRadius: DesignBook.Size.cardCornerRadius)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    DesignBook.Color.Text.accent.opacity(0.3),
                                    DesignBook.Color.Text.accent.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                }
            }
            .shadow(color: DesignBook.Color.Text.accent.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .disabled(playerWords.count >= wordsPerPlayer || isAutoFilling)
        .opacity((playerWords.count >= wordsPerPlayer || isAutoFilling) ? DesignBook.Opacity.disabled : DesignBook.Opacity.enabled)
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
                if !isAddWordButtonDisabled {
                    handleAddWord()
                    shouldScrollToTextField = true
                }
            }
            .id("wordTextField")
    }

    var wordsList: some View {
        VStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
            ForEach(playerWords.indices, id: \.self) { index in
                wordRow(at: index)
                    .transition(
                        .asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        )
                    )
            }
        }
    }

    func wordRow(at index: Int) -> some View {
        HStack(spacing: DesignBook.Spacing.sm) {
            Text("\(index + 1)")
                .font(DesignBook.Font.caption)
                .foregroundColor(DesignBook.Color.Text.tertiary)
                .frame(width: DesignBook.Size.badgeSize, height: DesignBook.Size.badgeSize)
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
                    .font(DesignBook.IconFont.small)
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
                    .font(DesignBook.IconFont.extraLarge)
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
            .matchedGeometryEffect(id: "addButton", in: addButtonNamespace)
        } else {
            PrimaryButton(title: actionButtonTitle, icon: actionButtonIcon) {
                handleSaveWords()
            }
        }
    }

    var floatingAddButton: some View {
        Button(action: handleAddWord) {
            Image(systemName: "plus.circle.fill")
                .font(DesignBook.IconFont.large)
                .frame(width: DesignBook.Size.floatingButtonSize, height: DesignBook.Size.floatingButtonSize)
        }
        .buttonStyle(.glassProminent)
        .disabled(isAddWordButtonDisabled)
        .opacity(isAddWordButtonDisabled ? DesignBook.Opacity.disabled : DesignBook.Opacity.enabled)
        .matchedGeometryEffect(id: "addButton", in: addButtonNamespace)
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
        _ = withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
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

    func handleAutoFillWords() {
        let remainingCount = wordsPerPlayer - playerWords.count
        guard remainingCount > 0 else { return }
        guard !isAutoFilling else { return }

        // Dismiss keyboard first for better visibility
        isWordFieldFocused = false

        var excludedWords = Set(playerWords)

        // If duplicates not allowed, exclude words used by other players
        if !appConfiguration.allowDuplicateWords {
            let usedWords = gameManager.getAllUsedWords()
            excludedWords.formUnion(usedWords)
        }

        // Get available words from database
        let availableWords = WordDatabase.words.filter { !excludedWords.contains($0) }

        // Shuffle and take what we need
        let newWords = Array(availableWords.shuffled().prefix(remainingCount))

        // Start AI thinking animation
        withAnimation(.easeInOut(duration: 0.3)) {
            isAutoFilling = true
        }

        // Add words one by one with delay for AI thinking effect
        for (index, word) in newWords.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.3 + 0.5) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    playerWords.append(word)
                }

                // Stop animation after last word
                if index == newWords.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isAutoFilling = false
                        }
                    }
                }
            }
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

//
//  GameView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct GameView: View {
    @Environment(GameManager.self) private var gameManager
    @Environment(Navigator.self) private var navigator

    @State private var timer: Timer?
    @State private var remainingSeconds: Int = 0
    @State private var showingGiveUpConfirmation: Bool = false
    @State private var isPaused: Bool = false

    let round: GameRound

    @State private var guessedWords: [Word] = []

    @State private var word: Word = .init(text: "")

    // MARK: - Body
    var body: some View {
        content
            .setDefaultBackground()
            .overlay {
                if isPaused {
                    pauseOverlay
                }
            }
            .toolbar { gameToolbar }
            .onAppear {
                word = gameManager.currentWord!
                startTimer()
            }
            .onDisappear {
                stopTimer()
            }
            .alert("Give Up?", isPresented: $showingGiveUpConfirmation) {
                giveUpAlertActions
            } message: {
                giveUpAlertMessage
            }
            .navigationBarBackButtonHidden()
            .onChange(of: gameManager.currentWord) { oldValue, newValue in
                if let newValue {
                    word = newValue
                } else {
                    navigator.push(.teamTurnResults(guessedWords: guessedWords))
                }
            }
    }
}

// MARK: - Components
private extension GameView {
    var content: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            roundInfoCard

            wordSection

            progressCard
        }
        .padding(.top, DesignBook.Spacing.lg)
        .paddingHorizontalDefault()
    }
    
    @ToolbarContentBuilder
    var gameToolbar: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(formatTime(remainingSeconds))
                .font(DesignBook.Font.title3)
                .foregroundColor(DesignBook.Color.Text.accent)
                .monospacedDigit()
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                togglePause()
            } label: {
                Image(systemName: isPaused ? "play.fill" : "pause.fill")
                    .foregroundColor(DesignBook.Color.Text.primary)
            }
        }
        
        ToolbarItem(placement: .cancellationAction) {
            DestructiveButton(
                action: {
                    showingGiveUpConfirmation = true
                },
                label: {
                    Label("Give up", systemImage: "hand.raised.fill")
                }
            )
        }
    }

    var roundInfoCard: some View {
        HeaderCard(
            title: round.title,
            description: round.description
        ) {
            Text("Current Team: \(gameManager.currentTeam.name)")
                .font(DesignBook.Font.headline)
                .foregroundColor(gameManager.currentTeam.color)
        }
    }

    @ViewBuilder
    var wordSection: some View {
        if let word = gameManager.currentWord {
            activeWordCard(for: word)
        }
    }

    func activeWordCard(for word: Word) -> some View {
        GameCard {
            VStack(spacing: 0) {
                Spacer()

                Text(word.text)
                    .font(DesignBook.Font.largeTitle)
                    .foregroundColor(DesignBook.Color.Text.primary)
                    .multilineTextAlignment(.center)

                Spacer()

                PrimaryButton(title: "Got It!", icon: "checkmark.circle.fill") {
                    markAsGuessed()
                }
            }
        }
    }

    var progressCard: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                let passedWordCount = gameManager.configuration.words.count - gameManager.remainingWordCount
                let totalWordsCount = gameManager.configuration.words.count

                HStack {
                    Text("Progress")
                        .font(DesignBook.Font.headline)
                        .foregroundColor(DesignBook.Color.Text.primary)

                    Spacer()

                    Text("\(passedWordCount)/\(totalWordsCount)")
                        .font(DesignBook.Font.headline)
                        .foregroundColor(DesignBook.Color.Text.accent)
                }

                ProgressView(
                    value: Double(passedWordCount),
                    total: Double(totalWordsCount)
                )
                .tint(DesignBook.Color.Text.accent)
            }
        }
    }

    var pauseOverlay: some View {
        ZStack {
            Rectangle()
                .fill(.thinMaterial)
                .ignoresSafeArea()

            VStack(spacing: DesignBook.Spacing.xl) {
                Image(systemName: "pause.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(DesignBook.Color.Text.primary)

                Text("Paused")
                    .font(DesignBook.Font.largeTitle)
                    .foregroundColor(DesignBook.Color.Text.primary)

                PrimaryButton(title: "Continue", icon: "play.fill") {
                    togglePause()
                }
                .frame(width: 216)
            }
        }
    }

    var timeUsed: Int {
        max(gameManager.configuration.roundDuration - remainingSeconds, 0)
    }

    @ViewBuilder
    var giveUpAlertActions: some View {
        Button("Cancel", role: .cancel) {
            showingGiveUpConfirmation = false
        }
        Button("Give Up", role: .destructive) {
            giveUpWord()
            showingGiveUpConfirmation = false
        }
    }

    var giveUpAlertMessage: some View {
        Text("Are you sure you want to skip this word? It will remain available for other teams.")
    }
}

// MARK: - Private functions
private extension GameView {
    func startTimer() {
        stopTimer()
        isPaused = false
        // Get remaining time for this team, or use full duration
        // TODO: Implement
        remainingSeconds = /*gameManager.getRemainingTime(for: team) ??*/ gameManager.configuration.roundDuration
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            tickTimer()
        }
    }

    func tickTimer() {
        guard !isPaused else { return }
        guard remainingSeconds > 0 else {
            stopTimer()
            timeExpired()
            return
        }
        remainingSeconds -= 1
    }

    func togglePause() {
        withAnimation {
            isPaused.toggle()
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainder = seconds % 60
        return String(format: "%02d:%02d", minutes, remainder)
    }

    func timeExpired() {
        stopTimer()
        showTeamTurnResults()
    }

    func showTeamTurnResults() {
        // Save remaining time for this team
        //        gameManager.saveRemainingTime(remainingSeconds, for: team)
        navigator.push(.teamTurnResults(guessedWords: guessedWords))
    }

    func markAsGuessed() {
        guessedWords.append(word)
        gameManager.commitWordGuess()
    }

    func giveUpWord() {
        finishRound()
    }

    func finishRound() {
        stopTimer()

        navigator.push(.teamTurnResults(guessedWords: guessedWords))
    }
}

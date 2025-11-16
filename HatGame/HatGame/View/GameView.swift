//
//  GameView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct GameView: View {
    let round: GameRound
    let teamIndex: Int

    @Environment(GameManager.self) private var gameManager
    @Environment(Navigator.self) private var navigator
    @State private var timer: Timer?
    @State private var remainingSeconds: Int = 0
    @State private var showingTeamTurnResults: Bool = false
    @State private var showingNextTeam: Bool = false
    @State private var nextTeamIndex: Int?
    @State private var nextTeamRound: GameRound?
    @State private var showingGiveUpConfirmation: Bool = false
    @State private var isPaused: Bool = false

    var currentTeam: Team? {
        guard teamIndex < gameManager.teams.count else { return nil }
        return gameManager.teams[teamIndex]
    }

    var body: some View {
        content
            .setDefaultBackground()
            .overlay {
                if isPaused {
                    pauseOverlay
                }
            }
            .toolbar {
                if !isPaused {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            withAnimation {
                                togglePause()
                            }
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
            }
            .onAppear {
                gameManager.startTeamTurn()
                startTimer()
            }
            .onDisappear {
                stopTimer()
            }
            .onChange(of: teamIndex) { _, _ in
                restartTimer()
            }
            .alert("Give Up?", isPresented: $showingGiveUpConfirmation) {
                giveUpAlertActions
            } message: {
                giveUpAlertMessage
            }
            .fullScreenCover(isPresented: $showingTeamTurnResults) {
                teamTurnResultsContent
            }
            .fullScreenCover(isPresented: $showingNextTeam) {
                nextTeamContent
            }
            .navigationBarBackButtonHidden()
    }
}

private extension GameView {
    var content: some View {
        VStack(spacing: DesignBook.Spacing.lg) {
            currentTeamSection
        }
    }

    @ViewBuilder
    var currentTeamSection: some View {
        if let team = currentTeam {
            VStack(spacing: DesignBook.Spacing.lg) {
                roundInfoCard(for: team)

                Spacer(minLength: 0)

                wordSection

                Spacer(minLength: 0)

                progressCard
            }
            .padding(.top, DesignBook.Spacing.lg)
        }
    }

    func roundInfoCard(for team: Team) -> some View {
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
                    .foregroundColor(DesignBook.Color.Team.color(for: teamIndex))

                Text("Time left: \(formatTime(remainingSeconds))")
                    .font(DesignBook.Font.bodyBold)
                    .foregroundColor(DesignBook.Color.Text.accent)
            }
        }
        .padding(.horizontal, DesignBook.Spacing.lg)
    }

    @ViewBuilder
    var wordSection: some View {
        if let word = gameManager.currentWord, !word.guessed {
            activeWordCard(for: word)
        } else if gameManager.allWordsGuessed {
            allWordsGuessedSection
        }
    }

    func activeWordCard(for word: Word) -> some View {
        GameCard {
            VStack(spacing: DesignBook.Spacing.xl) {
                Text(word.text)
                    .font(DesignBook.Font.largeTitle)
                    .foregroundColor(DesignBook.Color.Text.primary)
                    .multilineTextAlignment(.center)
                    .frame(minHeight: 200)

                HStack(spacing: DesignBook.Spacing.md) {
                    // TODO: Remove stack
                    PrimaryButton(title: "Got It!") {
                        markAsGuessed()
                    }
                }
                .padding(.horizontal, DesignBook.Spacing.sm)
            }
        }
        .padding(.horizontal, DesignBook.Spacing.lg)
    }

    var allWordsGuessedSection: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            GameCard {
                VStack(spacing: DesignBook.Spacing.md) {
                    Text("🎉")
                        .font(.system(size: 80))

                    Text("All words guessed!")
                        .font(DesignBook.Font.title2)
                        .foregroundColor(DesignBook.Color.Text.primary)

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
    }

    var progressCard: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                HStack {
                    Text("Progress")
                        .font(DesignBook.Font.headline)
                        .foregroundColor(DesignBook.Color.Text.primary)

                    Spacer()

                    Text("\(guessedWordsCount)/\(totalWordsCount)")
                        .font(DesignBook.Font.headline)
                        .foregroundColor(DesignBook.Color.Text.accent)
                }

                ProgressView(
                    value: Double(guessedWordsCount),
                    total: Double(totalWordsCount)
                )
                .tint(DesignBook.Color.Text.accent)
            }
        }
        .padding(.horizontal, DesignBook.Spacing.lg)
        .padding(.bottom, DesignBook.Spacing.lg)
    }

    var missingTeamView: some View {
        Text("Team not found")
            .font(DesignBook.Font.body)
            .foregroundColor(DesignBook.Color.Text.secondary)
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

                Text("Time remaining: \(formatTime(remainingSeconds))")
                    .font(DesignBook.Font.headline)
                    .foregroundColor(DesignBook.Color.Text.secondary)

                PrimaryButton(title: "Continue") {
                    togglePause()
                }
                .frame(width: 200)
            }
        }
    }

    var guessedWordsCount: Int {
        gameManager.shuffledWords.filter { $0.guessed }.count
    }

    var totalWordsCount: Int {
        gameManager.shuffledWords.count
    }

    var timeUsed: Int {
        max(gameManager.roundDuration - remainingSeconds, 0)
    }

    @ViewBuilder
    var teamTurnResultsContent: some View {
        if let current = currentTeam {
            let guessedWords = gameManager.getWordsGuessedInCurrentTurn(by: current.id)
            TeamTurnResultsView(
                team: current,
                teamIndex: teamIndex,
                guessedWords: guessedWords,
                round: round,
                onContinue: {
                    showNextTeam()
                }
            )
        }
    }

    @ViewBuilder
    var nextTeamContent: some View {
        if let nextIndex = nextTeamIndex,
           nextIndex < gameManager.teams.count,
           let round = nextTeamRound {
            NextTeamViewWrapper(
                nextTeam: gameManager.teams[nextIndex],
                nextIndex: nextIndex,
                round: round,
                wordsRemaining: gameManager.remainingWords.count,
                gameManager: gameManager,
                onContinue: {
                    proceedToNextTeam()
                }
            )
        } else {
            nextTeamErrorView
        }
    }

    var nextTeamErrorView: some View {
        ZStack {
            DesignBook.Color.Background.primary
                .ignoresSafeArea()
            Text("Error loading next team")
                .foregroundColor(DesignBook.Color.Text.primary)
        }
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

    func startTimer() {
        stopTimer()
        isPaused = false
        remainingSeconds = gameManager.roundDuration
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            tickTimer()
        }
    }

    func restartTimer() {
        startTimer()
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
        isPaused.toggle()
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
        if gameManager.allWordsGuessed {
            finishRound()
        } else {
            showingTeamTurnResults = true
        }
    }

    func showNextTeam() {
        let nextIndex = (teamIndex + 1) % gameManager.teams.count
        nextTeamIndex = nextIndex
        nextTeamRound = round
        showingTeamTurnResults = false

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000)
            showingNextTeam = true
        }
    }

    func proceedToNextTeam() {
        guard let nextIndex = nextTeamIndex else { return }
        showingNextTeam = false
        gameManager.currentTeamIndex = nextIndex
        gameManager.startTeamTurn()
        gameManager.currentWordIndex = 0
        nextTeamIndex = nil
        nextTeamRound = nil
        navigator.replace(with: .playing(round: round, currentTeamIndex: nextIndex))
    }

    func markAsGuessed() {
        guard let team = currentTeam else { return }
        gameManager.markWordAsGuessed(by: team.id)

        if gameManager.allWordsGuessed {
            stopTimer()
            finishRound()
        } else {
            gameManager.skipToNextWord()
        }
    }

    func giveUpWord() {
        if gameManager.allWordsGuessed {
            stopTimer()
            finishRound()
        } else {
            gameManager.skipToNextWord()
        }
    }

    func finishRound() {
        stopTimer()
        gameManager.finishRound()
        navigator.push(.roundResults(round: round))
    }
}

private struct NextTeamViewWrapper {
    let nextTeam: Team
    let nextIndex: Int
    let round: GameRound
    let wordsRemaining: Int
    let gameManager: GameManager
    let onContinue: () -> Void
}

// MARK: - View
extension NextTeamViewWrapper: View {
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

private extension NextTeamViewWrapper {
    var explainingPlayer: Player {
        if nextTeam.players.count >= 2 {
            return gameManager.getExplainingPlayer(for: nextIndex) ?? nextTeam.players[0]
        } else if nextTeam.players.count == 1 {
            return nextTeam.players[0]
        } else {
            return Player(name: "Player 1", teamId: nextTeam.id)
        }
    }

    var guessingPlayer: Player {
        if nextTeam.players.count >= 2 {
            return gameManager.getGuessingPlayer(for: nextIndex) ?? nextTeam.players[1]
        } else if nextTeam.players.count == 1 {
            return nextTeam.players[0]
        } else {
            return Player(name: "Player 2", teamId: nextTeam.id)
        }
    }
}

// MARK: - Preview
#Preview {
    let manager = GameManager()
    manager.addTeam(name: "Team 1")
    manager.shuffledWords = [Word(text: "Test")]
    manager.currentRound = .one
    manager.currentTeamIndex = 0
    return GameView(round: .one, teamIndex: 0)
        .environment(manager)
}


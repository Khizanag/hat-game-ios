//
//  OnlinePlayView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 22.12.24.
//

import SwiftUI
import DesignBook
import Navigation
import Networking

struct OnlinePlayView: View {
    @Environment(Navigator.self) private var navigator
    @Environment(RoomManager.self) private var roomManager
    @Environment(GameSyncManager.self) private var gameSyncManager

    @State private var remainingSeconds: Int = 60
    @State private var timer: Timer?
    @State private var isPaused: Bool = false
    @State private var showingGiveUpConfirmation: Bool = false
    @State private var guessedWordIds: [String] = []
    @State private var words: [String: OnlineWord] = [:]

    private var room: GameRoom? { roomManager.room }
    private var gameState: OnlineGameState? { room?.gameState }
    private var teams: [OnlineTeam] { room?.teams ?? [] }

    private var currentTeam: OnlineTeam? {
        guard let index = gameState?.currentTeamIndex,
              index < teams.count else { return nil }
        return teams[index]
    }

    private var currentRound: OnlineGameRound {
        gameState?.currentRound ?? .first
    }

    private var isActivePlayer: Bool {
        gameState?.activePlayerId == roomManager.currentPlayerId
    }

    private var currentWord: OnlineWord? {
        guard let wordId = gameState?.currentWordId else { return nil }
        return words[wordId]
    }

    private var totalWordCount: Int {
        gameState?.allWordIds.count ?? 0
    }

    private var remainingWordCount: Int {
        gameState?.remainingWordIds.count ?? 0
    }

    private var passedWordCount: Int {
        totalWordCount - remainingWordCount
    }

    var body: some View {
        content
            .setDefaultBackground()
            .overlay {
                if isPaused && isActivePlayer {
                    pauseOverlay
                }
            }
            .toolbar { gameToolbar }
            .onAppear {
                loadWords()
                if isActivePlayer {
                    startTimer()
                }
            }
            .onDisappear {
                stopTimer()
            }
            .onChange(of: gameState?.currentWordId) { _, newWordId in
                if newWordId == nil && isActivePlayer {
                    // All words guessed - end turn
                    endTurn()
                }
            }
            .onChange(of: gameState?.phase) { _, newPhase in
                if newPhase != .playing {
                    stopTimer()
                }
            }
            .alert(String(localized: "game.giveUp.title"), isPresented: $showingGiveUpConfirmation) {
                giveUpAlertActions
            } message: {
                giveUpAlertMessage
            }
            .navigationBarBackButtonHidden()
    }
}

// MARK: - Components
private extension OnlinePlayView {
    var content: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            roundInfoCard

            if isActivePlayer {
                activePlayerContent
            } else {
                spectatorContent
            }

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

        if isActivePlayer {
            ToolbarItem(placement: .automatic) {
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
                        Label(String(localized: "game.giveUp.button"), systemImage: "hand.raised.fill")
                    }
                )
            }
        }
    }

    var roundInfoCard: some View {
        HeaderCard(
            title: currentRound.title,
            description: currentRound.description
        ) {
            if let team = currentTeam {
                Text(String(format: String(localized: "game.currentTeamLabel"), team.name))
                    .font(DesignBook.Font.headline)
                    .foregroundColor(Color(hex: team.colorHex) ?? DesignBook.Color.Text.accent)
            }
        }
    }

    @ViewBuilder
    var activePlayerContent: some View {
        if let word = currentWord {
            activeWordCard(for: word)
        } else {
            GameCard {
                VStack(spacing: DesignBook.Spacing.md) {
                    ProgressView()
                    Text("onlinePlay.loadingWord")
                        .font(DesignBook.Font.body)
                        .foregroundColor(DesignBook.Color.Text.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignBook.Spacing.xl)
            }
        }
    }

    func activeWordCard(for word: OnlineWord) -> some View {
        GameCard {
            VStack(spacing: 0) {
                Spacer()

                Text(word.text)
                    .font(DesignBook.Font.largeTitle)
                    .foregroundColor(DesignBook.Color.Text.primary)
                    .multilineTextAlignment(.center)

                Spacer()

                PrimaryButton(title: String(localized: "game.gotIt"), icon: "checkmark.circle.fill") {
                    markAsGuessed(word)
                }
            }
        }
    }

    var spectatorContent: some View {
        GameCard {
            VStack(spacing: DesignBook.Spacing.lg) {
                Image(systemName: "eye.fill")
                    .font(.system(size: 40))
                    .foregroundColor(DesignBook.Color.Text.accent)

                Text("onlinePlay.spectatorMode")
                    .font(DesignBook.Font.title3)
                    .foregroundColor(DesignBook.Color.Text.primary)

                Text("onlinePlay.watchingTeam")
                    .font(DesignBook.Font.body)
                    .foregroundColor(DesignBook.Color.Text.secondary)
                    .multilineTextAlignment(.center)

                if let team = currentTeam {
                    Text(team.name)
                        .font(DesignBook.Font.headline)
                        .foregroundColor(Color(hex: team.colorHex) ?? DesignBook.Color.Text.accent)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignBook.Spacing.xl)
        }
    }

    var progressCard: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                HStack {
                    Text("game.progress.title")
                        .font(DesignBook.Font.headline)
                        .foregroundColor(DesignBook.Color.Text.primary)

                    Spacer()

                    Text("\(passedWordCount)/\(totalWordCount)")
                        .font(DesignBook.Font.headline)
                        .foregroundColor(DesignBook.Color.Text.accent)
                }

                ProgressView(
                    value: Double(passedWordCount),
                    total: Double(max(1, totalWordCount))
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
                    .font(DesignBook.IconFont.emoji)
                    .foregroundColor(DesignBook.Color.Text.primary)

                Text("game.paused.title")
                    .font(DesignBook.Font.largeTitle)
                    .foregroundColor(DesignBook.Color.Text.primary)

                PrimaryButton(title: String(localized: "common.buttons.continue"), icon: "play.fill") {
                    isPaused = false
                }
                .frame(width: 216)
            }
        }
    }

    @ViewBuilder
    var giveUpAlertActions: some View {
        Button(String(localized: "common.buttons.cancel"), role: .cancel) {
            showingGiveUpConfirmation = false
        }
        Button(String(localized: "game.giveUp.button"), role: .destructive) {
            endTurn()
            showingGiveUpConfirmation = false
        }
    }

    var giveUpAlertMessage: some View {
        Text(String(localized: "game.giveUp.confirmationMessage"))
    }
}

// MARK: - Private Functions
private extension OnlinePlayView {
    func loadWords() {
        Task {
            do {
                let fetchedWords = try await roomManager.getWords()
                for word in fetchedWords {
                    words[word.id] = word
                }
            } catch {
                print("Failed to load words: \(error)")
            }
        }
    }

    func startTimer() {
        stopTimer()
        isPaused = false
        remainingSeconds = gameState?.roundDuration ?? 60

        // If timer was started earlier, calculate remaining time
        if let startedAt = gameState?.timerStartedAt {
            let elapsed = Int(Date().timeIntervalSince(startedAt))
            remainingSeconds = max(0, remainingSeconds - elapsed)
        }

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            tickTimer()
        }
    }

    func tickTimer() {
        guard !isPaused else { return }
        guard remainingSeconds > 0 else {
            stopTimer()
            endTurn()
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

    func markAsGuessed(_ word: OnlineWord) {
        guessedWordIds.append(word.id)

        guard let roomId = room?.id,
              let state = gameState else { return }

        Task {
            do {
                try await gameSyncManager.markWordGuessed(
                    roomId: roomId,
                    gameState: state,
                    wordId: word.id,
                    teams: teams
                )
            } catch {
                print("Failed to mark word as guessed: \(error)")
            }
        }
    }

    func endTurn() {
        guard isActivePlayer,
              let roomId = room?.id,
              let state = gameState else { return }

        stopTimer()

        Task {
            do {
                try await gameSyncManager.endTurn(
                    roomId: roomId,
                    gameState: state,
                    guessedWordIds: guessedWordIds
                )
            } catch {
                print("Failed to end turn: \(error)")
            }
        }
    }
}

// MARK: - OnlineGameRound Extension
private extension OnlineGameRound {
    var title: String {
        switch self {
        case .first: String(localized: "round.first.title")
        case .second: String(localized: "round.second.title")
        case .third: String(localized: "round.third.title")
        }
    }

    var description: String {
        switch self {
        case .first: String(localized: "round.first.description")
        case .second: String(localized: "round.second.description")
        case .third: String(localized: "round.third.description")
        }
    }
}

// MARK: - Preview
#Preview {
    OnlinePlayView()
        .environment(Navigator())
        .environment(RoomManager())
        .environment(GameSyncManager())
}

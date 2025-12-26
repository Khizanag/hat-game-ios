//
//  OnlineNextTeamView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 22.12.24.
//

import SwiftUI
import DesignBook
import Navigation
import Networking

struct OnlineNextTeamView: View {
    @Environment(Navigator.self) private var navigator
    @Environment(RoomManager.self) private var roomManager
    @Environment(GameSyncManager.self) private var gameSyncManager

    @State private var selectedExplainerIndex: Int = 0
    @State private var isLoading: Bool = false

    private var room: GameRoom? { roomManager.room }
    private var gameState: OnlineGameState? { room?.gameState }
    private var teams: [OnlineTeam] { room?.teams ?? [] }
    private var players: [OnlinePlayer] { room?.players ?? [] }

    private var currentTeam: OnlineTeam? {
        guard let index = gameState?.currentTeamIndex,
              index < teams.count else { return nil }
        return teams[index]
    }

    private var currentRound: OnlineGameRound {
        gameState?.currentRound ?? .first
    }

    private var teamPlayers: [OnlinePlayer] {
        guard let teamId = currentTeam?.id else { return [] }
        return players.filter { $0.teamId == teamId }
    }

    private var isActivePlayer: Bool {
        gameState?.activePlayerId == roomManager.currentPlayerId
    }

    private var currentExplainer: OnlinePlayer? {
        guard let index = gameState?.currentExplainerIndex,
              index < teamPlayers.count else { return nil }
        return teamPlayers[index]
    }

    private var remainingWordCount: Int {
        gameState?.remainingWordIds.count ?? 0
    }

    private var isMyTeamsTurn: Bool {
        currentTeam?.playerIds.contains(roomManager.currentPlayerId ?? "") ?? false
    }

    var body: some View {
        content
            .setDefaultStyle()
            .navigationBarBackButtonHidden()
            .onAppear {
                if let index = gameState?.currentExplainerIndex {
                    selectedExplainerIndex = index
                }
            }
    }
}

// MARK: - Private
private extension OnlineNextTeamView {
    var content: some View {
        ScrollView {
            VStack(spacing: DesignBook.Spacing.lg) {
                Text("🎯")
                    .font(DesignBook.IconFont.emoji)

                Text("onlineNextTeam.title")
                    .font(DesignBook.Font.largeTitle)
                    .foregroundColor(DesignBook.Color.Text.primary)

                teamCard
                rolesCard
                roundStatusCard
            }
            .paddingHorizontalDefault()
            .padding(.bottom, DesignBook.Spacing.xxl)
        }
        .safeAreaInset(edge: .bottom) {
            actionSection
                .paddingHorizontalDefault()
                .withFooterGradient()
        }
    }

    var teamCard: some View {
        GameCard {
            VStack(spacing: DesignBook.Spacing.md) {
                if let team = currentTeam {
                    Text(team.name)
                        .font(DesignBook.Font.title2)
                        .foregroundColor(Color(hex: team.colorHex) ?? DesignBook.Color.Text.accent)

                    if let totalScore = gameState?.getTotalScore(for: team.id), totalScore > 0 {
                        Text(String(format: String(localized: "game.currentScoreLabel"), totalScore))
                            .font(DesignBook.Font.headline)
                            .foregroundColor(DesignBook.Color.Text.accent)
                    }
                }
            }
        }
    }

    var rolesCard: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.lg) {
                HStack {
                    Text("onlineNextTeam.teamRoles")
                        .font(DesignBook.Font.headline)
                        .foregroundColor(DesignBook.Color.Text.primary)

                    Spacer()

                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(DesignBook.Font.caption)
                        .foregroundColor(DesignBook.Color.Text.accent)
                }

                // Explainer section
                VStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
                    HStack(spacing: DesignBook.Spacing.xs) {
                        Image(systemName: "person.wave.2.fill")
                            .font(DesignBook.Font.caption)
                            .foregroundColor(DesignBook.Color.Text.accent)

                        Text("game.nextTeam.role.explaining")
                            .font(DesignBook.Font.caption)
                            .foregroundColor(DesignBook.Color.Text.secondary)
                    }

                    if let explainer = currentExplainer {
                        HStack(spacing: DesignBook.Spacing.sm) {
                            Circle()
                                .fill(DesignBook.Color.Text.accent.opacity(DesignBook.Opacity.semiTransparent))
                                .frame(width: DesignBook.Size.dotSmall, height: DesignBook.Size.dotSmall)

                            Text(explainer.name)
                                .font(DesignBook.Font.bodyBold)
                                .foregroundColor(DesignBook.Color.Text.accent)

                            if explainer.id == roomManager.currentPlayerId {
                                Text("onlineNextTeam.you")
                                    .font(DesignBook.Font.caption)
                                    .foregroundColor(DesignBook.Color.Text.secondary)
                                    .padding(.horizontal, DesignBook.Spacing.sm)
                                    .padding(.vertical, DesignBook.Spacing.xs)
                                    .background(DesignBook.Color.Background.secondary)
                                    .cornerRadius(DesignBook.Size.smallCardCornerRadius)
                            }
                        }
                        .padding(DesignBook.Spacing.sm)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(DesignBook.Color.Text.accent.opacity(DesignBook.Opacity.light))
                        .cornerRadius(DesignBook.Size.smallCardCornerRadius)
                    }
                }

                // Guessers section
                let guessers = teamPlayers.filter { $0.id != currentExplainer?.id }
                if !guessers.isEmpty {
                    VStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
                        HStack(spacing: DesignBook.Spacing.xs) {
                            Image(systemName: "lightbulb.fill")
                                .font(DesignBook.Font.caption)
                                .foregroundColor(DesignBook.Color.Text.accent)

                            Text("game.nextTeam.role.guessing")
                                .font(DesignBook.Font.caption)
                                .foregroundColor(DesignBook.Color.Text.secondary)
                        }

                        VStack(alignment: .leading, spacing: DesignBook.Spacing.xs) {
                            ForEach(guessers, id: \.id) { guesser in
                                HStack(spacing: DesignBook.Spacing.sm) {
                                    Circle()
                                        .fill(DesignBook.Color.Text.accent.opacity(DesignBook.Opacity.medium))
                                        .frame(width: DesignBook.Size.dotSmall, height: DesignBook.Size.dotSmall)

                                    Text(guesser.name)
                                        .font(DesignBook.Font.body)
                                        .foregroundColor(DesignBook.Color.Text.primary)

                                    if guesser.id == roomManager.currentPlayerId {
                                        Text("onlineNextTeam.you")
                                            .font(DesignBook.Font.caption)
                                            .foregroundColor(DesignBook.Color.Text.secondary)
                                    }
                                }
                                .padding(.horizontal, DesignBook.Spacing.sm)
                                .padding(.vertical, DesignBook.Spacing.xs)
                            }
                        }
                        .padding(DesignBook.Spacing.sm)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(DesignBook.Color.Background.secondary)
                        .cornerRadius(DesignBook.Size.smallCardCornerRadius)
                    }
                }
            }
        }
    }

    var roundStatusCard: some View {
        GameCard {
            VStack(spacing: DesignBook.Spacing.md) {
                Text("game.nextTeam.roundStatus")
                    .font(DesignBook.Font.headline)
                    .foregroundColor(DesignBook.Color.Text.primary)

                Text(currentRound.title)
                    .font(DesignBook.Font.title3)
                    .foregroundColor(DesignBook.Color.Text.secondary)

                Text(String(format: String(localized: "game.wordsRemainingLabel"), remainingWordCount))
                    .font(DesignBook.Font.body)
                    .foregroundColor(DesignBook.Color.Text.secondary)
            }
        }
    }

    @ViewBuilder
    var actionSection: some View {
        if isActivePlayer {
            PrimaryButton(title: String(localized: "common.buttons.play"), icon: "play.fill") {
                startTurn()
            }
            .disabled(isLoading)
        } else if isMyTeamsTurn {
            VStack(spacing: DesignBook.Spacing.md) {
                Text("onlineNextTeam.waitingForExplainer")
                    .font(DesignBook.Font.body)
                    .foregroundColor(DesignBook.Color.Text.secondary)
                    .multilineTextAlignment(.center)

                ProgressView()
            }
        } else {
            VStack(spacing: DesignBook.Spacing.md) {
                Text("onlineNextTeam.otherTeamsTurn")
                    .font(DesignBook.Font.body)
                    .foregroundColor(DesignBook.Color.Text.secondary)
                    .multilineTextAlignment(.center)

                ProgressView()
            }
        }
    }

    func startTurn() {
        guard let roomId = room?.id,
              let state = gameState else { return }

        isLoading = true

        Task {
            do {
                try await gameSyncManager.startTurn(roomId: roomId, gameState: state)
            } catch {
                print("Failed to start turn: \(error)")
            }
            isLoading = false
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
}

// MARK: - Preview
#Preview {
    OnlineNextTeamView()
        .environment(Navigator())
        .environment(RoomManager())
        .environment(GameSyncManager())
}

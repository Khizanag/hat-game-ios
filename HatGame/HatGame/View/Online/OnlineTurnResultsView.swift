//
//  OnlineTurnResultsView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 22.12.24.
//

import SwiftUI
import DesignBook
import Navigation
import Networking

struct OnlineTurnResultsView: View {
    @Environment(Navigator.self) private var navigator
    @Environment(RoomManager.self) private var roomManager
    @Environment(GameSyncManager.self) private var gameSyncManager

    @State private var isLoading: Bool = false

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

    private var roundScore: Int {
        guard let teamId = currentTeam?.id else { return 0 }
        return gameState?.getScore(for: teamId, in: currentRound) ?? 0
    }

    private var isActivePlayer: Bool {
        gameState?.activePlayerId == roomManager.currentPlayerId
    }

    var body: some View {
        content
            .setDefaultStyle()
            .navigationBarBackButtonHidden()
    }
}

// MARK: - Private
private extension OnlineTurnResultsView {
    var content: some View {
        ScrollView {
            VStack(spacing: DesignBook.Spacing.lg) {
                Text("🎉")
                    .font(DesignBook.IconFont.emoji)

                Text("onlineTurnResults.title")
                    .font(DesignBook.Font.largeTitle)
                    .foregroundColor(DesignBook.Color.Text.primary)

                teamResultCard
                scoreboardCard
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

    var teamResultCard: some View {
        GameCard {
            VStack(spacing: DesignBook.Spacing.md) {
                if let team = currentTeam {
                    Text(team.name)
                        .font(DesignBook.Font.title2)
                        .foregroundColor(Color(hex: team.colorHex) ?? DesignBook.Color.Text.accent)
                }

                HStack(spacing: DesignBook.Spacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(DesignBook.Font.title3)
                        .foregroundColor(DesignBook.Color.Status.success)

                    Text(String(format: String(localized: "onlineTurnResults.wordsGuessed"), roundScore))
                        .font(DesignBook.Font.title3)
                        .foregroundColor(DesignBook.Color.Text.primary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignBook.Spacing.md)
        }
    }

    var scoreboardCard: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                Text("onlineTurnResults.standings")
                    .font(DesignBook.Font.headline)
                    .foregroundColor(DesignBook.Color.Text.primary)

                let sortedTeams = teams.sorted { team1, team2 in
                    (gameState?.getTotalScore(for: team1.id) ?? 0) > (gameState?.getTotalScore(for: team2.id) ?? 0)
                }

                ForEach(Array(sortedTeams.enumerated()), id: \.element.id) { index, team in
                    HStack(spacing: DesignBook.Spacing.md) {
                        Text("\(index + 1)")
                            .font(DesignBook.Font.headline)
                            .foregroundColor(DesignBook.Color.Text.primary)
                            .frame(width: 30)

                        Circle()
                            .fill(Color(hex: team.colorHex) ?? DesignBook.Color.Text.accent)
                            .frame(width: 16, height: 16)

                        Text(team.name)
                            .font(DesignBook.Font.body)
                            .foregroundColor(DesignBook.Color.Text.primary)

                        Spacer()

                        Text("\(gameState?.getTotalScore(for: team.id) ?? 0)")
                            .font(DesignBook.Font.headline)
                            .foregroundColor(DesignBook.Color.Text.accent)
                    }
                    .padding(.vertical, DesignBook.Spacing.sm)
                }
            }
        }
    }

    @ViewBuilder
    var actionSection: some View {
        if isActivePlayer || roomManager.isHost {
            PrimaryButton(title: String(localized: "common.buttons.continue"), icon: "arrow.right") {
                continueGame()
            }
            .disabled(isLoading)
        } else {
            VStack(spacing: DesignBook.Spacing.md) {
                Text("onlineTurnResults.waitingForNext")
                    .font(DesignBook.Font.body)
                    .foregroundColor(DesignBook.Color.Text.secondary)
                    .multilineTextAlignment(.center)

                ProgressView()
            }
        }
    }

    func continueGame() {
        guard let roomId = room?.id,
              let state = gameState else { return }

        isLoading = true

        Task {
            do {
                try await gameSyncManager.advanceToNextTurn(
                    roomId: roomId,
                    gameState: state,
                    teams: teams
                )
            } catch {
                print("Failed to continue game: \(error)")
            }
            isLoading = false
        }
    }
}

// MARK: - Preview
#Preview {
    OnlineTurnResultsView()
        .environment(Navigator())
        .environment(RoomManager())
        .environment(GameSyncManager())
}

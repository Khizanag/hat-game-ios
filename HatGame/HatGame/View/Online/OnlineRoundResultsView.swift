//
//  OnlineRoundResultsView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 22.12.24.
//

import SwiftUI
import DesignBook
import Navigation
import Networking

struct OnlineRoundResultsView: View {
    @Environment(Navigator.self) private var navigator
    @Environment(RoomManager.self) private var roomManager
    @Environment(GameSyncManager.self) private var gameSyncManager

    @State private var isLoading: Bool = false

    private var room: GameRoom? { roomManager.room }
    private var gameState: OnlineGameState? { room?.gameState }
    private var teams: [OnlineTeam] { room?.teams ?? [] }

    private var currentRound: OnlineGameRound {
        gameState?.currentRound ?? .first
    }

    private var previousRound: OnlineGameRound? {
        switch currentRound {
        case .first: nil
        case .second: .first
        case .third: .second
        }
    }

    var body: some View {
        content
            .setDefaultStyle()
            .navigationBarBackButtonHidden()
    }
}

// MARK: - Private
private extension OnlineRoundResultsView {
    var content: some View {
        ScrollView {
            VStack(spacing: DesignBook.Spacing.lg) {
                Text("🏁")
                    .font(DesignBook.IconFont.emoji)

                Text("onlineRoundResults.roundComplete")
                    .font(DesignBook.Font.largeTitle)
                    .foregroundColor(DesignBook.Color.Text.primary)

                if let round = previousRound {
                    Text(round.title)
                        .font(DesignBook.Font.title3)
                        .foregroundColor(DesignBook.Color.Text.secondary)
                }

                roundScoresCard
                totalScoresCard
                nextRoundCard
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

    var roundScoresCard: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                Text("onlineRoundResults.roundScores")
                    .font(DesignBook.Font.headline)
                    .foregroundColor(DesignBook.Color.Text.primary)

                let sortedTeams = teams.sorted { team1, team2 in
                    let score1 = previousRound.map { gameState?.getScore(for: team1.id, in: $0) ?? 0 } ?? 0
                    let score2 = previousRound.map { gameState?.getScore(for: team2.id, in: $0) ?? 0 } ?? 0
                    return score1 > score2
                }

                ForEach(Array(sortedTeams.enumerated()), id: \.element.id) { index, team in
                    HStack(spacing: DesignBook.Spacing.md) {
                        medalIcon(for: index)
                            .frame(width: 30)

                        Circle()
                            .fill(Color(hex: team.colorHex) ?? DesignBook.Color.Text.accent)
                            .frame(width: 16, height: 16)

                        Text(team.name)
                            .font(DesignBook.Font.body)
                            .foregroundColor(DesignBook.Color.Text.primary)

                        Spacer()

                        let roundScore = previousRound.map { gameState?.getScore(for: team.id, in: $0) ?? 0 } ?? 0
                        Text("\(roundScore)")
                            .font(DesignBook.Font.headline)
                            .foregroundColor(DesignBook.Color.Text.accent)
                    }
                    .padding(.vertical, DesignBook.Spacing.sm)
                }
            }
        }
    }

    var totalScoresCard: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                Text("onlineRoundResults.totalScores")
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

    var nextRoundCard: some View {
        GameCard {
            VStack(spacing: DesignBook.Spacing.md) {
                Text("onlineRoundResults.nextRound")
                    .font(DesignBook.Font.headline)
                    .foregroundColor(DesignBook.Color.Text.primary)

                Text(currentRound.title)
                    .font(DesignBook.Font.title2)
                    .foregroundColor(DesignBook.Color.Text.accent)

                Text(currentRound.description)
                    .font(DesignBook.Font.body)
                    .foregroundColor(DesignBook.Color.Text.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignBook.Spacing.sm)
        }
    }

    @ViewBuilder
    func medalIcon(for index: Int) -> some View {
        switch index {
        case 0:
            Text("🥇")
                .font(DesignBook.Font.title3)
        case 1:
            Text("🥈")
                .font(DesignBook.Font.title3)
        case 2:
            Text("🥉")
                .font(DesignBook.Font.title3)
        default:
            Text("\(index + 1)")
                .font(DesignBook.Font.headline)
                .foregroundColor(DesignBook.Color.Text.primary)
        }
    }

    @ViewBuilder
    var actionSection: some View {
        if roomManager.isHost {
            PrimaryButton(title: String(localized: "onlineRoundResults.startNextRound"), icon: "play.fill") {
                startNextRound()
            }
            .disabled(isLoading)
        } else {
            VStack(spacing: DesignBook.Spacing.md) {
                Text("onlineRoundResults.waitingForHost")
                    .font(DesignBook.Font.body)
                    .foregroundColor(DesignBook.Color.Text.secondary)
                    .multilineTextAlignment(.center)

                ProgressView()
            }
        }
    }

    func startNextRound() {
        guard let roomId = room?.id,
              let state = gameState else { return }

        isLoading = true

        Task {
            do {
                try await gameSyncManager.continueFromRoundResults(roomId: roomId, gameState: state)
            } catch {
                print("Failed to start next round: \(error)")
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
    OnlineRoundResultsView()
        .environment(Navigator())
        .environment(RoomManager())
        .environment(GameSyncManager())
}

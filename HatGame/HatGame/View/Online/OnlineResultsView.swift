//
//  OnlineResultsView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 22.12.24.
//

import SwiftUI
import DesignBook
import Navigation
import Networking

struct OnlineResultsView: View {
    @Environment(Navigator.self) private var navigator
    @Environment(RoomManager.self) private var roomManager

    private var teams: [OnlineTeam] {
        roomManager.room?.teams ?? []
    }

    private var gameState: OnlineGameState? {
        roomManager.room?.gameState
    }

    private var sortedTeams: [(team: OnlineTeam, score: Int)] {
        teams.map { team in
            let score = gameState?.getTotalScore(for: team.id) ?? 0
            return (team: team, score: score)
        }
        .sorted { $0.score > $1.score }
    }

    var body: some View {
        content
            .navigationTitle(String(localized: "onlineResults.title"))
            .setDefaultBackground()
    }
}

// MARK: - Private
private extension OnlineResultsView {
    var content: some View {
        ScrollView {
            VStack(spacing: DesignBook.Spacing.lg) {
                winnerCard
                leaderboard
            }
            .paddingHorizontalDefault()
            .padding(.top, DesignBook.Spacing.lg)
            .padding(.bottom, DesignBook.Spacing.xxl)
        }
        .safeAreaInset(edge: .bottom) {
            actionButton
                .withFooterGradient()
        }
    }

    var winnerCard: some View {
        GameCard {
            VStack(spacing: DesignBook.Spacing.md) {
                Text("🏆")
                    .font(.system(size: 60))

                if let winner = sortedTeams.first {
                    Text(winner.team.name)
                        .font(DesignBook.Font.largeTitle)
                        .foregroundColor(Color(hex: winner.team.colorHex) ?? DesignBook.Color.Text.primary)

                    Text(String(format: String(localized: "onlineResults.winnerScore"), winner.score))
                        .font(DesignBook.Font.title3)
                        .foregroundColor(DesignBook.Color.Text.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignBook.Spacing.lg)
        }
    }

    var leaderboard: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                Text("onlineResults.leaderboard")
                    .font(DesignBook.Font.headline)
                    .foregroundColor(DesignBook.Color.Text.primary)

                ForEach(Array(sortedTeams.enumerated()), id: \.element.team.id) { index, item in
                    teamRow(rank: index + 1, team: item.team, score: item.score)
                }
            }
        }
    }

    func teamRow(rank: Int, team: OnlineTeam, score: Int) -> some View {
        HStack(spacing: DesignBook.Spacing.md) {
            Text("\(rank)")
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

            Text("\(score)")
                .font(DesignBook.Font.headline)
                .foregroundColor(DesignBook.Color.Text.accent)
        }
        .padding(.vertical, DesignBook.Spacing.sm)
    }

    var actionButton: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            PrimaryButton(title: String(localized: "onlineResults.returnHome"), icon: "house.fill") {
                leaveRoom()
            }
        }
        .paddingHorizontalDefault()
    }

    func leaveRoom() {
        Task {
            try? await roomManager.leaveRoom()
            navigator.dismiss()
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        OnlineResultsView()
    }
    .environment(Navigator())
    .environment(RoomManager())
}

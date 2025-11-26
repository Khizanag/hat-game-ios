//
//  ResultsView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct ResultsView: View {
    @Environment(GameManager.self) private var gameManager
    @Environment(Navigator.self) private var navigator

    @State private var isTotalScoresExpanded = false
    @State private var expandedRounds: Set<GameRound> = []

    private var round: GameRound? {
        gameManager.currentRound
    }

    private var isFinal: Bool {
        round == nil
    }

    private var winners: [Team] {
        let sortedTeams = gameManager.getSortedTeamsByTotalScore()
        guard let topScore = sortedTeams.first.map({ gameManager.getTotalScore(for: $0) }) else {
            return []
        }
        return sortedTeams.filter { gameManager.getTotalScore(for: $0) == topScore }
    }

    var body: some View {
        content
            .setDefaultStyle(
                title: String(
                    localized: isFinal ? "game.results.gameOverTitle" : "game.results.roundResultsTitle"
                )
            )
            .navigationBarBackButtonHidden()
            .toolbar { finalToolbar }
            .onAppear {
                if !isFinal, let currentRound = round {
                    expandedRounds = [currentRound]
                } else if isFinal {
                    expandedRounds = Set(GameRound.allCases)
                }
            }
    }
}

// MARK: - Private
private extension ResultsView {
    var content: some View {
        ScrollView {
            VStack(spacing: DesignBook.Spacing.xl) {
                winnerSection

                if isFinal {
                    allRoundsSection
                    totalScoresSection
                } else {
                    totalScoresSection
                    allRoundsSection
                }
            }
            .paddingHorizontalDefault()
            .padding(.top, DesignBook.Spacing.lg)
            .padding(.bottom, DesignBook.Spacing.xxl)
        }
        .safeAreaInset(edge: .bottom) {
            actionSection
                .paddingHorizontalDefault()
                .withFooterGradient()
        }
    }

    var allRoundsSection: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            ForEach(gameManager.getStartedRounds(), id: \.rawValue) { round in
                roundSection(for: round)
            }
        }
    }

    func roundSection(for round: GameRound) -> some View {
        FoldableCard(
            isExpanded: Binding(
                get: { expandedRounds.contains(round) },
                set: { isExpanded in
                    if isExpanded {
                        expandedRounds.insert(round)
                    } else {
                        expandedRounds.remove(round)
                    }
                }
            ),
            title: round.title,
            description: round.description
        ) {
            roundScores(for: round)
        }
    }

    @ViewBuilder
    var winnerSection: some View {
        if isFinal {
            GameCard {
                winnerCardContent
            }
        }
    }

    func roundScores(for round: GameRound) -> some View {
        VStack(spacing: DesignBook.Spacing.sm) {
            ForEach(Array(gameManager.getSortedTeamsByRoundScore(for: round).enumerated()), id: \.element.id) { index, team in
                TeamScoreRowView(
                    team: team,
                    rank: index + 1,
                    score: gameManager.getScore(for: team, in: round),
                    isWinner: index == 0
                )
            }
        }
    }

    var totalScoresSection: some View {
        FoldableCard(
            isExpanded: $isTotalScoresExpanded,
            title: String(localized: "game.results.totalScores")
        ) {
            totalScoresContent
        }
    }

    var totalScoresContent: some View {
        VStack(spacing: DesignBook.Spacing.sm) {
            ForEach(Array(gameManager.getSortedTeamsByTotalScore().enumerated()), id: \.element.id) { index, team in
                TeamScoreRowView(
                    team: team,
                    rank: index + 1,
                    score: gameManager.getTotalScore(for: team),
                    isWinner: index == 0
                )
            }
        }
    }

    @ViewBuilder
    var actionSection: some View {
        if isFinal {
            newGameButton
        }
    }

    var newGameButton: some View {
        PrimaryButton(title: String(localized: "game.results.returnToMain"), icon: "house.fill") {
            handleReturnToMain()
        }
    }

    @ViewBuilder
    var winnerCardContent: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            Text("🏆")
                .font(DesignBook.IconFont.emoji)

            if winners.count == 1 {
                Text("game.results.winner")
                    .font(DesignBook.Font.title2)
                    .foregroundColor(DesignBook.Color.Text.primary)

                if let winner = winners.first {
                    Text(winner.name)
                        .font(DesignBook.Font.largeTitle)
                        .foregroundColor(teamColor(for: winner))

                    Text("\(gameManager.getTotalScore(for: winner)) points")
                        .font(DesignBook.Font.headline)
                        .foregroundColor(DesignBook.Color.Text.secondary)
                }
            } else {
                Text("game.results.winners")
                    .font(DesignBook.Font.title2)
                    .foregroundColor(DesignBook.Color.Text.primary)

                VStack(spacing: DesignBook.Spacing.sm) {
                    ForEach(winners) { winner in
                        VStack(spacing: DesignBook.Spacing.xs) {
                            Text(winner.name)
                                .font(DesignBook.Font.title3)
                                .foregroundColor(teamColor(for: winner))

                            Text("\(gameManager.getTotalScore(for: winner)) points")
                                .font(DesignBook.Font.body)
                                .foregroundColor(DesignBook.Color.Text.secondary)
                        }
                    }
                }
            }
        }
    }

    func teamColor(for team: Team) -> Color {
        team.color
    }

    func handleReturnToMain() {
        navigator.dismissToRoot()
        navigator.dismiss()
    }

    @ToolbarContentBuilder
    var finalToolbar: some ToolbarContent {
        if isFinal {
            ToolbarItem(placement: .automatic) {
                Button(String(localized: "common.buttons.close")) {
                    navigator.dismissToRoot()
                }
                .foregroundColor(DesignBook.Color.Text.accent)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        Page.finalResults.view()
    }
    .environment(GameManager())
}

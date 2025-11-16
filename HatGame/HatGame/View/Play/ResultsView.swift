//
//  ResultsView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct ResultsView: View {
    @Environment(GameManager.self) private var gameManager
    let round: GameRound?
    let isFinal: Bool
    @Environment(Navigator.self) private var navigator
    @State private var isTotalScoresExpanded = false
    
    private var winner: Team? {
        let sortedTeams = gameManager.getSortedTeamsByTotalScore()
        return sortedTeams.first
    }

    var body: some View {
        content
            .setDefaultStyle(title: isFinal ? "Game Over" : "Round Results")
            .navigationBarBackButtonHidden()
            .toolbar {
                finalToolbar
            }
    }
}

private extension ResultsView {
    var content: some View {
        ScrollView {
            VStack(spacing: DesignBook.Spacing.xl) {
                winnerSection
                currentRoundSection
                totalScoresSection
                actionSection
            }
            .paddingHorizontalDefault()
            .padding(.top, DesignBook.Spacing.lg)
            .padding(.bottom, DesignBook.Spacing.xxl)
        }
    }
    
    @ViewBuilder
    var winnerSection: some View {
        if isFinal, let winner = winner {
            GameCard {
                winnerCardContent(for: winner)
            }
        }
    }
    
    @ViewBuilder
    var currentRoundSection: some View {
        if let round = round {
            GameCard {
                VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                    currentRoundHeader(for: round)
                    currentRoundScores(for: round)
                }
            }
        }
    }
    
    func currentRoundHeader(for round: GameRound) -> some View {
        VStack(alignment: .leading, spacing: DesignBook.Spacing.xs) {
            Text(round.title)
                .font(DesignBook.Font.title2)
                .foregroundColor(DesignBook.Color.Text.primary)
            
            Text(round.description)
                .font(DesignBook.Font.body)
                .foregroundColor(DesignBook.Color.Text.secondary)
        }
    }
    
    func currentRoundScores(for round: GameRound) -> some View {
        VStack(spacing: DesignBook.Spacing.sm) {
            ForEach(Array(gameManager.getSortedTeamsByRoundScore(for: round).enumerated()), id: \.element.id) { index, team in
                TeamScoreRow(
                    team: team,
                    rank: index + 1,
                    score: gameManager.getScore(for: team, in: round),
                    isWinner: index == 0
                )
            }
        }
        .padding(.top, DesignBook.Spacing.sm)
    }
    
    var totalScoresSection: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                totalScoresHeader
                
                if isTotalScoresExpanded {
                    totalScoresContent
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }
    
    var totalScoresHeader: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isTotalScoresExpanded.toggle()
            }
        } label: {
            HStack {
                Text("Total Scores")
                    .font(DesignBook.Font.title3)
                    .foregroundColor(DesignBook.Color.Text.primary)
                
                Spacer()
                
                Image(systemName: isTotalScoresExpanded ? "chevron.up" : "chevron.down")
                    .font(DesignBook.Font.headline)
                    .foregroundColor(DesignBook.Color.Text.accent)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    var totalScoresContent: some View {
        VStack(spacing: DesignBook.Spacing.sm) {
            ForEach(Array(gameManager.getSortedTeamsByTotalScore().enumerated()), id: \.element.id) { index, team in
                TeamScoreRow(
                    team: team,
                    rank: index + 1,
                    score: gameManager.getTotalScore(for: team),
                    isWinner: index == 0
                )
            }
        }
        .padding(.top, DesignBook.Spacing.sm)
    }
    
    @ViewBuilder
    var actionSection: some View {
        if isFinal {
            newGameButton
        }
    }
    
    var newGameButton: some View {
        PrimaryButton(title: "New Game") {
            handleNewGame()
        }
    }
    
    @ViewBuilder
    func winnerCardContent(for winner: Team) -> some View {
        VStack(spacing: DesignBook.Spacing.md) {
            Text("🏆")
                .font(.system(size: 80))
            
            Text("Winner!")
                .font(DesignBook.Font.title2)
                .foregroundColor(DesignBook.Color.Text.primary)
            
            Text(winner.name)
                .font(DesignBook.Font.largeTitle)
                .foregroundColor(teamColor(for: winner))
            
            Text("\(gameManager.getTotalScore(for: winner)) points")
                .font(DesignBook.Font.headline)
                .foregroundColor(DesignBook.Color.Text.secondary)
        }
    }
    
    func teamColor(for team: Team) -> Color {
        team.color
    }
    
    func handleNewGame() {
        navigator.dismissToRoot()
    }
    
    @ToolbarContentBuilder
    var finalToolbar: some ToolbarContent {
        if isFinal {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Close") {
                    navigator.dismissToRoot()
                }
                .foregroundColor(DesignBook.Color.Text.accent)
            }
        }
    }
}

private struct TeamScoreRow: View {
    let team: Team
    let rank: Int
    let score: Int
    let isWinner: Bool
    
    var body: some View {
        HStack(spacing: DesignBook.Spacing.md) {
            rankView
            indicator
            nameView
            Spacer()
            scoreView
            crownView
        }
        .padding(DesignBook.Spacing.md)
        .background(rowBackgroundColor)
        .cornerRadius(DesignBook.Size.smallCardCornerRadius)
    }
}

// MARK: - TeamScoreRow Components
private extension TeamScoreRow {
    var rankView: some View {
        Text("\(rank)")
            .font(DesignBook.Font.title3)
            .foregroundColor(rankColor)
            .frame(width: 40, alignment: .leading)
    }
    
    var indicator: some View {
        Circle()
            .fill(team.color)
            .frame(width: 12, height: 12)
    }
    
    var nameView: some View {
        Text(team.name)
            .font(DesignBook.Font.headline)
            .foregroundColor(DesignBook.Color.Text.primary)
    }
    
    var scoreView: some View {
        Text("\(score)")
            .font(DesignBook.Font.title3)
            .foregroundColor(isWinner ? team.color : DesignBook.Color.Text.secondary)
    }
    
    @ViewBuilder
    var crownView: some View {
        if isWinner {
            Image(systemName: "crown.fill")
                .font(DesignBook.Font.caption)
                .foregroundColor(team.color)
        }
    }
    
    var rowBackgroundColor: Color {
        isWinner ? team.color.opacity(DesignBook.Opacity.highlight) : DesignBook.Color.Background.secondary
    }
    
    var rankColor: Color {
        rank <= 3 ? team.color : DesignBook.Color.Text.tertiary
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        Page.finalResults.view()
    }
    .environment(GameManager())
}
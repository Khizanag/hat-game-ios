//
//  ResultsView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct ResultsView {
    @Environment(GameManager.self) private var gameManager
    let round: GameRound?
    let isFinal: Bool
    @Environment(Navigator.self) private var navigator
    
    var sortedTeams: [Team] {
        gameManager.getSortedTeamsByScore()
    }
    
    var winner: Team? {
        gameManager.getWinner()
    }
}

// MARK: - View
extension ResultsView: View {
    var body: some View {
        NavigationStack {
            content
                .setDefaultBackground()
                .navigationTitle(isFinal ? "Game Over" : "Round Results")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    nonFinalToolbar
                }
        }
    }
}

private extension ResultsView {
    var content: some View {
        ScrollView {
            VStack(spacing: DesignBook.Spacing.xl) {
                winnerSection
                standingsSection
                actionSection
            }
        }
    }
    
    @ViewBuilder
    var winnerSection: some View {
        if isFinal, let winner = winner {
            GameCard {
                winnerCardContent(for: winner)
            }
            .padding(.horizontal, DesignBook.Spacing.lg)
            .padding(.top, DesignBook.Spacing.lg)
        }
    }
    
    var standingsSection: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                standingsHeader
                teamScoreRows
            }
        }
        .padding(.horizontal, DesignBook.Spacing.lg)
    }
    
    var standingsHeader: some View {
        Text(isFinal ? "Final Standings" : "Current Standings")
            .font(DesignBook.Font.title3)
            .foregroundColor(DesignBook.Color.Text.primary)
    }
    
    var teamScoreRows: some View {
        VStack(spacing: DesignBook.Spacing.sm) {
            ForEach(Array(sortedTeams.enumerated()), id: \.element.id) { index, team in
                TeamScoreRow(
                    team: team,
                    rank: index + 1,
                    isWinner: winner?.id == team.id,
                    teamColor: teamColor(for: team)
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
        PrimaryButton(title: "New Game") {
            handleNewGame()
        }
        .padding(.horizontal, DesignBook.Spacing.lg)
        .padding(.bottom, DesignBook.Spacing.lg)
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
            
            Text("\(winner.score) points")
                .font(DesignBook.Font.headline)
                .foregroundColor(DesignBook.Color.Text.secondary)
        }
    }
    
    func teamColor(for team: Team) -> Color {
        DesignBook.Color.Team.color(
            for: gameManager.configuration.teams.firstIndex(where: { $0.id == team.id }) ?? 0
        )
    }
    
    func handleNewGame() {
        gameManager.resetGame()
        navigator.dismissToRoot()
    }
    
    @ToolbarContentBuilder
    var nonFinalToolbar: some ToolbarContent {
        if !isFinal {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    navigator.dismiss()
                }
                .foregroundColor(DesignBook.Color.Text.accent)
            }
        }
    }
}

private struct TeamScoreRow {
    let team: Team
    let rank: Int
    let isWinner: Bool
    let teamColor: Color
}

// MARK: - View
extension TeamScoreRow: View {
    var body: some View {
        HStack {
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

private extension TeamScoreRow {
    var rankView: some View {
        Text("\(rank)")
            .font(DesignBook.Font.title3)
            .foregroundColor(rankColor)
            .frame(width: 40)
    }
    
    var indicator: some View {
        Circle()
            .fill(teamColor)
            .frame(width: 12, height: 12)
    }
    
    var nameView: some View {
        Text(team.name)
            .font(DesignBook.Font.headline)
            .foregroundColor(DesignBook.Color.Text.primary)
    }
    
    var scoreView: some View {
        Text("\(team.score)")
            .font(DesignBook.Font.title3)
            .foregroundColor(isWinner ? teamColor : DesignBook.Color.Text.secondary)
    }
    
    @ViewBuilder
    var crownView: some View {
        if isWinner {
            Image(systemName: "crown.fill")
                .foregroundColor(teamColor)
        }
    }
    
    var rowBackgroundColor: Color {
        isWinner ? teamColor.opacity(0.1) : DesignBook.Color.Background.secondary
    }
    
    var rankColor: Color {
        rank <= 3 ? teamColor : DesignBook.Color.Text.tertiary
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        Page.finalResults.view()
    }
    .environment(GameManager())
}

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
    @Environment(\.dismiss) private var dismiss
    @Environment(Navigator.self) private var navigator
    
    var sortedTeams: [Team] {
        gameManager.getSortedTeamsByScore()
    }
    
    var winner: Team? {
        gameManager.getWinner()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignBook.Color.Background.primary
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: DesignBook.Spacing.xl) {
                        if isFinal, let winner = winner {
                            GameCard {
                                VStack(spacing: DesignBook.Spacing.md) {
                                    Text("🏆")
                                        .font(.system(size: 80))
                                    
                                    Text("Winner!")
                                        .font(DesignBook.Font.title2)
                                        .foregroundColor(DesignBook.Color.Text.primary)
                                    
                                    Text(winner.name)
                                        .font(DesignBook.Font.largeTitle)
                                        .foregroundColor(DesignBook.Color.Team.color(for: gameManager.teams.firstIndex(where: { $0.id == winner.id }) ?? 0))
                                    
                                    Text("\(winner.score) points")
                                        .font(DesignBook.Font.headline)
                                        .foregroundColor(DesignBook.Color.Text.secondary)
                                }
                            }
                            .padding(.horizontal, DesignBook.Spacing.lg)
                            .padding(.top, DesignBook.Spacing.lg)
                        }
                        
                        GameCard {
                            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                                Text(isFinal ? "Final Standings" : "Current Standings")
                                    .font(DesignBook.Font.title3)
                                    .foregroundColor(DesignBook.Color.Text.primary)
                                
                                VStack(spacing: DesignBook.Spacing.sm) {
                                    ForEach(Array(sortedTeams.enumerated()), id: \.element.id) { index, team in
                                        TeamScoreRow(
                                            team: team,
                                            rank: index + 1,
                                            isWinner: winner?.id == team.id,
                                            teamColor: DesignBook.Color.Team.color(for: gameManager.teams.firstIndex(where: { $0.id == team.id }) ?? 0)
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, DesignBook.Spacing.lg)
                        
                        if isFinal {
                            PrimaryButton(title: "New Game") {
                                gameManager.resetGame()
                                navigator.dismissToRoot()
                            }
                            .padding(.horizontal, DesignBook.Spacing.lg)
                            .padding(.bottom, DesignBook.Spacing.lg)
                        } else {
                            VStack(spacing: DesignBook.Spacing.md) {
                                PrimaryButton(title: "Continue to Next Round") {
                                    gameManager.startNextRound()
                                    if let nextRound = gameManager.currentRound, let nextTeamIndex = gameManager.currentTeamIndex {
                                        navigator.push(.playing(round: nextRound, currentTeamIndex: nextTeamIndex))
                                    } else {
                                        navigator.push(.finalResults)
                                    }
                                }
                            }
                            .padding(.horizontal, DesignBook.Spacing.lg)
                            .padding(.bottom, DesignBook.Spacing.lg)
                        }
                    }
                }
            }
            .navigationTitle(isFinal ? "Game Over" : "Round Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !isFinal {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                        .foregroundColor(DesignBook.Color.Text.accent)
                    }
                }
            }
        }
    }
}

private struct TeamScoreRow: View {
    let team: Team
    let rank: Int
    let isWinner: Bool
    let teamColor: SwiftUI.Color
    
    var body: some View {
        HStack {
            Text("\(rank)")
                .font(DesignBook.Font.title3)
                .foregroundColor(rank <= 3 ? teamColor : DesignBook.Color.Text.tertiary)
                .frame(width: 40)
            
            Circle()
                .fill(teamColor)
                .frame(width: 12, height: 12)
            
            Text(team.name)
                .font(DesignBook.Font.headline)
                .foregroundColor(DesignBook.Color.Text.primary)
            
            Spacer()
            
            Text("\(team.score)")
                .font(DesignBook.Font.title3)
                .foregroundColor(isWinner ? teamColor : DesignBook.Color.Text.secondary)
            
            if isWinner {
                Image(systemName: "crown.fill")
                    .foregroundColor(teamColor)
            }
        }
        .padding(DesignBook.Spacing.md)
        .background(isWinner ? teamColor.opacity(0.1) : DesignBook.Color.Background.secondary)
        .cornerRadius(DesignBook.Size.smallCardCornerRadius)
    }
}

#Preview {
    NavigationView {
        Page.finalResults.view()
    }
    .environment(GameManager())
}


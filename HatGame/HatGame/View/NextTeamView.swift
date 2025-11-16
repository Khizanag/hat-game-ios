//
//  NextTeamView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct NextTeamView: View {
    let team: Team
    let teamIndex: Int
    let round: GameRound
    let wordsRemaining: Int
    let explainingPlayer: Player
    let guessingPlayer: Player
    let onContinue: () -> Void
    
    var body: some View {
        content
            .setDefaultBackground()
    }
}

private extension NextTeamView {
    var content: some View {
        VStack(spacing: DesignBook.Spacing.xl) {
            Spacer()
            teamDetails
            Spacer()
            startTurnButton
        }
    }
    
    var teamDetails: some View {
        VStack(spacing: DesignBook.Spacing.lg) {
            Text("🎯")
                .font(.system(size: 80))
            
            Text("Next Team")
                .font(DesignBook.Font.largeTitle)
                .foregroundColor(DesignBook.Color.Text.primary)
            
            teamScoreCard
            roundStatusCard
            rolesCard
        }
    }
    
    var teamScoreCard: some View {
        GameCard {
            VStack(spacing: DesignBook.Spacing.md) {
                Text(team.name)
                    .font(DesignBook.Font.title2)
                    .foregroundColor(DesignBook.Color.Team.color(for: teamIndex))
                
                Text("Current Score: \(team.score)")
                    .font(DesignBook.Font.headline)
                    .foregroundColor(DesignBook.Color.Text.accent)
            }
        }
        .padding(.horizontal, DesignBook.Spacing.lg)
    }
    
    var roundStatusCard: some View {
        GameCard {
            VStack(spacing: DesignBook.Spacing.md) {
                Text("Round Status")
                    .font(DesignBook.Font.headline)
                    .foregroundColor(DesignBook.Color.Text.primary)
                
                Text(round.title)
                    .font(DesignBook.Font.title3)
                    .foregroundColor(DesignBook.Color.Text.secondary)
                
                Text("Words remaining: \(wordsRemaining)")
                    .font(DesignBook.Font.body)
                    .foregroundColor(DesignBook.Color.Text.secondary)
            }
        }
        .padding(.horizontal, DesignBook.Spacing.lg)
    }
    
    var rolesCard: some View {
        GameCard {
            VStack(spacing: DesignBook.Spacing.md) {
                Text("Team Roles")
                    .font(DesignBook.Font.headline)
                    .foregroundColor(DesignBook.Color.Text.primary)
                
                VStack(spacing: DesignBook.Spacing.sm) {
                    roleRow(icon: "person.wave.2.fill", label: "Explaining", value: explainingPlayer.name)
                    roleRow(icon: "lightbulb.fill", label: "Guessing", value: guessingPlayer.name)
                }
            }
        }
        .padding(.horizontal, DesignBook.Spacing.lg)
    }
    
    func roleRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(DesignBook.Color.Text.accent)
            Text("\(label):")
                .font(DesignBook.Font.body)
                .foregroundColor(DesignBook.Color.Text.secondary)
            Spacer()
            Text(value)
                .font(DesignBook.Font.bodyBold)
                .foregroundColor(DesignBook.Color.Text.primary)
        }
    }
    
    var startTurnButton: some View {
        PrimaryButton(title: "Start Turn") {
            onContinue()
        }
        .padding(.horizontal, DesignBook.Spacing.lg)
        .padding(.bottom, DesignBook.Spacing.lg)
    }
}

// MARK: - Preview
#Preview {
    let team = Team(name: "Team Beta", players: [
        Player(name: "Alice", teamId: UUID()),
        Player(name: "Bob", teamId: UUID())
    ])
    return NextTeamView(
        team: team,
        teamIndex: 1,
        round: .first,
        wordsRemaining: 15,
        explainingPlayer: team.players[0],
        guessingPlayer: team.players[1],
        onContinue: {}
    )
}


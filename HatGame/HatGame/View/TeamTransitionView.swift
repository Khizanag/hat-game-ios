//
//  TeamTransitionView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct TeamTransitionView: View {
    let currentTeam: Team
    let nextTeam: Team
    let nextTeamIndex: Int
    let round: GameRound
    let onContinue: () -> Void
    
    var body: some View {
        content
            .setDefaultBackground()
    }
}

private extension TeamTransitionView {
    var content: some View {
        VStack(spacing: DesignBook.Spacing.xl) {
            Spacer()
            detailsSection
            Spacer()
            continueButton
        }
    }
    
    var detailsSection: some View {
        VStack(spacing: DesignBook.Spacing.lg) {
            Text("⏱️")
                .font(.system(size: 80))
            
            Text("Time's Up!")
                .font(DesignBook.Font.largeTitle)
                .foregroundColor(DesignBook.Color.Text.primary)
            
            transitionCard
            roundCard
        }
    }
    
    var transitionCard: some View {
        GameCard {
            VStack(spacing: DesignBook.Spacing.md) {
                Text("\(currentTeam.name)'s turn is over")
                    .font(DesignBook.Font.headline)
                    .foregroundColor(DesignBook.Color.Text.secondary)
                
                Text("→")
                    .font(DesignBook.Font.title)
                    .foregroundColor(DesignBook.Color.Text.accent)
                    .padding(.vertical, DesignBook.Spacing.sm)
                
                Text("Next up: \(nextTeam.name)")
                    .font(DesignBook.Font.title2)
                    .foregroundColor(DesignBook.Color.Team.color(for: nextTeamIndex))
            }
        }
        .padding(.horizontal, DesignBook.Spacing.lg)
    }
    
    var roundCard: some View {
        GameCard {
            VStack(spacing: DesignBook.Spacing.sm) {
                Text(round.title)
                    .font(DesignBook.Font.title3)
                    .foregroundColor(DesignBook.Color.Text.primary)
                
                Text(round.description)
                    .font(DesignBook.Font.body)
                    .foregroundColor(DesignBook.Color.Text.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, DesignBook.Spacing.lg)
    }
    
    var continueButton: some View {
        PrimaryButton(title: "Continue") {
            onContinue()
        }
        .padding(.horizontal, DesignBook.Spacing.lg)
        .padding(.bottom, DesignBook.Spacing.lg)
    }
}

// MARK: - Preview
//#Preview {
//    let team1 = Team(name: "Team Alpha")
//    let team2 = Team(name: "Team Beta")
//    return TeamTransitionView(
//        currentTeam: team1,
//        nextTeam: team2,
//        nextTeamIndex: 1,
//        round: .first,
//        onContinue: {}
//    )
//}


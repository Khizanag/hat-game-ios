//
//  TeamScoreRowView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 16.11.25.
//

import SwiftUI

struct TeamScoreRowView: View {
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

// MARK: - Components
private extension TeamScoreRowView {
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
    VStack(spacing: DesignBook.Spacing.md) {
        TeamScoreRowView(
            team: Team(name: "Team 1", color: .blue),
            rank: 1,
            score: 25,
            isWinner: true
        )
        
        TeamScoreRowView(
            team: Team(name: "Team 2", color: .red),
            rank: 2,
            score: 20,
            isWinner: false
        )
        
        TeamScoreRowView(
            team: Team(name: "Team 3", color: .green),
            rank: 3,
            score: 15,
            isWinner: false
        )
    }
    .padding()
    .setDefaultBackground()
}


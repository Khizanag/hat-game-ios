//
//  TeamScoreRowView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 16.11.25.
//

import DesignBook
import SwiftUI

struct TeamScoreRowView: View {
    let team: Team
    let rank: Int
    let score: Int
    let isWinner: Bool

    var body: some View {
        HStack(spacing: DesignBook.Spacing.md) {
            rankBadge
            indicator
            nameView
            Spacer()
            scoreView
        }
        .padding(.horizontal, DesignBook.Spacing.md)
        .padding(.vertical, DesignBook.Spacing.sm + 2)
        .background {
            RoundedRectangle(cornerRadius: DesignBook.Size.smallCardCornerRadius, style: .continuous)
                .fill(rowBackgroundColor)
                .overlay {
                    if isWinner {
                        RoundedRectangle(cornerRadius: DesignBook.Size.smallCardCornerRadius, style: .continuous)
                            .strokeBorder(team.color.opacity(0.35), lineWidth: 1.5)
                    }
                }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }
}

// MARK: - Components
private extension TeamScoreRowView {
    var rankBadge: some View {
        ZStack {
            Circle()
                .fill(rankBackgroundColor)
                .frame(width: 32, height: 32)

            if rank == 1 {
                Image(systemName: "crown.fill")
                    .font(DesignBook.Font.captionBold)
                    .foregroundStyle(rankForegroundColor)
            } else {
                Text("\(rank)")
                    .font(DesignBook.Font.captionBold)
                    .foregroundStyle(rankForegroundColor)
                    .monospacedDigit()
            }
        }
    }

    var indicator: some View {
        Circle()
            .fill(team.color)
            .frame(width: 10, height: 10)
    }

    var nameView: some View {
        Text(team.name)
            .font(DesignBook.Font.headline)
            .foregroundStyle(DesignBook.Color.Text.primary)
            .lineLimit(1)
    }

    var scoreView: some View {
        AnimatedScoreText(
            value: score,
            font: DesignBook.Font.title3,
            color: isWinner ? team.color : DesignBook.Color.Text.secondary,
            duration: 0.6
        )
    }

    var rowBackgroundColor: Color {
        isWinner ? team.color.opacity(0.10) : DesignBook.Color.Background.secondary
    }

    var rankBackgroundColor: Color {
        switch rank {
        case 1: return team.color
        case 2: return DesignBook.Color.Text.tertiary.opacity(0.4)
        case 3: return DesignBook.Color.Text.tertiary.opacity(0.25)
        default: return DesignBook.Color.Background.secondary
        }
    }

    var rankForegroundColor: Color {
        rank == 1 ? .white : DesignBook.Color.Text.primary
    }

    var accessibilityLabel: Text {
        Text("\(team.name), rank \(rank), \(score) points")
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

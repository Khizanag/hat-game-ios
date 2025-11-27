//
//  TeamCard.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct TeamCard: View {
    let team: Team
    let playersPerTeam: Int
    let onRemoveTeam: () -> Void
    let onEditTeam: () -> Void
    let isEditMode: Bool

    var body: some View {
        HStack(spacing: DesignBook.Spacing.sm) {
            if isEditMode {
                dragHandle
            }

            GameCard {
                VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                    header
                    playersList
                }
            }

            if isEditMode {
                editModeActions
            }
        }
    }
}

// MARK: - Private
private extension TeamCard {
    var header: some View {
        HStack {
            Text(team.name)
                .font(DesignBook.Font.headline)
                .foregroundColor(team.color)

            Spacer()

            Text("\(team.players.count)/\(playersPerTeam)")
                .font(DesignBook.Font.captionBold)
                .foregroundColor(DesignBook.Color.Text.secondary)
        }
    }

    var playersList: some View {
        VStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
            ForEach(team.players) { player in
                HStack {
                    Circle()
                        .fill(team.color)
                        .frame(width: DesignBook.Size.dotMedium, height: DesignBook.Size.dotMedium)

                    Text(player.name)
                        .font(DesignBook.Font.body)
                        .foregroundColor(DesignBook.Color.Text.secondary)
                }
            }
        }
    }

    var dragHandle: some View {
        Image(systemName: "line.3.horizontal")
            .font(.system(size: 20))
            .foregroundColor(DesignBook.Color.Text.tertiary)
            .frame(width: 30)
    }

    var editModeActions: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            Button(action: onEditTeam) {
                Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(DesignBook.Color.Text.accent)
            }
            .buttonStyle(.plain)
            .frame(width: 44, height: 44)

            Button(action: onRemoveTeam) {
                Image(systemName: "trash.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(DesignBook.Color.Status.error)
            }
            .buttonStyle(.plain)
            .frame(width: 44, height: 44)
        }
    }
}
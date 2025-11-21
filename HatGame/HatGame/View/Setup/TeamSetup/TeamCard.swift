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
    let onAddPlayer: () -> Void
    let onRemoveTeam: () -> Void
    let onEditTeam: () -> Void

    var body: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                header
                playersList
                actions
            }
        }
        .contextMenu {
            Button {
                onEditTeam()
            } label: {
                Label(String(localized: "teamCard.edit"), systemImage: "pencil")
            }

            Button(role: .destructive) {
                onRemoveTeam()
            } label: {
                Label(String(localized: "teamCard.delete"), systemImage: "trash")
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
                        .frame(width: 8, height: 8)

                    Text(player.name)
                        .font(DesignBook.Font.body)
                        .foregroundColor(DesignBook.Color.Text.secondary)
                }
            }
        }
    }

    var actions: some View {
        HStack {
            addPlayerButton
            Spacer()
            editButton
            deleteButton
        }
    }

    var addPlayerButton: some View {
        Button(action: onAddPlayer) {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text(
                    team.players.count < playersPerTeam
                        ? String(localized: "teamCard.addPlayer")
                        : String(localized: "teamCard.teamFull")
                )
            }
            .font(DesignBook.Font.body)
            .foregroundColor(team.players.count < playersPerTeam ? DesignBook.Color.Text.accent : DesignBook.Color.Text.tertiary)
        }
        .disabled(team.players.count >= playersPerTeam)
    }

    var editButton: some View {
        Button(action: onEditTeam) {
            Image(systemName: "pencil.circle")
                .foregroundColor(DesignBook.Color.Text.accent)
                .font(DesignBook.Font.body)
        }
    }

    var deleteButton: some View {
        Button(action: onRemoveTeam) {
            Image(systemName: "trash")
                .foregroundColor(DesignBook.Color.Status.error)
                .font(DesignBook.Font.body)
        }
    }
}
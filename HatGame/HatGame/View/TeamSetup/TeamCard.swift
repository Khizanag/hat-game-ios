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
    @Bindable var gameManager: GameManager
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
    }
}

private extension TeamCard {
    var teamColor: Color {
        DesignBook.Color.Team.color(
            for: gameManager.teams.firstIndex(where: { $0.id == team.id }) ?? 0
        )
    }
    
    var header: some View {
        HStack {
            Text(team.name)
                .font(DesignBook.Font.headline)
                .foregroundColor(teamColor)
            
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
                        .fill(teamColor)
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
                Text(team.players.count < playersPerTeam ? "Add Player" : "Team is full")
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


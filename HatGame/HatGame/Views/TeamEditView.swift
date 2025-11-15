//
//  TeamEditView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct TeamEditView: View {
    @Bindable var gameManager: GameManager
    let teamId: UUID
    @Environment(\.dismiss) private var dismiss
    @State private var teamName: String = ""
    @State private var playerNames: [UUID: String] = [:]
    
    private var team: Team? {
        gameManager.teams.first(where: { $0.id == teamId })
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignBook.Color.Background.primary
                    .ignoresSafeArea()
                
                if let team {
                    ScrollView {
                        VStack(spacing: DesignBook.Spacing.lg) {
                            GameCard {
                                VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                                    Text("Team name")
                                        .font(DesignBook.Font.captionBold)
                                        .foregroundColor(DesignBook.Color.Text.secondary)
                                    
                                    TextField("Team name", text: $teamName)
                                        .textFieldStyle(.plain)
                                        .font(DesignBook.Font.headline)
                                        .foregroundColor(DesignBook.Color.Text.primary)
                                        .padding(DesignBook.Spacing.md)
                                        .background(DesignBook.Color.Background.secondary)
                                        .cornerRadius(DesignBook.Size.smallCardCornerRadius)
                                }
                            }
                            
                            GameCard {
                                VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                                    Text("Players")
                                        .font(DesignBook.Font.captionBold)
                                        .foregroundColor(DesignBook.Color.Text.secondary)
                                    
                                    ForEach(team.players) { player in
                                        VStack(alignment: .leading, spacing: DesignBook.Spacing.xs) {
                                            Text("Player \(index(of: player) + 1)")
                                                .font(DesignBook.Font.caption)
                                                .foregroundColor(DesignBook.Color.Text.secondary)
                                            
                                            TextField("Player name", text: Binding(
                                                get: { playerNames[player.id] ?? player.name },
                                                set: { playerNames[player.id] = $0 }
                                            ))
                                            .textFieldStyle(.plain)
                                            .font(DesignBook.Font.body)
                                            .foregroundColor(DesignBook.Color.Text.primary)
                                            .padding(DesignBook.Spacing.md)
                                            .background(DesignBook.Color.Background.secondary)
                                            .cornerRadius(DesignBook.Size.smallCardCornerRadius)
                                        }
                                    }
                                }
                            }
                            
                            VStack(spacing: DesignBook.Spacing.md) {
                                PrimaryButton(title: "Save changes") {
                                    applyChanges()
                                    dismiss()
                                }
                                
                                SecondaryButton(title: "Cancel") {
                                    dismiss()
                                }
                            }
                            .padding(.bottom, DesignBook.Spacing.lg)
                        }
                        .padding(.horizontal, DesignBook.Spacing.lg)
                        .padding(.top, DesignBook.Spacing.lg)
                    }
                } else {
                    Text("Team not found")
                        .font(DesignBook.Font.body)
                        .foregroundColor(DesignBook.Color.Text.secondary)
                }
            }
            .navigationTitle("Edit group")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadDataIfNeeded()
            }
        }
        .presentationDetents([.large])
    }
    
    private func loadDataIfNeeded() {
        guard let team, teamName.isEmpty else { return }
        teamName = team.name
        for player in team.players {
            playerNames[player.id] = player.name
        }
    }
    
    private func applyChanges() {
        let trimmedTeamName = teamName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTeamName.isEmpty {
            gameManager.updateTeamName(teamId: teamId, name: trimmedTeamName)
        }
        
        if let team {
            for player in team.players {
                if let newName = playerNames[player.id]?.trimmingCharacters(in: .whitespacesAndNewlines),
                   !newName.isEmpty,
                   newName != player.name {
                    gameManager.updatePlayerName(playerId: player.id, name: newName)
                }
            }
        }
    }
    
    private func index(of player: Player) -> Int {
        gameManager.teams.first(where: { $0.id == teamId })?.players.firstIndex(where: { $0.id == player.id }) ?? 0
    }
}

#Preview {
    let manager = GameManager()
    manager.addTeam(name: "Orion")
    let teamId = manager.teams[0].id
    manager.addPlayer(name: "Alex", to: teamId)
    manager.addPlayer(name: "Maya", to: teamId)
    return TeamEditView(gameManager: manager, teamId: teamId)
}



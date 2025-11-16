//
//  TeamEditView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct TeamEditView: View {
    @Environment(GameManager.self) private var gameManager
    @Environment(Navigator.self) private var navigator

    let team: Team

    @State private var teamName: String = ""
    @State private var playerNames: [String] = []
    @State private var teamColor: Color = DesignBook.Color.Team.team1
    
    var body: some View {
        TeamFormView(
            teamName: $teamName,
            playerNames: $playerNames,
            teamColor: $teamColor,
            title: "Edit group",
            primaryButtonTitle: "Save changes",
            onPrimaryAction: {
                handleSaveChanges()
                navigator.dismiss()
            },
            onCancel: {
                navigator.dismiss()
            }
        )
        .setDefaultBackground()
        .onAppear {
            loadDataIfNeeded()
        }
        .presentationDetents([.large])
    }
}

private extension TeamEditView {
    func loadDataIfNeeded() {
        guard teamName.isEmpty else { return }
        teamName = team.name
        playerNames = team.players.map { $0.name }
        teamColor = team.color
    }
    
    func handleSaveChanges() {
        applyTeamNameChange()
        applyTeamColorChange()
        applyPlayerNameChanges()
    }
    
    func applyTeamNameChange() {
        let trimmedName = teamName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, let index = gameManager.configuration.teams.firstIndex(where: { $0.id == team.id }) else { return }
        gameManager.configuration.teams[index].name = trimmedName
    }
    
    func applyTeamColorChange() {
        guard let index = gameManager.configuration.teams.firstIndex(where: { $0.id == team.id }) else { return }
        // Since color is let, we need to replace the entire team
        let updatedTeam = Team(
            id: team.id,
            name: gameManager.configuration.teams[index].name,
            players: gameManager.configuration.teams[index].players,
            color: teamColor
        )
        gameManager.configuration.teams[index] = updatedTeam
    }
    
    func applyPlayerNameChanges() {
        guard let teamIndex = gameManager.configuration.teams.firstIndex(where: { $0.id == team.id }) else { return }
        for (index, player) in team.players.enumerated() {
            guard index < playerNames.count else { continue }
            let trimmedName = playerNames[index].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedName.isEmpty, trimmedName != player.name else { continue }
            // Update player name in the team
            if let playerIndex = gameManager.configuration.teams[teamIndex].players.firstIndex(where: { $0.id == player.id }) {
                // Since Player.name is let, we need to replace the player
                let updatedPlayer = Player(
                    id: player.id,
                    name: trimmedName,
                    teamId: player.teamId
                )
                gameManager.configuration.teams[teamIndex].players[playerIndex] = updatedPlayer
            }
        }
    }
}
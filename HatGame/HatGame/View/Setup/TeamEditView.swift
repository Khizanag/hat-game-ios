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
    
    var body: some View {
        TeamFormView(
            teamName: $teamName,
            playerNames: $playerNames,
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
    }
    
    func handleSaveChanges() {
        applyTeamNameChange()
        applyPlayerNameChanges()
    }
    
    func applyTeamNameChange() {
        let trimmedName = teamName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
//        gameManager.updateTeamName(team: team, name: trimmedName)
    }
    
    func applyPlayerNameChanges() {
        for (index, player) in team.players.enumerated() {
            guard index < playerNames.count else { continue }
            let trimmedName = playerNames[index].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedName.isEmpty, trimmedName != player.name else { continue }
//            gameManager.updatePlayerName(playerId: player.id, name: trimmedName)
        }
    }
}

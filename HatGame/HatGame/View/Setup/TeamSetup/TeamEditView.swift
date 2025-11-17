//
//  TeamEditView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct TeamEditView: View {
    @Environment(GameManager.self) private var gameManager

    let team: Team
    
    var body: some View {
        TeamFormView(
            team: team,
            playersPerTeam: gameManager.configuration.maxTeamMembers,
            existingTeams: gameManager.configuration.teams,
            onPrimaryAction: { updatedTeam in
                gameManager.removeTeam(team)
                gameManager.addTeam(updatedTeam)
            }
        )
        .setDefaultBackground()
        .presentationDetents([.large])
    }
}

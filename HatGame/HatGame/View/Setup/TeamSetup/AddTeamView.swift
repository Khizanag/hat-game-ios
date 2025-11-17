//
//  AddTeamView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct AddTeamView: View {
    @Environment(GameManager.self) private var gameManager

    let playersPerTeam: Int
    let onTeamCreate: (Team) -> Void

    init(playersPerTeam: Int, onTeamCreate: @escaping (Team) -> Void) {
        self.playersPerTeam = playersPerTeam
        self.onTeamCreate = onTeamCreate
    }

    var body: some View {
        TeamFormView(
            team: nil,
            playersPerTeam: playersPerTeam,
            existingTeams: gameManager.configuration.teams,
            onPrimaryAction: onTeamCreate
        )
    }
}

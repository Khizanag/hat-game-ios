//
//  AddTeamView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct AddTeamView: View {
    @Environment(Navigator.self) private var navigator

    @State private var teamName: String = ""
    @State private var playerNames: [String]
    
    let playersPerTeam: Int
    let onTeamCreate: (Team) -> Void

    init(playersPerTeam: Int, onTeamCreate: @escaping (Team) -> Void) {
        self.playersPerTeam = playersPerTeam
        self.onTeamCreate = onTeamCreate
        self._playerNames = State(initialValue: Array(repeating: "", count: playersPerTeam))
    }

    var body: some View {
        TeamFormView(
            teamName: $teamName,
            playerNames: $playerNames,
            title: "New Team",
            primaryButtonTitle: "Create Team",
            onPrimaryAction: {
                var team = Team(name: teamName, color: .pink)
                team.players = playerNames.map { playerName in
                    .init(name: playerName, teamId: team.id)
                }
                onTeamCreate(team)
                navigator.dismiss()
            },
            onCancel: {
                navigator.dismiss()
            }
        )
    }
}
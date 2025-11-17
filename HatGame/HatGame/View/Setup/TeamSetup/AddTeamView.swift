//
//  AddTeamView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct AddTeamView: View {
    @Environment(Navigator.self) private var navigator
    @Environment(GameManager.self) private var gameManager

    @State private var teamName: String = ""
    @State private var playerNames: [String]
    @State private var teamColor: Color

    let playersPerTeam: Int
    let onTeamCreate: (Team) -> Void

    init(playersPerTeam: Int, onTeamCreate: @escaping (Team) -> Void) {
        self.playersPerTeam = playersPerTeam
        self.onTeamCreate = onTeamCreate
        self._playerNames = State(initialValue: Array(repeating: "", count: playersPerTeam))
        self._teamColor = State(initialValue: TeamDefaultColorGenerator.defaultColors[0])
    }

    var body: some View {
        TeamFormView(
            teamName: $teamName,
            playerNames: $playerNames,
            teamColor: $teamColor,
            title: "New Team",
            primaryButtonTitle: "Create Team",
            existingTeams: gameManager.configuration.teams,
            onPrimaryAction: {
                var team = Team(name: teamName, color: teamColor)
                team.players = playerNames.map { playerName in
                    Player(name: playerName, teamId: team.id)
                }
                onTeamCreate(team)
                navigator.dismiss()
            },
            onCancel: {
                navigator.dismiss()
            }
        )
        .onAppear {
            updateDefaultColor()
        }
    }
}

// MARK: - Private
private extension AddTeamView {
    func updateDefaultColor() {
        let generator = TeamDefaultColorGenerator()
        teamColor = generator.generateDefaultColor(for: gameManager.configuration)
    }
}

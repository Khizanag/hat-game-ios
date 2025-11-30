//
//  TeamEditView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI
import Navigation

struct TeamEditView: View {
    @Environment(GameManager.self) private var gameManager
    @Environment(Navigator.self) private var navigator

    let team: Team

    var body: some View {
        TeamFormView(
            team: team,
            onPrimaryAction: { updatedTeam in
                gameManager.removeTeam(team)
                gameManager.addTeam(updatedTeam)
            }
        )
        .environment(gameManager)
        .environment(navigator)
        .setDefaultBackground()
        .presentationDetents([.large])
    }
}

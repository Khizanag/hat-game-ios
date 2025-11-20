//
//  AddTeamView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct AddTeamView: View {
    @Environment(GameManager.self) private var gameManager
    @Environment(Navigator.self) private var navigator
    
    let onTeamCreate: (Team) -> Void

    init(onTeamCreate: @escaping (Team) -> Void) {
        self.onTeamCreate = onTeamCreate
    }

    var body: some View {
        TeamFormView(
            team: nil,
            onPrimaryAction: onTeamCreate
        )
        .environment(gameManager)
        .environment(navigator)
    }
}

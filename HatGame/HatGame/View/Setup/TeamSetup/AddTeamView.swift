//
//  AddTeamView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct AddTeamView: View {
    let onTeamCreate: (Team) -> Void

    init(onTeamCreate: @escaping (Team) -> Void) {
        self.onTeamCreate = onTeamCreate
    }

    var body: some View {
        TeamFormView(
            team: nil,
            onPrimaryAction: onTeamCreate
        )
    }
}
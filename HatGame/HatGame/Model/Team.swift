//
//  Team.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import Foundation
import SwiftUI

struct Team: Identifiable, Hashable {
    let id: UUID
    var name: String
    var players: [Player]
    let color: Color

    init(
        id: UUID = UUID(),
        name: String,
        players: [Player] = [],
        color: Color
    ) {
        self.id = id
        self.name = name
        self.players = players
        self.color = color
    }
}

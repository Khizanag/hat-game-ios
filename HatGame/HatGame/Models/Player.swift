//
//  Player.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import Foundation

struct Player: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var teamId: UUID
    
    init(id: UUID = UUID(), name: String, teamId: UUID) {
        self.id = id
        self.name = name
        self.teamId = teamId
    }
}


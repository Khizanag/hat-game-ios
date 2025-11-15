//
//  Team.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import Foundation

struct Team: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var players: [Player]
    var score: Int
    var colorIndex: Int
    
    init(
        id: UUID = UUID(),
        name: String,
        players: [Player] = [],
        score: Int = 0,
        colorIndex: Int = 0
    ) {
        self.id = id
        self.name = name
        self.players = players
        self.score = score
        self.colorIndex = colorIndex
    }
}


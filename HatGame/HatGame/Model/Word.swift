//
//  Word.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import Foundation

struct Word: Identifiable, Codable, Hashable {
    let id: UUID
    var text: String
    var guessed: Bool
    var guessedByTeamId: UUID?
    var guessedInRound: Int?
    
    init(
        id: UUID = UUID(),
        text: String,
        guessed: Bool = false,
        guessedByTeamId: UUID? = nil,
        guessedInRound: Int? = nil
    ) {
        self.id = id
        self.text = text
        self.guessed = guessed
        self.guessedByTeamId = guessedByTeamId
        self.guessedInRound = guessedInRound
    }
}


//
//  Word.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import Foundation

struct Word: Identifiable, Hashable {
    let id: UUID
    let text: String

    init(
        id: UUID = UUID(),
        text: String
    ) {
        self.id = id
        self.text = text
    }
}

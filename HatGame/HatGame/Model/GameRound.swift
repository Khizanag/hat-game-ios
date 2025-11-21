//
//  GameRound.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 16.11.25.
//

import SwiftUI

enum GameRound: Int, Codable, CaseIterable, Equatable, Hashable {
    case first = 1
    case second = 2
    case third = 3

    var description: String {
        switch self {
        case .first:
            String(localized: "gameRound.first.description")
        case .second:
            String(localized: "gameRound.second.description")
        case .third:
            String(localized: "gameRound.third.description")
        }
    }

    var title: String {
        String(format: String(localized: "gameRound.title"), rawValue)
    }
}
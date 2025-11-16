//
//  GameRound.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 16.11.25.
//

import Foundation

enum GameRound: Int, Codable, CaseIterable, Equatable, Hashable {
    case first = 1
    case second = 2
    case third = 3
    
    var description: String {
        switch self {
        case .first:
            "No restrictions - use any words or descriptions"
        case .second:
            "One word only - can say just one word"
        case .third:
            "No words - gestures and miming only"
        }
    }
    
    var title: String {
        "Round \(rawValue)"
    }
}
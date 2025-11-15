//
//  GameRound.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import Foundation

enum GameRound: Int, Codable, CaseIterable, Equatable {
    case one = 1
    case two = 2
    case three = 3
    
    var description: String {
        switch self {
        case .one:
            "No restrictions - use any words or descriptions"
        case .two:
            "One word only - can say just one word"
        case .three:
            "No words - gestures and miming only"
        }
    }
    
    var title: String {
        "Round \(rawValue)"
    }
}


//
//  GameConfiguration.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import Foundation
import Observation
import SwiftUI

@Observable
final class GameConfiguration {
    var maxTeams: Int = 6
    var maxTeamMembers: Int = 10
    var teams: [Team] = []
    var words: [Word] = []
    var wordsPerPlayer: Int = 10
    var roundDuration: Int = 60
    
    var teamColors: [Color] {
        [
            DesignBook.Color.Team.team1,
            DesignBook.Color.Team.team2,
            DesignBook.Color.Team.team3,
            DesignBook.Color.Team.team4,
            DesignBook.Color.Team.team5,
            DesignBook.Color.Team.team6
        ]
    }
    
    func teamColor(for index: Int) -> Color {
        teamColors[index % teamColors.count]
    }
}


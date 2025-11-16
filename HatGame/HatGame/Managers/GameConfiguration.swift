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
    let minTeams = 2
    let maxTeams: Int
    let maxTeamMembers: Int
    var wordsPerPlayer: Int
    var roundDuration: Int
    var teams: [Team] = []
    var words: [Word] = []

    let teamColors: [Color] = [
        DesignBook.Color.Team.team1,
        DesignBook.Color.Team.team2,
        DesignBook.Color.Team.team3,
        DesignBook.Color.Team.team4,
        DesignBook.Color.Team.team5,
        DesignBook.Color.Team.team6
    ]
    
    func teamColor(for index: Int) -> Color {
        teamColors[index % teamColors.count]
    }

    init(
        maxTeams: Int = 6,
        maxTeamMembers: Int = 2,
        wordsPerPlayer: Int = 10,
        roundDuration: Int = 60,
        teams: [Team] = [],
        words: [Word] = []
    ) {
        self.maxTeams = maxTeams
        self.maxTeamMembers = maxTeamMembers
        self.wordsPerPlayer = wordsPerPlayer
        self.roundDuration = roundDuration
        self.teams = teams
        self.words = words
    }
}

extension GameConfiguration {
    static let mockForTesting = makeMockForTesting()

    private static func makeMockForTesting() -> GameConfiguration {
        let team1Id = UUID()
        let team1 = Team(
            name: "Alpha",
            players: [
                .init(name: "Alice", teamId: team1Id),
                .init(name: "Bob", teamId: team1Id),
            ],
            color: DesignBook.Color.Team.team1
        )

        let team2Id = UUID()
        let team2 = Team(
            name: "Beta",
            players: [
                .init(name: "John", teamId: team2Id),
                .init(name: "Margaret", teamId: team2Id),
            ],
            color: DesignBook.Color.Team.team2
        )

        return GameConfiguration(
            maxTeams: 2,
            maxTeamMembers: 2,
            wordsPerPlayer: 3,
            roundDuration: 10,
            teams: [team1, team2],
            words: [
                .init(text: "A"),
                .init(text: "B"),
                .init(text: "C"),
                .init(text: "D"),
                .init(text: "E"),
                .init(text: "F"),
                .init(text: "G"),
                .init(text: "H"),
                .init(text: "I"),
                .init(text: "J"),
                .init(text: "K"),
                .init(text: "L"),
            ]
        )
    }
}
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
    let minTeamMembers = 2 // Minimum 2 players per team (one explains, others guess)
    let maxTeamMembers: Int
    var wordsPerPlayer: Int
    var roundDuration: Int
    var teams: [Team] = []
    var words: [Word] = []

    static let rounds: [GameRound] = [.first, .second, .third]

    var teamColors: [Color] {
        TeamDefaultColorGenerator.defaultColors
    }

    func teamColor(for index: Int) -> Color {
        teamColors[index % teamColors.count]
    }

    init(
        maxTeams: Int = 6,
        maxTeamMembers: Int = 6,
        wordsPerPlayer: Int? = nil,
        roundDuration: Int? = nil,
        teams: [Team] = [],
        words: [Word] = []
    ) {
        self.maxTeams = maxTeams
        self.maxTeamMembers = maxTeamMembers
        self.wordsPerPlayer = wordsPerPlayer ?? AppConfiguration.shared.defaultWordsPerPlayer
        self.roundDuration = roundDuration ?? AppConfiguration.shared.defaultRoundDuration
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
            color: TeamDefaultColorGenerator.defaultColors[0]
        )

        let team2Id = UUID()
        let team2 = Team(
            name: "Beta",
            players: [
                .init(name: "John", teamId: team2Id),
                .init(name: "Margaret", teamId: team2Id),
            ],
            color: TeamDefaultColorGenerator.defaultColors[1]
        )

        return GameConfiguration(
            maxTeams: 10,
            maxTeamMembers: 2,
            wordsPerPlayer: 3,
            roundDuration: 10,
            teams: [team1, team2],
            words: [ ]
        )
    }
}

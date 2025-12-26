//
//  GameRoom.swift
//  Networking
//
//  Created by Giga Khizanishvili on 22.12.24.
//

import Foundation

public enum RoomStatus: String, Codable, Sendable {
    case waiting
    case setup
    case playing
    case finished
}

public struct GameRoom: Codable, Identifiable, Sendable {
    public let id: String
    public let hostId: String
    public var status: RoomStatus
    public var settings: GameSettings
    public var teams: [OnlineTeam]
    public var players: [OnlinePlayer]
    public var gameState: OnlineGameState?
    public let createdAt: Date

    public init(
        id: String,
        hostId: String,
        status: RoomStatus = .waiting,
        settings: GameSettings = GameSettings(),
        teams: [OnlineTeam] = [],
        players: [OnlinePlayer] = [],
        gameState: OnlineGameState? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.hostId = hostId
        self.status = status
        self.settings = settings
        self.teams = teams
        self.players = players
        self.gameState = gameState
        self.createdAt = createdAt
    }
}

public struct GameSettings: Codable, Sendable {
    public var maxTeams: Int
    public var playersPerTeam: Int
    public var wordsPerPlayer: Int
    public var roundDuration: Int

    public init(
        maxTeams: Int = 4,
        playersPerTeam: Int = 2,
        wordsPerPlayer: Int = 5,
        roundDuration: Int = 60
    ) {
        self.maxTeams = maxTeams
        self.playersPerTeam = playersPerTeam
        self.wordsPerPlayer = wordsPerPlayer
        self.roundDuration = roundDuration
    }
}

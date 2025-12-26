//
//  RoomManager.swift
//  Networking
//
//  Created by Giga Khizanishvili on 22.12.24.
//

import Foundation
import Observation
import FirebaseDatabase

@MainActor
@Observable
public final class RoomManager {
    public private(set) var room: GameRoom?
    public private(set) var currentPlayerId: String?
    public private(set) var isConnected: Bool = false
    public private(set) var error: Error?

    private let firebaseService = FirebaseService.shared
    private var roomObserverHandle: DatabaseHandle?
    private var deviceId: String

    public var isHost: Bool {
        room?.hostId == currentPlayerId
    }

    public var currentPlayer: OnlinePlayer? {
        guard let playerId = currentPlayerId else { return nil }
        return room?.players.first { $0.id == playerId }
    }

    public var currentTeam: OnlineTeam? {
        guard let teamId = currentPlayer?.teamId else { return nil }
        return room?.teams.first { $0.id == teamId }
    }

    public init() {
        self.deviceId = Self.getOrCreateDeviceId()
    }

    // MARK: - Room Creation

    public func createRoom(hostName: String, settings: GameSettings) async throws -> String {
        let roomCode = try await firebaseService.generateUniqueRoomCode()
        let playerId = UUID().uuidString

        let host = OnlinePlayer(
            id: playerId,
            deviceId: deviceId,
            name: hostName,
            isReady: true
        )

        let room = GameRoom(
            id: roomCode,
            hostId: playerId,
            status: .waiting,
            settings: settings,
            players: [host]
        )

        try await firebaseService.createRoom(room)
        self.currentPlayerId = playerId
        startObservingRoom(id: roomCode)

        return roomCode
    }

    // MARK: - Room Joining

    public func joinRoom(code: String, playerName: String) async throws {
        guard let existingRoom = try await firebaseService.getRoom(id: code) else {
            throw NetworkingError.roomNotFound
        }

        guard existingRoom.status == .waiting || existingRoom.status == .setup else {
            throw RoomError.gameAlreadyStarted
        }

        let playerId = UUID().uuidString
        let player = OnlinePlayer(
            id: playerId,
            deviceId: deviceId,
            name: playerName
        )

        try await firebaseService.addPlayer(player, toRoomId: code)
        self.currentPlayerId = playerId
        startObservingRoom(id: code)
    }

    // MARK: - Room Observation

    private func startObservingRoom(id: String) {
        roomObserverHandle = firebaseService.observeRoom(id: id) { [weak self] room in
            Task { @MainActor in
                self?.room = room
                self?.isConnected = room != nil
            }
        }
    }

    public func stopObserving() {
        guard let handle = roomObserverHandle, let roomId = room?.id else { return }
        firebaseService.removeObserver(handle: handle, forRoomId: roomId)
        roomObserverHandle = nil
        room = nil
        isConnected = false
    }

    // MARK: - Player Actions

    public func updatePlayerReady(_ isReady: Bool) async throws {
        guard var player = currentPlayer, let roomId = room?.id else { return }
        player.isReady = isReady
        try await firebaseService.updatePlayer(player, inRoomId: roomId)
    }

    public func joinTeam(teamId: String) async throws {
        guard var player = currentPlayer, let roomId = room?.id else { return }
        player.teamId = teamId
        try await firebaseService.updatePlayer(player, inRoomId: roomId)
    }

    public func leaveTeam() async throws {
        guard var player = currentPlayer, let roomId = room?.id else { return }
        player.teamId = nil
        try await firebaseService.updatePlayer(player, inRoomId: roomId)
    }

    public func markWordsSubmitted() async throws {
        guard var player = currentPlayer, let roomId = room?.id else { return }
        player.hasSubmittedWords = true
        try await firebaseService.updatePlayer(player, inRoomId: roomId)
    }

    public func leaveRoom() async throws {
        guard let playerId = currentPlayerId, let roomId = room?.id else { return }

        stopObserving()

        if isHost {
            try await firebaseService.deleteRoom(id: roomId)
        } else {
            try await firebaseService.removePlayer(playerId: playerId, fromRoomId: roomId)
        }

        currentPlayerId = nil
    }

    // MARK: - Host Actions

    public func createTeam(name: String, colorHex: String) async throws {
        guard isHost, let roomId = room?.id else {
            throw NetworkingError.notAuthorized
        }

        let team = OnlineTeam(name: name, colorHex: colorHex)
        try await firebaseService.addTeam(team, toRoomId: roomId)
    }

    public func removeTeam(teamId: String) async throws {
        guard isHost, let roomId = room?.id else {
            throw NetworkingError.notAuthorized
        }

        try await firebaseService.removeTeam(teamId: teamId, fromRoomId: roomId)
    }

    public func updateSettings(_ settings: GameSettings) async throws {
        guard isHost, var room = room else {
            throw NetworkingError.notAuthorized
        }

        room.settings = settings
        try await firebaseService.updateRoom(room)
    }

    public func updateRoomStatus(_ status: RoomStatus) async throws {
        guard isHost, let roomId = room?.id else {
            throw NetworkingError.notAuthorized
        }

        try await firebaseService.updateRoomStatus(status, forRoomId: roomId)
    }

    public func startGame() async throws {
        guard isHost else {
            throw NetworkingError.notAuthorized
        }

        try await updateRoomStatus(.playing)
    }

    // MARK: - Word Submission

    public func submitWords(_ words: [String]) async throws {
        guard let playerId = currentPlayerId, let roomId = room?.id else { return }

        let onlineWords = words.map { OnlineWord(text: $0, addedByPlayerId: playerId) }
        try await firebaseService.addWords(onlineWords, toRoomId: roomId)
        try await markWordsSubmitted()
    }

    // MARK: - Game State

    public func updateGameState(_ state: OnlineGameState) async throws {
        guard let roomId = room?.id else { return }
        try await firebaseService.updateGameState(state, forRoomId: roomId)
    }

    public func getWords() async throws -> [OnlineWord] {
        guard let roomId = room?.id else { return [] }
        return try await firebaseService.getWords(forRoomId: roomId)
    }

    // MARK: - Device ID

    private static func getOrCreateDeviceId() -> String {
        let key = "HatGame.deviceId"
        if let existingId = UserDefaults.standard.string(forKey: key) {
            return existingId
        }
        let newId = UUID().uuidString
        UserDefaults.standard.set(newId, forKey: key)
        return newId
    }
}

public enum RoomError: Error, LocalizedError {
    case gameAlreadyStarted
    case roomFull
    case teamFull
    case notEnoughPlayers
    case notEnoughTeams

    public var errorDescription: String? {
        switch self {
        case .gameAlreadyStarted:
            return "Game has already started"
        case .roomFull:
            return "Room is full"
        case .teamFull:
            return "Team is full"
        case .notEnoughPlayers:
            return "Not enough players to start"
        case .notEnoughTeams:
            return "Need at least 2 teams to start"
        }
    }
}

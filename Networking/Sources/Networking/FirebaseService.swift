//
//  FirebaseService.swift
//  Networking
//
//  Created by Giga Khizanishvili on 22.12.24.
//

import Foundation
import FirebaseDatabase
import FirebaseCore

public final class FirebaseService: @unchecked Sendable {
    public static let shared = FirebaseService()

    private var database: Database {
        Database.database()
    }

    private var roomsRef: DatabaseReference {
        database.reference().child("rooms")
    }

    private init() {
        // Lazy initialization - database accessed only when needed
    }

    public var isAvailable: Bool {
        FirebaseApp.app() != nil
    }

    // MARK: - Room Operations

    public func createRoom(_ room: GameRoom) async throws {
        guard isAvailable else { throw NetworkingError.firebaseNotConfigured }
        let roomData = try encodeToDict(room)
        try await roomsRef.child(room.id).setValue(roomData)
    }

    public func getRoom(id: String) async throws -> GameRoom? {
        guard isAvailable else { throw NetworkingError.firebaseNotConfigured }
        return try await withTimeout(seconds: 10) {
            try await withCheckedThrowingContinuation { continuation in
                self.roomsRef.child(id).observeSingleEvent(of: .value) { snapshot in
                    guard snapshot.exists(), let data = snapshot.value else {
                        continuation.resume(returning: nil)
                        return
                    }
                    do {
                        let room = try self.decode(GameRoom.self, from: data)
                        continuation.resume(returning: room)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                } withCancel: { error in
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    public func updateRoom(_ room: GameRoom) async throws {
        guard isAvailable else { throw NetworkingError.firebaseNotConfigured }
        let roomData = try encodeToDict(room)
        try await roomsRef.child(room.id).setValue(roomData)
    }

    public func deleteRoom(id: String) async throws {
        guard isAvailable else { throw NetworkingError.firebaseNotConfigured }
        try await roomsRef.child(id).removeValue()
    }

    public func observeRoom(id: String, onChange: @escaping (GameRoom?) -> Void) -> DatabaseHandle {
        guard isAvailable else {
            onChange(nil)
            return 0
        }
        return roomsRef.child(id).observe(.value) { snapshot in
            guard snapshot.exists(), let data = snapshot.value else {
                onChange(nil)
                return
            }
            do {
                let room = try self.decode(GameRoom.self, from: data)
                onChange(room)
            } catch {
                print("Failed to decode room: \(error)")
                onChange(nil)
            }
        }
    }

    public func removeObserver(handle: DatabaseHandle, forRoomId roomId: String) {
        roomsRef.child(roomId).removeObserver(withHandle: handle)
    }

    // MARK: - Player Operations

    public func addPlayer(_ player: OnlinePlayer, toRoomId roomId: String) async throws {
        guard isAvailable else { throw NetworkingError.firebaseNotConfigured }
        let playerData = try encodeToDict(player)
        try await roomsRef.child(roomId).child("players").child(player.id).setValue(playerData)
    }

    public func updatePlayer(_ player: OnlinePlayer, inRoomId roomId: String) async throws {
        guard isAvailable else { throw NetworkingError.firebaseNotConfigured }
        let playerData = try encodeToDict(player)
        try await roomsRef.child(roomId).child("players").child(player.id).setValue(playerData)
    }

    public func removePlayer(playerId: String, fromRoomId roomId: String) async throws {
        guard isAvailable else { throw NetworkingError.firebaseNotConfigured }
        try await roomsRef.child(roomId).child("players").child(playerId).removeValue()
    }

    // MARK: - Team Operations

    public func addTeam(_ team: OnlineTeam, toRoomId roomId: String) async throws {
        guard isAvailable else { throw NetworkingError.firebaseNotConfigured }
        let teamData = try encodeToDict(team)
        try await roomsRef.child(roomId).child("teams").child(team.id).setValue(teamData)
    }

    public func updateTeam(_ team: OnlineTeam, inRoomId roomId: String) async throws {
        guard isAvailable else { throw NetworkingError.firebaseNotConfigured }
        let teamData = try encodeToDict(team)
        try await roomsRef.child(roomId).child("teams").child(team.id).setValue(teamData)
    }

    public func removeTeam(teamId: String, fromRoomId roomId: String) async throws {
        guard isAvailable else { throw NetworkingError.firebaseNotConfigured }
        try await roomsRef.child(roomId).child("teams").child(teamId).removeValue()
    }

    // MARK: - Word Operations

    public func addWords(_ words: [OnlineWord], toRoomId roomId: String) async throws {
        guard isAvailable else { throw NetworkingError.firebaseNotConfigured }
        var updates: [String: Any] = [:]
        for word in words {
            let wordData = try encodeToDict(word)
            updates["words/\(word.id)"] = wordData
        }
        try await roomsRef.child(roomId).updateChildValues(updates)
    }

    public func getWords(forRoomId roomId: String) async throws -> [OnlineWord] {
        guard isAvailable else { throw NetworkingError.firebaseNotConfigured }
        return try await withTimeout(seconds: 10) {
            try await withCheckedThrowingContinuation { continuation in
                self.roomsRef.child(roomId).child("words").observeSingleEvent(of: .value) { snapshot in
                    guard snapshot.exists(), let data = snapshot.value as? [String: Any] else {
                        continuation.resume(returning: [])
                        return
                    }

                    var words: [OnlineWord] = []
                    for (_, wordData) in data {
                        if let word = try? self.decode(OnlineWord.self, from: wordData) {
                            words.append(word)
                        }
                    }
                    continuation.resume(returning: words)
                } withCancel: { error in
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // MARK: - Game State Operations

    public func updateGameState(_ state: OnlineGameState, forRoomId roomId: String) async throws {
        guard isAvailable else { throw NetworkingError.firebaseNotConfigured }
        let stateData = try encodeToDict(state)
        try await roomsRef.child(roomId).child("gameState").setValue(stateData)
    }

    public func updateRoomStatus(_ status: RoomStatus, forRoomId roomId: String) async throws {
        guard isAvailable else { throw NetworkingError.firebaseNotConfigured }
        try await roomsRef.child(roomId).child("status").setValue(status.rawValue)
    }

    // MARK: - Room Code Generation

    public func generateUniqueRoomCode() async throws -> String {
        guard isAvailable else { throw NetworkingError.firebaseNotConfigured }
        let characters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        let code = String((0..<6).map { _ in characters.randomElement()! })
        return code
    }

    // MARK: - Helpers

    private func encodeToDict<T: Encodable>(_ value: T) throws -> [String: Any] {
        let data = try JSONEncoder().encode(value)
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NetworkingError.encodingFailed
        }
        return dict
    }

    private func decode<T: Decodable>(_ type: T.Type, from value: Any) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: value)
        return try JSONDecoder().decode(type, from: data)
    }

    private func withTimeout<T: Sendable>(seconds: TimeInterval, operation: @Sendable @escaping () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }

            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw NetworkingError.timeout
            }

            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
}

public enum NetworkingError: Error, LocalizedError {
    case roomNotFound
    case failedToGenerateRoomCode
    case encodingFailed
    case decodingFailed
    case notAuthorized
    case firebaseNotConfigured
    case timeout

    public var errorDescription: String? {
        switch self {
        case .roomNotFound:
            return "Room not found"
        case .failedToGenerateRoomCode:
            return "Failed to generate unique room code"
        case .encodingFailed:
            return "Failed to encode data"
        case .decodingFailed:
            return "Failed to decode data"
        case .notAuthorized:
            return "Not authorized to perform this action"
        case .firebaseNotConfigured:
            return "Firebase is not configured. Please check your GoogleService-Info.plist"
        case .timeout:
            return "Operation timed out. Please check your internet connection"
        }
    }
}

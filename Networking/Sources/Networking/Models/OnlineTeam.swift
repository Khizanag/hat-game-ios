//
//  OnlineTeam.swift
//  Networking
//
//  Created by Giga Khizanishvili on 22.12.24.
//

import Foundation

public struct OnlineTeam: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public var name: String
    public var colorHex: String
    public var playerIds: [String]

    public init(
        id: String = UUID().uuidString,
        name: String,
        colorHex: String,
        playerIds: [String] = []
    ) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.playerIds = playerIds
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: OnlineTeam, rhs: OnlineTeam) -> Bool {
        lhs.id == rhs.id
    }
}

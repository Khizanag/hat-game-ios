//
//  HatGameTests.swift
//  HatGameTests
//
//  Created by Giga Khizanishvili on 15.11.25.
//

@testable import HatGame
import SwiftUI
import Testing

@MainActor
struct HatGameTests {
    // MARK: - Fresh words per game
    /// Regression: `mockForTesting` used to be a shared `static let`. Because
    /// `GameConfiguration` is a reference type, one game's words leaked into the
    /// next game played in test mode. Each access must now return a fresh value.
    @Test func mockConfigurationIsFreshOnEachAccess() {
        let first = GameConfiguration.mockForTesting
        first.words.append(Word(text: "leak"))

        let second = GameConfiguration.mockForTesting

        #expect(second.words.isEmpty)
        #expect(first !== second)
    }
}

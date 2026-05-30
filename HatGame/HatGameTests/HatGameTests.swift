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

    // MARK: - Configurable skipping
    @Test func skippingDisabledKeepsCurrentWord() {
        let manager = makeManager(isSkippingEnabled: false)
        manager.start()

        let wordBeforeSkip = manager.currentWord
        manager.skipCurrentWord()

        #expect(manager.currentWord == wordBeforeSkip)
    }

    @Test func skippingEnabledSwapsCurrentWord() {
        let manager = makeManager(isSkippingEnabled: true)
        manager.start()

        let wordBeforeSkip = manager.currentWord
        manager.skipCurrentWord()

        // With more than one word remaining, skipping always hands back a different word.
        #expect(manager.currentWord != wordBeforeSkip)
    }

    // MARK: - Helpers
    private func makeManager(isSkippingEnabled: Bool) -> GameManager {
        let teamId = UUID()
        let team = Team(
            name: "Alpha",
            players: [
                Player(name: "Alice", teamId: teamId),
                Player(name: "Bob", teamId: teamId),
            ],
            color: .blue
        )
        let configuration = GameConfiguration(
            isSkippingEnabled: isSkippingEnabled,
            teams: [team],
            words: [Word(text: "one"), Word(text: "two"), Word(text: "three")]
        )
        return GameManager(configuration: configuration)
    }
}

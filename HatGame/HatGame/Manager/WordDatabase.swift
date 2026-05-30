//
//  WordDatabase.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 26.11.25.
//

import Foundation
import OSLog

private let logger = Logger(subsystem: "com.khizanag.hat-game", category: "WordDatabase")

/// Curated database of Georgian nouns and verbal nouns (masdars) for the game.
///
/// Sourced from Wiktionary's Georgian noun lemmas, filtered to common, guessable
/// words across many topics, and shipped as a bundled resource (`georgian-words.txt`)
/// rather than an inline array — this keeps the list easy to grow and avoids
/// slowing compilation with a multi-thousand-element literal.
enum WordDatabase {
    /// All curated words, loaded once from the bundled resource.
    static let words: [String] = loadWords()

    /// Returns a random subset of `count` words from the database.
    static func randomWords(count: Int) -> [String] {
        guard count > 0 else { return [] }
        return Array(words.shuffled().prefix(count))
    }

    /// Returns all words shuffled.
    static func allWordsShuffled() -> [String] {
        words.shuffled()
    }

    private static func loadWords() -> [String] {
        guard let url = Bundle.main.url(forResource: "georgian-words", withExtension: "txt"),
              let contents = try? String(contentsOf: url, encoding: .utf8) else {
            logger.error("Missing bundled resource georgian-words.txt")
            return []
        }
        return contents
            .split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
}

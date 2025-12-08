//
//  GameManager.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

final class HistoryManager {

    private var configuration: GameConfiguration = .init()
    private var history: [GameRound: [Team: Set<Word>]] = [:]

    func setUp(configuration: GameConfiguration) {
        self.configuration = configuration
    }

    func saveThatTeamGuessedWord(word: Word, for team: Team, round: GameRound) {
        var oldWords = history[round]?[team] ?? []
        oldWords.insert(word)

        var oldRound = history[round] ?? [:]
        oldRound[team] = oldWords

        history[round] = oldRound
    }

    func prepareForNewRound(_ round: GameRound) {
        var dict: [Team: Set<Word>] = [:]
        for team in configuration.teams {
            dict[team] = []
        }
        history[round] = dict
    }

    func rankingForRound(_ round: GameRound) -> [(Team, Int)]? {
        guard let roundResults = history[round] else {
            return nil
        }

        return roundResults
            .map { roundResult in
                let team = roundResult.key
                let words = roundResult.value

                return (team, words.count)
            }
            .sorted { $0.1 > $1.1 }
    }

    func fullCurrentRanking() -> [(GameRound, [(Team, Int)])] {
        GameConfiguration.rounds.compactMap { round in
            guard let a = rankingForRound(round) else {
                return nil
            }
            return (round, a)
        }
    }

    func totalRanking() -> [(Team, Int)] {
        var totalRanking: [Team: Int] = [:]
        for round in GameConfiguration.rounds {
            let ranking = rankingForRound(round) ?? []
            for (team, score) in ranking {
                totalRanking[team, default: 0] += score
            }
        }
        return totalRanking.sorted { $0.1 > $1.1 }
    }
}

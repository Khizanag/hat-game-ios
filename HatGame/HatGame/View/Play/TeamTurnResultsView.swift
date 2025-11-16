//
//  TeamTurnResultsView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 16.11.25.
//

import SwiftUI

struct TeamTurnResultsView: View {
    let guessedWords: [Word]

    @Environment(GameManager.self) private var gameManager
    @Environment(Navigator.self) private var navigator

    var body: some View {
        resultsScroll
            .setDefaultBackground()
            .navigationBarBackButtonHidden()
    }
}

// MARK: - Private
private extension TeamTurnResultsView {
    var resultsScroll: some View {
        ScrollView {
            VStack(spacing: DesignBook.Spacing.lg) {
                Spacer()
                    .frame(height: DesignBook.Spacing.lg)
                header
                resultsCard
                wordsSection
            }
            .paddingHorizontalDefault()
            .padding(.bottom, DesignBook.Spacing.xxl)
        }
        .safeAreaInset(edge: .bottom) {
            continueButton
                .paddingHorizontalDefault()
        }
    }

    var header: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            Text("⏱️")
                .font(.system(size: 80))

            Text("Time's Up!")
                .font(DesignBook.Font.largeTitle)
                .foregroundColor(DesignBook.Color.Text.primary)
        }
    }

    @ViewBuilder
    var resultsCard: some View {
        let team = gameManager.currentTeam

        GameCard {
            VStack(spacing: DesignBook.Spacing.md) {
                Text("\(team.name)'s Results")
                    .font(DesignBook.Font.title2)
                    .foregroundColor(team.color)

                Text("Words guessed this turn: \(guessedWords.count)")
                    .font(DesignBook.Font.headline)
                    .foregroundColor(DesignBook.Color.Text.secondary)
            }
        }
    }

    @ViewBuilder
    var wordsSection: some View {
        if guessedWords.isEmpty {
            emptyStateCard
        } else {
            guessedWordsCard
        }
    }

    var guessedWordsCard: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                Text("Words Guessed")
                    .font(DesignBook.Font.headline)
                    .foregroundColor(DesignBook.Color.Text.primary)

                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: DesignBook.Spacing.sm
                ) {
                    ForEach(guessedWords) { word in
                        Text(word.text)
                            .font(DesignBook.Font.body)
                            .foregroundColor(DesignBook.Color.Text.secondary)
                            .padding(DesignBook.Spacing.sm)
                            .frame(maxWidth: .infinity)
                            .background(DesignBook.Color.Background.secondary)
                            .cornerRadius(DesignBook.Size.smallCardCornerRadius)
                    }
                }
            }
        }
    }

    var emptyStateCard: some View {
        GameCard {
            Text("No words guessed this turn")
                .font(DesignBook.Font.body)
                .foregroundColor(DesignBook.Color.Text.secondary)
        }
    }

    var continueButton: some View {
        PrimaryButton(title: "Continue") {
            if let round = gameManager.currentRound {
                //                    gameManager.setNextTeam()
                navigator.push(
                    .nextTeam(
                        round: round,
                        team: gameManager.configuration.teams[0]/*team*/
                    )
                )
            } else {
                navigator.push(.finalResults)
            }
        }
    }
}
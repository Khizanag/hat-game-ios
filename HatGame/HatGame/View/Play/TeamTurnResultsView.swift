//
//  TeamTurnResultsView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 16.11.25.
//

import SwiftUI

struct TeamTurnResultsView: View {
    @Environment(GameManager.self) private var gameManager
    @Environment(Navigator.self) private var navigator

    let guessedWords: [Word]
    @State private var isStandingsPresented = false

    var body: some View {
        resultsScroll
            .setDefaultBackground()
            .navigationBarBackButtonHidden()
            .sheet(isPresented: $isStandingsPresented) {
                NavigationView {
                    ResultsView()
                }
            }
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
            buttonsSection
                .paddingHorizontalDefault()
        }
    }

    var header: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            Text("⏱️")
                .font(.system(size: 80))

            Text("game.turn_results.time_up")
                .font(DesignBook.Font.largeTitle)
                .foregroundColor(DesignBook.Color.Text.primary)
        }
    }

    @ViewBuilder
    var resultsCard: some View {
        let team = gameManager.currentTeam

        GameCard {
            VStack(spacing: DesignBook.Spacing.md) {
                Text(String(format: String(localized: "game.turn_results.team_title"), team.name))
                    .font(DesignBook.Font.title2)
                    .foregroundColor(team.color)

                Text(String(format: String(localized: "game.turn_results.words_guessed_count"), guessedWords.count))
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
                Text("game.turn_results.words_guessed")
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
            Text("game.turn_results.no_words_guessed")
                .font(DesignBook.Font.body)
                .foregroundColor(DesignBook.Color.Text.secondary)
        }
    }

    var buttonsSection: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            SecondaryButton(title: String(localized: "game.turn_results.check_standings")) {
                isStandingsPresented = true
            }

            PrimaryButton(title: String(localized: "common.buttons.continue"), icon: "arrow.right.circle.fill") {
                gameManager.prepareForNewPlay()

                if let round = gameManager.currentRound {
                    navigator.push(
                        .nextTeam(
                            round: round,
                            team: gameManager.currentTeam
                        )
                    )
                } else {
                    navigator.push(.finalResults)
                }
            }
        }
    }
}

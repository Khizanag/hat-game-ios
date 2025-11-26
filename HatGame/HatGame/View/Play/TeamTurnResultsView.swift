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
    let completionReason: PlayCompletionReason
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
                .withFooterGradient()
        }
    }

    var header: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            Text(completionReason == .timeExpired ? "⏱️" : "✨")
                .font(DesignBook.IconFont.emoji)

            Text(completionReason == .timeExpired ? "game.turnResults.timeUp" : "game.turnResults.allWordsGuessed")
                .font(DesignBook.Font.largeTitle)
                .foregroundColor(DesignBook.Color.Text.primary)
        }
    }

    @ViewBuilder
    var resultsCard: some View {
        let team = gameManager.currentTeam

        GameCard {
            VStack(spacing: DesignBook.Spacing.md) {
                Text(String(format: String(localized: "game.turnResults.teamTitle"), team.name))
                    .font(DesignBook.Font.title2)
                    .foregroundColor(team.color)

                Text(String(format: String(localized: "game.turnResults.wordsGuessedCount"), guessedWords.count))
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
                Text("game.turnResults.wordsGuessed")
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
            Text("game.turnResults.noWordsGuessed")
                .font(DesignBook.Font.body)
                .foregroundColor(DesignBook.Color.Text.secondary)
        }
    }

    var buttonsSection: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            SecondaryButton(title: String(localized: "game.turnResults.checkStandings"), icon: "list.bullet.rectangle") {
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

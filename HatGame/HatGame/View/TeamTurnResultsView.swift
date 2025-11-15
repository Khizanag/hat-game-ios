//
//  TeamTurnResultsView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct TeamTurnResultsView: View {
    let team: Team
    let teamIndex: Int
    let guessedWords: [Word]
    let round: GameRound
    let onContinue: () -> Void
    
    var body: some View {
        ZStack {
            backgroundLayer
            resultsScroll
            continueButton
        }
    }
}

private extension TeamTurnResultsView {
    var backgroundLayer: some View {
        DesignBook.Color.Background.primary
            .ignoresSafeArea()
    }
    
    var resultsScroll: some View {
        ScrollView {
            VStack(spacing: DesignBook.Spacing.lg) {
                Spacer()
                    .frame(height: DesignBook.Spacing.lg)
                header
                resultsCard
                wordsSection
                Spacer()
                    .frame(height: DesignBook.Spacing.xl)
            }
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
    
    var resultsCard: some View {
        GameCard {
            VStack(spacing: DesignBook.Spacing.md) {
                Text("\(team.name)'s Results")
                    .font(DesignBook.Font.title2)
                    .foregroundColor(DesignBook.Color.Team.color(for: teamIndex))
                
                Text("Words guessed this turn: \(guessedWords.count)")
                    .font(DesignBook.Font.headline)
                    .foregroundColor(DesignBook.Color.Text.secondary)
            }
        }
        .padding(.horizontal, DesignBook.Spacing.lg)
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
        .padding(.horizontal, DesignBook.Spacing.lg)
    }
    
    var emptyStateCard: some View {
        GameCard {
            Text("No words guessed this turn")
                .font(DesignBook.Font.body)
                .foregroundColor(DesignBook.Color.Text.secondary)
        }
        .padding(.horizontal, DesignBook.Spacing.lg)
    }
    
    var continueButton: some View {
        VStack {
            Spacer()
            PrimaryButton(title: "Continue") {
                onContinue()
            }
            .padding(.horizontal, DesignBook.Spacing.lg)
            .padding(.bottom, DesignBook.Spacing.lg)
        }
    }
}

// MARK: - Preview
#Preview {
    let team = Team(name: "Team Alpha")
    let words = [
        Word(text: "Apple"),
        Word(text: "Banana"),
        Word(text: "Cherry")
    ]
    return TeamTurnResultsView(
        team: team,
        teamIndex: 0,
        guessedWords: words,
        round: .one,
        onContinue: {}
    )
}


//
//  RandomizationView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct RandomizationView: View {
    @Environment(GameManager.self) private var gameManager
    @Environment(Navigator.self) private var navigator
    @State private var isShuffling: Bool = false
    @State private var selectedStartingTeamIndex: Int = 0

    var body: some View {
        content
            .setDefaultStyle(title: "Randomize")
            .navigationBarBackButtonHidden()
    }
}

private extension RandomizationView {
    var content: some View {
        readyContent
            .paddingHorizontalDefault()
            .overlay {
                if isShuffling {
                    ZStack {
                        Color.clear
                            .background(Material.ultraThin)

                        shufflingContent

                    }
                }
            }
    }

    var shufflingContent: some View {
        GameCard {
            VStack(spacing: DesignBook.Spacing.md) {
                ProgressView()
                    .scaleEffect(1.5)

                Text("Shuffling words...")
                    .font(DesignBook.Font.headline)
                    .foregroundColor(DesignBook.Color.Text.secondary)
            }
            .frame(height: 200)
        }
        .paddingHorizontalDefault()
        .frame(maxHeight: .infinity)
    }

    var readyContent: some View {
        VStack {
            GameCard {
                VStack(spacing: DesignBook.Spacing.md) {
                    Text("🎲")
                        .font(.system(size: 80))

                    Text("Randomize Words")
                        .font(DesignBook.Font.title2)
                        .foregroundColor(DesignBook.Color.Text.primary)

                    Text("\(gameManager.configuration.words.count) words ready")
                        .font(DesignBook.Font.body)
                        .foregroundColor(DesignBook.Color.Text.secondary)
                }
            }

            Spacer()

            startingTeamPickerCard

            Spacer()

            shuffleButton
        }
    }

    var startingTeamPickerCard: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                Text("Which team starts?")
                    .font(DesignBook.Font.headline)
                    .foregroundColor(DesignBook.Color.Text.primary)

                Picker("Starting Team", selection: $selectedStartingTeamIndex) {
                    ForEach(Array(gameManager.configuration.teams.enumerated()), id: \.offset) { index, team in
                        Text(team.name)
                            .tag(index)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
            }
        }
    }

    var shuffleButton: some View {
        PrimaryButton(title: "Shuffle & Start") {
            shuffleAndStart()
        }
    }

    func shuffleAndStart() {
        isShuffling = true

        DispatchQueue.main.asyncAfter(deadline: .now() /*+ 1.5*/) { // TODO: Revert
            gameManager.start()
            navigator.push(
                .play(
                    round: .first // TODO: Change with dynamic value
                )
            )
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        Page.randomization.view()
    }
    .environment(GameManager())
}
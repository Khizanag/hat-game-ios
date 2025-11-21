//
//  NextTeamView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct NextTeamView: View {
    @Environment(Navigator.self) private var navigator
    @Environment(GameManager.self) private var gameManager

    @State private var isStandingsPresented = false

    let round: GameRound
    let team: Team

    let explainingPlayer: Player = .init(name: "Anonymous", teamId: .init())
    let guessingPlayer: Player = .init(name: "James", teamId: .init())

    var body: some View {
        content
            .setDefaultStyle()
            .navigationBarBackButtonHidden()
            .sheet(isPresented: $isStandingsPresented) {
                NavigationView {
                    ResultsView()
                }
            }
    }
}

// MARK: - Components
private extension NextTeamView {
    var content: some View {
        ScrollView {
            VStack {
                teamDetails
                    .paddingHorizontalDefault()
            }
            .padding(.bottom, DesignBook.Spacing.xxl)
        }
        .safeAreaInset(edge: .bottom) {
            buttonsSection
                .paddingHorizontalDefault()
        }
    }

    var teamDetails: some View {
        VStack(spacing: DesignBook.Spacing.lg) {
            Text("🎯")
                .font(DesignBook.IconFont.emoji)

            Text("game.nextTeam.title")
                .font(DesignBook.Font.largeTitle)
                .foregroundColor(DesignBook.Color.Text.primary)

            teamScoreCard
            roundStatusCard
            rolesCard
        }
    }

    var teamScoreCard: some View {
        GameCard {
            VStack(spacing: DesignBook.Spacing.md) {
                Text(team.name)
                    .font(DesignBook.Font.title2)
                    .foregroundColor(team.color)

                Text(String(format: String(localized: "game.currentScoreLabel"), gameManager.getTotalScore(for: team)))
                    .font(DesignBook.Font.headline)
                    .foregroundColor(DesignBook.Color.Text.accent)
            }
        }
    }

    var roundStatusCard: some View {
        GameCard {
            VStack(spacing: DesignBook.Spacing.md) {
                Text("game.nextTeam.roundStatus")
                    .font(DesignBook.Font.headline)
                    .foregroundColor(DesignBook.Color.Text.primary)

                Text(round.title)
                    .font(DesignBook.Font.title3)
                    .foregroundColor(DesignBook.Color.Text.secondary)

                Text(String(format: String(localized: "game.wordsRemainingLabel"), gameManager.remainingWordCount))
                    .font(DesignBook.Font.body)
                    .foregroundColor(DesignBook.Color.Text.secondary)
            }
        }
    }

    var rolesCard: some View {
        GameCard {
            VStack(spacing: DesignBook.Spacing.md) {
                Text("game.nextTeam.teamRoles")
                    .font(DesignBook.Font.headline)
                    .foregroundColor(DesignBook.Color.Text.primary)

                VStack(spacing: DesignBook.Spacing.sm) {
                    roleRow(icon: "person.wave.2.fill", label: String(localized: "game.nextTeam.role.explaining"), value: explainingPlayer.name)
                    roleRow(icon: "lightbulb.fill", label: String(localized: "game.nextTeam.role.guessing"), value: guessingPlayer.name)
                }
            }
        }
    }

    func roleRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(DesignBook.Color.Text.accent)
            Text("\(label):")
                .font(DesignBook.Font.body)
                .foregroundColor(DesignBook.Color.Text.secondary)
            Spacer()
            Text(value)
                .font(DesignBook.Font.bodyBold)
                .foregroundColor(DesignBook.Color.Text.primary)
        }
    }

    var buttonsSection: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            SecondaryButton(title: String(localized: "game.turnResults.checkStandings"), icon: "list.bullet.rectangle") {
                isStandingsPresented = true
            }

            PrimaryButton(title: String(localized: "common.buttons.play"), icon: "play.fill") {
                gameManager.prepareForNewPlay()
                navigator.push(.play(round: round))
            }
        }
    }
}

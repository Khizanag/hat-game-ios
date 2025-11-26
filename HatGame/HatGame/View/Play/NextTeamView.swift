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
    @State private var selectedExplainerIndex: Int = 0

    let round: GameRound
    let team: Team

    private var isFirstPlay: Bool {
        gameManager.getExplainerIndex(for: team) == nil
    }

    private var currentExplainer: Player? {
        gameManager.getExplainer(for: team)
    }

    private var currentGuessers: [Player] {
        gameManager.getGuessers(for: team)
    }

    var body: some View {
        content
            .setDefaultStyle()
            .navigationBarBackButtonHidden()
            .sheet(isPresented: $isStandingsPresented) {
                NavigationView {
                    ResultsView()
                }
            }
            .onAppear {
                if let explainerIndex = gameManager.getExplainerIndex(for: team) {
                    selectedExplainerIndex = explainerIndex
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
                .withFooterGradient()
        }
    }

    var teamDetails: some View {
        VStack(spacing: DesignBook.Spacing.lg) {
            Text("🎯")
                .font(DesignBook.IconFont.emoji)

            Text("game.nextTeam.title")
                .font(DesignBook.Font.largeTitle)
                .foregroundColor(DesignBook.Color.Text.primary)

            rolesCard
            teamScoreCard
            roundStatusCard
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

    @ViewBuilder
    var rolesCard: some View {
        if isFirstPlay {
            roleSelectionCard
        } else {
            currentRolesCard
        }
    }

    var roleSelectionCard: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.lg) {
                HStack {
                    VStack(alignment: .leading, spacing: DesignBook.Spacing.xs) {
                        Text("game.nextTeam.selectExplainer")
                            .font(DesignBook.Font.headline)
                            .foregroundColor(DesignBook.Color.Text.primary)

                        Text("game.nextTeam.selectExplainer.description")
                            .font(DesignBook.Font.caption)
                            .foregroundColor(DesignBook.Color.Text.secondary)
                    }

                    Spacer()

                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            let randomIndex = Int.random(in: 0..<team.players.count)
                            selectedExplainerIndex = randomIndex
                            gameManager.setExplainer(playerIndex: randomIndex, for: team)
                        }
                    } label: {
                        Image(systemName: "shuffle")
                            .font(DesignBook.Font.body)
                            .foregroundColor(DesignBook.Color.Text.accent)
                            .padding(DesignBook.Spacing.sm)
                            .background(DesignBook.Color.Background.secondary)
                            .cornerRadius(DesignBook.Size.smallCardCornerRadius)
                    }
                }

                VStack(spacing: DesignBook.Spacing.sm) {
                    ForEach(Array(team.players.enumerated()), id: \.element.id) { index, player in
                        playerSelectionRow(player: player, index: index, isSelected: selectedExplainerIndex == index)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedExplainerIndex = index
                                    gameManager.setExplainer(playerIndex: index, for: team)
                                }
                            }
                    }
                }
            }
        }
    }

    func playerSelectionRow(player: Player, index: Int, isSelected: Bool) -> some View {
        HStack(spacing: DesignBook.Spacing.md) {
            // Selection indicator
            ZStack {
                Circle()
                    .stroke(
                        isSelected ? team.color : DesignBook.Color.Text.tertiary.opacity(0.3),
                        lineWidth: 2
                    )
                    .frame(width: 24, height: 24)

                if isSelected {
                    Circle()
                        .fill(team.color)
                        .frame(width: 16, height: 16)
                }
            }

            // Player name
            Text(player.name)
                .font(isSelected ? DesignBook.Font.bodyBold : DesignBook.Font.body)
                .foregroundColor(DesignBook.Color.Text.primary)

            Spacer()

            // Role badge
            if isSelected {
                Text("game.nextTeam.role.explaining")
                    .font(DesignBook.Font.caption)
                    .foregroundColor(team.color)
                    .padding(.horizontal, DesignBook.Spacing.sm)
                    .padding(.vertical, DesignBook.Spacing.xs)
                    .background(team.color.opacity(0.15))
                    .cornerRadius(DesignBook.Size.smallCardCornerRadius)
            } else {
                Text("game.nextTeam.role.guessing")
                    .font(DesignBook.Font.caption)
                    .foregroundColor(DesignBook.Color.Text.secondary)
                    .padding(.horizontal, DesignBook.Spacing.sm)
                    .padding(.vertical, DesignBook.Spacing.xs)
                    .background(DesignBook.Color.Background.secondary)
                    .cornerRadius(DesignBook.Size.smallCardCornerRadius)
            }
        }
        .padding(DesignBook.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignBook.Size.cardCornerRadius)
                .fill(isSelected ? team.color.opacity(0.05) : DesignBook.Color.Background.secondary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignBook.Size.cardCornerRadius)
                .stroke(isSelected ? team.color.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }

    var currentRolesCard: some View {
        GameCard {
            VStack(spacing: DesignBook.Spacing.md) {
                HStack {
                    Text("game.nextTeam.teamRoles")
                        .font(DesignBook.Font.headline)
                        .foregroundColor(DesignBook.Color.Text.primary)

                    Spacer()

                    // Show rotation indicator if roles changed
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(DesignBook.Font.caption)
                        .foregroundColor(DesignBook.Color.Text.accent)
                }

                VStack(spacing: DesignBook.Spacing.md) {
                    // Explainer section
                    if let explainer = currentExplainer {
                        VStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
                            HStack(spacing: DesignBook.Spacing.xs) {
                                Image(systemName: "person.wave.2.fill")
                                    .font(DesignBook.Font.caption)
                                    .foregroundColor(team.color)

                                Text("game.nextTeam.role.explaining")
                                    .font(DesignBook.Font.caption)
                                    .foregroundColor(DesignBook.Color.Text.secondary)
                            }

                            HStack(spacing: DesignBook.Spacing.sm) {
                                Circle()
                                    .fill(team.color.opacity(0.6))
                                    .frame(width: 6, height: 6)

                                Text(explainer.name)
                                    .font(DesignBook.Font.bodyBold)
                                    .foregroundColor(team.color)
                            }
                            .padding(DesignBook.Spacing.sm)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(team.color.opacity(0.1))
                            .cornerRadius(DesignBook.Size.smallCardCornerRadius)
                        }
                    }

                    // Guessers section
                    if !currentGuessers.isEmpty {
                        VStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
                            HStack(spacing: DesignBook.Spacing.xs) {
                                Image(systemName: "lightbulb.fill")
                                    .font(DesignBook.Font.caption)
                                    .foregroundColor(DesignBook.Color.Text.accent)

                                Text("game.nextTeam.role.guessing")
                                    .font(DesignBook.Font.caption)
                                    .foregroundColor(DesignBook.Color.Text.secondary)
                            }

                            VStack(alignment: .leading, spacing: DesignBook.Spacing.xs) {
                                ForEach(currentGuessers) { guesser in
                                    HStack(spacing: DesignBook.Spacing.sm) {
                                        Circle()
                                            .fill(DesignBook.Color.Text.accent.opacity(0.3))
                                            .frame(width: 6, height: 6)

                                        Text(guesser.name)
                                            .font(DesignBook.Font.body)
                                            .foregroundColor(DesignBook.Color.Text.primary)
                                    }
                                    .padding(.horizontal, DesignBook.Spacing.sm)
                                    .padding(.vertical, DesignBook.Spacing.xs)
                                }
                            }
                            .padding(DesignBook.Spacing.sm)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(DesignBook.Color.Background.secondary)
                            .cornerRadius(DesignBook.Size.smallCardCornerRadius)
                        }
                    }
                }
            }
        }
    }

    var buttonsSection: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            SecondaryButton(title: String(localized: "game.turnResults.checkStandings"), icon: "list.bullet.rectangle") {
                isStandingsPresented = true
            }

            PrimaryButton(title: String(localized: "common.buttons.play"), icon: "play.fill") {
                // Ensure explainer is set before playing
                if isFirstPlay {
                    gameManager.setExplainer(playerIndex: selectedExplainerIndex, for: team)
                }
                navigator.push(.play(round: round))
            }
        }
    }
}

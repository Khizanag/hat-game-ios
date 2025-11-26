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
    @State private var isRandomizingTeam: Bool = false
    @State private var selectedStartingTeamIndex: Int = 0
    @State private var showTeamReveal: Bool = false
    @State private var rotationAngle: Double = 0

    var body: some View {
        content
            .setDefaultStyle(title: String(localized: "randomization.title"))
            .navigationBarBackButtonHidden()
    }
}

// MARK: - Private
private extension RandomizationView {
    var content: some View {
        ZStack {
            readyContent
                .blur(radius: isShuffling ? 10 : 0)
                .opacity(isShuffling ? 0.3 : 1)

            if isShuffling {
                shufflingOverlay
            }
        }
    }

    var shufflingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: DesignBook.Spacing.xl) {
                // Animated dice
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    DesignBook.Color.Text.accent,
                                    DesignBook.Color.Text.accent.opacity(0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .shadow(color: DesignBook.Color.Text.accent.opacity(0.5), radius: 20, x: 0, y: 10)
                        .rotation3DEffect(
                            .degrees(rotationAngle),
                            axis: (x: 1, y: 1, z: 0)
                        )

                    Image(systemName: "dice.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                        .rotation3DEffect(
                            .degrees(rotationAngle),
                            axis: (x: 1, y: 1, z: 0)
                        )
                }

                VStack(spacing: DesignBook.Spacing.sm) {
                    Text("randomization.shuffling.message")
                        .font(DesignBook.Font.title2)
                        .foregroundColor(.white)

                    HStack(spacing: 4) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(.white.opacity(0.8))
                                .frame(width: 8, height: 8)
                                .scaleEffect(loadingDotScale(for: index))
                                .animation(
                                    .easeInOut(duration: 0.6)
                                        .repeatForever()
                                        .delay(Double(index) * 0.2),
                                    value: isShuffling
                                )
                        }
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
    }

    func loadingDotScale(for index: Int) -> CGFloat {
        isShuffling ? 1.5 : 1.0
    }

    var readyContent: some View {
        ScrollView {
            VStack(spacing: DesignBook.Spacing.xl) {
                headerCard

                wordsReadyCard

                startingTeamSection

                Spacer()
            }
            .paddingHorizontalDefault()
            .padding(.top, DesignBook.Spacing.lg)
            .padding(.bottom, DesignBook.Spacing.xxl)
        }
        .safeAreaInset(edge: .bottom) {
            shuffleButton
                .paddingHorizontalDefault()
                .padding(.bottom, DesignBook.Spacing.sm)
        }
    }

    var headerCard: some View {
        GameCard {
            VStack(spacing: DesignBook.Spacing.lg) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    DesignBook.Color.Text.accent.opacity(0.2),
                                    DesignBook.Color.Text.accent.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)

                    Image(systemName: "sparkles")
                        .font(.system(size: 50))
                        .foregroundColor(DesignBook.Color.Text.accent)
                        .symbolEffect(.pulse, options: .repeating)
                }

                VStack(spacing: DesignBook.Spacing.xs) {
                    Text("randomization.header.title")
                        .font(DesignBook.Font.title2)
                        .foregroundColor(DesignBook.Color.Text.primary)

                    Text("randomization.header.subtitle")
                        .font(DesignBook.Font.body)
                        .foregroundColor(DesignBook.Color.Text.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(DesignBook.Spacing.lg)
        }
    }

    var wordsReadyCard: some View {
        GameCard {
            HStack(spacing: DesignBook.Spacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: DesignBook.Size.smallCardCornerRadius)
                        .fill(DesignBook.Color.Status.success.opacity(0.15))
                        .frame(width: 50, height: 50)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(DesignBook.Color.Status.success)
                }

                VStack(alignment: .leading, spacing: DesignBook.Spacing.xs) {
                    Text("randomization.wordsReady.title")
                        .font(DesignBook.Font.headline)
                        .foregroundColor(DesignBook.Color.Text.primary)

                    Text(String(format: String(localized: "randomization.wordsReady.count"), gameManager.configuration.words.count))
                        .font(DesignBook.Font.body)
                        .foregroundColor(DesignBook.Color.Text.secondary)
                }

                Spacer()

                Text("\(gameManager.configuration.words.count)")
                    .font(DesignBook.Font.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(DesignBook.Color.Status.success)
            }
            .padding(DesignBook.Spacing.lg)
        }
    }

    var startingTeamSection: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            HStack {
                Text("randomization.startingTeam.title")
                    .font(DesignBook.Font.title3)
                    .foregroundColor(DesignBook.Color.Text.primary)

                Spacer()

                if !showTeamReveal {
                    Button {
                        randomizeStartingTeam()
                    } label: {
                        HStack(spacing: DesignBook.Spacing.xs) {
                            Image(systemName: isRandomizingTeam ? "sparkles" : "shuffle")
                                .font(DesignBook.Font.caption)
                                .symbolEffect(.pulse, options: .repeating, isActive: isRandomizingTeam)

                            Text("randomization.startingTeam.randomize")
                                .font(DesignBook.Font.caption)
                        }
                        .foregroundColor(DesignBook.Color.Text.accent)
                        .padding(.horizontal, DesignBook.Spacing.md)
                        .padding(.vertical, DesignBook.Spacing.sm)
                        .background(DesignBook.Color.Text.accent.opacity(0.1))
                        .cornerRadius(DesignBook.Size.smallCardCornerRadius)
                    }
                    .disabled(isRandomizingTeam)
                }
            }

            if showTeamReveal {
                revealedTeamCard
                    .transition(.scale.combined(with: .opacity))
            } else {
                teamsGrid
            }
        }
    }

    var teamsGrid: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            ForEach(Array(gameManager.configuration.teams.enumerated()), id: \.offset) { index, team in
                teamCard(team: team, index: index, isSelected: selectedStartingTeamIndex == index)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedStartingTeamIndex = index
                            showTeamReveal = false
                        }
                    }
            }
        }
    }

    func teamCard(team: Team, index: Int, isSelected: Bool) -> some View {
        HStack(spacing: DesignBook.Spacing.md) {
            // Team color indicator
            RoundedRectangle(cornerRadius: DesignBook.Size.smallCardCornerRadius)
                .fill(team.color)
                .frame(width: 8)

            // Team info
            VStack(alignment: .leading, spacing: DesignBook.Spacing.xs) {
                Text(team.name)
                    .font(DesignBook.Font.headline)
                    .foregroundColor(DesignBook.Color.Text.primary)

                Text(String(format: String(localized: "randomization.team.players"), team.players.count))
                    .font(DesignBook.Font.caption)
                    .foregroundColor(DesignBook.Color.Text.secondary)
            }

            Spacer()

            // Selection indicator
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(DesignBook.IconFont.medium)
                    .foregroundColor(DesignBook.Color.Text.accent)
            } else {
                Image(systemName: "circle")
                    .font(DesignBook.IconFont.medium)
                    .foregroundColor(DesignBook.Color.Text.tertiary)
            }
        }
        .padding(DesignBook.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignBook.Size.cardCornerRadius)
                .fill(DesignBook.Color.Background.card)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignBook.Size.cardCornerRadius)
                        .stroke(isSelected ? team.color : Color.clear, lineWidth: 2)
                )
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
    }

    var revealedTeamCard: some View {
        let team = gameManager.configuration.teams[selectedStartingTeamIndex]

        return GameCard {
            VStack(spacing: DesignBook.Spacing.lg) {
                // Trophy icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    team.color.opacity(0.3),
                                    team.color.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)

                    Image(systemName: "trophy.fill")
                        .font(.system(size: 40))
                        .foregroundColor(team.color)
                        .symbolEffect(.bounce, value: showTeamReveal)
                }

                VStack(spacing: DesignBook.Spacing.sm) {
                    Text("randomization.startingTeam.selected")
                        .font(DesignBook.Font.caption)
                        .foregroundColor(DesignBook.Color.Text.secondary)

                    Text(team.name)
                        .font(DesignBook.Font.title)
                        .fontWeight(.bold)
                        .foregroundColor(team.color)

                    Text("randomization.startingTeam.goesFirst")
                        .font(DesignBook.Font.body)
                        .foregroundColor(DesignBook.Color.Text.secondary)
                }

                // Players list
                VStack(alignment: .leading, spacing: DesignBook.Spacing.xs) {
                    ForEach(team.players) { player in
                        HStack(spacing: DesignBook.Spacing.sm) {
                            Circle()
                                .fill(team.color.opacity(0.3))
                                .frame(width: 8, height: 8)

                            Text(player.name)
                                .font(DesignBook.Font.body)
                                .foregroundColor(DesignBook.Color.Text.primary)
                        }
                    }
                }
                .padding(DesignBook.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(DesignBook.Color.Background.secondary)
                .cornerRadius(DesignBook.Size.smallCardCornerRadius)
            }
            .padding(DesignBook.Spacing.lg)
        }
    }

    var shuffleButton: some View {
        PrimaryButton(
            title: String(localized: "randomization.shuffleAndStart"),
            icon: "play.fill"
        ) {
            shuffleAndStart()
        }
        .disabled(isShuffling || isRandomizingTeam)
    }

    func randomizeStartingTeam() {
        guard !isRandomizingTeam else { return }

        withAnimation(.easeInOut(duration: 0.3)) {
            isRandomizingTeam = true
            showTeamReveal = false
        }

        // Cycle through teams rapidly for drama
        var cycleCount = 0
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            cycleCount += 1
            withAnimation(.easeInOut(duration: 0.1)) {
                selectedStartingTeamIndex = Int.random(in: 0..<gameManager.configuration.teams.count)
            }

            if cycleCount >= 20 {
                timer.invalidate()
                // Final selection
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                        selectedStartingTeamIndex = Int.random(in: 0..<gameManager.configuration.teams.count)
                        isRandomizingTeam = false
                        showTeamReveal = true
                    }
                }
            }
        }
    }

    func shuffleAndStart() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isShuffling = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            gameManager.start(startingTeamIndex: selectedStartingTeamIndex)
            navigator.push(
                .play(
                    round: .first
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

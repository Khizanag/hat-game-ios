//
//  HomeView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import DesignBook
import Navigation
import SwiftUI

struct HomeView: View {
    @Environment(Navigator.self) private var navigator
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @SceneStorage("HomeView.isHowToPlayExpanded") private var isHowToPlayExpanded: Bool = true
    @State private var isHeroFloating: Bool = false

    private let appConfiguration = AppConfiguration.shared

    var body: some View {
        content
            .background {
                heroBackdrop.ignoresSafeArea()
            }
    }
}

// MARK: - Composition
private extension HomeView {
    var heroBackdrop: some View {
        ZStack {
            DesignBook.Color.Background.primary
            DesignBook.Gradient.brandBackdrop
                .opacity(0.9)
        }
    }

    var content: some View {
        ScrollView {
            VStack(spacing: DesignBook.Spacing.xl) {
                hero
                howToPlayCard
                Spacer().frame(height: DesignBook.Spacing.xl)
            }
        }
        .safeAreaInset(edge: .bottom) {
            actionButtons
                .withFooterGradient()
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                isHeroFloating = true
            }
        }
    }

    var hero: some View {
        VStack(spacing: DesignBook.Spacing.lg) {
            heroIcon
                .padding(.top, DesignBook.Spacing.lg)

            VStack(spacing: DesignBook.Spacing.xs) {
                Text("home.title")
                    .font(DesignBook.Font.largeTitle)
                    .foregroundStyle(DesignBook.Color.Text.primary)
                    .multilineTextAlignment(.center)

                Text("home.subtitle")
                    .font(DesignBook.Font.body)
                    .foregroundStyle(DesignBook.Color.Text.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignBook.Spacing.lg)
            }
        }
    }

    var heroIcon: some View {
        ZStack {
            // Soft glow halo behind the hat.
            Circle()
                .fill(DesignBook.Gradient.primary)
                .frame(width: 156, height: 156)
                .blur(radius: 36)
                .opacity(0.55)

            // Inner glass disc.
            Circle()
                .fill(DesignBook.Color.Background.card)
                .frame(width: 136, height: 136)
                .overlay {
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    DesignBook.Color.Text.accent.opacity(0.4),
                                    DesignBook.Color.Text.accent.opacity(0.0),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                }
                .shadow(.large)

            Text("🎩")
                .font(.system(size: 88))
                .offset(y: reduceMotion ? 0 : (isHeroFloating ? -6 : 6))
                .accessibilityHidden(true)
        }
    }

    var howToPlayCard: some View {
        FoldableCard(
            isExpanded: $isHowToPlayExpanded,
            title: String(localized: "home.howToPlay.title"),
            icon: "sparkles"
        ) {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                ForEach(Array(instructions.enumerated()), id: \.offset) { index, instruction in
                    InstructionRow(
                        index: index + 1,
                        icon: instruction.icon,
                        text: instruction.text
                    )
                }
            }
        }
        .paddingHorizontalDefault()
    }

    var actionButtons: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            PrimaryButton(title: String(localized: "home.localGame"), icon: "person.2.fill") {
                DesignBook.Haptics.tap()
                navigator.present(.teamSetup)
            }

            if appConfiguration.isTestMode {
                SecondaryButton(title: String(localized: "home.onlineGame"), icon: "wifi") {
                    DesignBook.Haptics.tap()
                    navigator.present(.onlineFlow)
                }
            }

            SecondaryButton(title: String(localized: "common.buttons.settings"), icon: "gearshape") {
                DesignBook.Haptics.selection()
                navigator.push(.settings)
            }
        }
        .paddingHorizontalDefault()
        .padding(.bottom, DesignBook.Spacing.sm)
    }

    var instructions: [(icon: String, text: String)] {
        [
            (icon: "person.2.fill", text: String(localized: "home.instructions.createTeams")),
            (icon: "text.bubble.fill", text: String(localized: "home.instructions.addWords")),
            (icon: "shuffle.circle.fill", text: String(localized: "home.instructions.randomize")),
            (icon: "1.circle.fill", text: String(localized: "home.instructions.round1")),
            (icon: "2.circle.fill", text: String(localized: "home.instructions.round2")),
            (icon: "3.circle.fill", text: String(localized: "home.instructions.round3")),
            (icon: "trophy.fill", text: String(localized: "home.instructions.winner")),
        ]
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        HomeView()
    }
    .environment(Navigator())
}

//
//  HomeView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct HomeView: View {
    @Environment(Navigator.self) private var navigator
    @SceneStorage("HomeView.isHowToPlayExpanded") private var isHowToPlayExpanded: Bool = true

    var body: some View {
        content
            .setDefaultBackground()
    }
}

private extension HomeView {
    var content: some View {
        ScrollView {
            VStack(spacing: DesignBook.Spacing.xl) {
                header
                howToPlayCard
                Spacer()
                    .frame(height: DesignBook.Spacing.xl)
            }
        }
        .safeAreaInset(edge: .bottom) {
            actionButtons
        }
    }

    var header: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            Text("🎩")
                .font(.system(size: 80))
                .padding(.top, DesignBook.Spacing.md)

            Text("Hat Game")
                .font(DesignBook.Font.largeTitle)
                .foregroundColor(DesignBook.Color.Text.primary)
        }
    }

    var howToPlayCard: some View {
        FoldableCard(
            isExpanded: $isHowToPlayExpanded,
            title: "How to Play",
            icon: "questionmark.circle"
        ) {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                ForEach(Array(instructions.enumerated()), id: \.offset) { _, instruction in
                    InstructionRow(icon: instruction.icon, text: instruction.text)
                }
            }
        }
        .paddingHorizontalDefault()
    }

    var actionButtons: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            PrimaryButton(title: "Start Game", icon: "play.fill") {
                navigator.present(.teamSetup)
            }

            SecondaryButton(title: "Settings", icon: "gearshape") {
                navigator.push(.settings)
            }
        }
        .paddingHorizontalDefault()
    }

    var instructions: [(icon: String, text: String)] {
        [
            (icon: "person.2", text: "Create teams and add players"),
            (icon: "text.bubble", text: "Each player adds words to the hat"),
            (icon: "shuffle", text: "Words are randomized"),
            (icon: "1.circle", text: "Round 1: No restrictions - guess as many as you can"),
            (icon: "2.circle", text: "Round 2: One word only to describe"),
            (icon: "3.circle", text: "Round 3: Gestures and miming only"),
            (icon: "trophy", text: "Team with most points wins!")
        ]
    }
}

private struct InstructionRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: DesignBook.Spacing.md) {
            ZStack {
                Circle()
                    .fill(DesignBook.Color.Text.accent.opacity(0.2))
                    .frame(width: 24, height: 24)

                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(DesignBook.Color.Text.accent)
            }

            Text(text)
                .font(DesignBook.Font.body)
                .foregroundColor(DesignBook.Color.Text.secondary)

            Spacer()
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        Page.home.view()
    }
    .environment(GameManager())
}

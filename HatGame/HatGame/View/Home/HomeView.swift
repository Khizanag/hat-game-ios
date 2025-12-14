//
//  HomeView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI
import DesignBook
import Navigation

struct HomeView: View {
    @Environment(Navigator.self) private var navigator
    @SceneStorage("HomeView.isHowToPlayExpanded") private var isHowToPlayExpanded: Bool = true

    var body: some View {
        content
            .setDefaultBackground()
    }
}

// MARK: - Private
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
                .withFooterGradient()
        }
    }

    var header: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            Text("🎩")
                .font(DesignBook.IconFont.emoji)
                .padding(.top, DesignBook.Spacing.md)

            Text("home.title")
                .font(DesignBook.Font.largeTitle)
                .foregroundColor(DesignBook.Color.Text.primary)
        }
    }

    var howToPlayCard: some View {
        FoldableCard(
            isExpanded: $isHowToPlayExpanded,
            title: String(localized: "home.howToPlay.title"),
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
            PrimaryButton(title: String(localized: "home.startGame"), icon: "play.fill") {
                navigator.present(.teamSetup)
            }

            SecondaryButton(title: String(localized: "common.buttons.settings"), icon: "gearshape") {
                navigator.push(.settings)
            }
        }
        .paddingHorizontalDefault()
    }

    var instructions: [(icon: String, text: String)] {
        [
            (icon: "person.2", text: String(localized: "home.instructions.createTeams")),
            (icon: "text.bubble", text: String(localized: "home.instructions.addWords")),
            (icon: "shuffle", text: String(localized: "home.instructions.randomize")),
            (icon: "1.circle", text: String(localized: "home.instructions.round1")),
            (icon: "2.circle", text: String(localized: "home.instructions.round2")),
            (icon: "3.circle", text: String(localized: "home.instructions.round3")),
            (icon: "trophy", text: String(localized: "home.instructions.winner"))
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
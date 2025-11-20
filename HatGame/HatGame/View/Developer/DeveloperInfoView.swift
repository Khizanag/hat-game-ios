//
//  DeveloperInfoView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct DeveloperInfoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.lg) {
                header
                aboutSection
                technologiesSection
                contactSection
                Spacer()
            }
            .paddingHorizontalDefault()
            .padding(.vertical, DesignBook.Spacing.lg)
        }
        .setDefaultStyle(title: "Developer Info")
    }
}

private extension DeveloperInfoView {
    var header: some View {
        VStack(alignment: .leading, spacing: DesignBook.Spacing.xs) {
            Text("HatGame")
                .font(DesignBook.Font.largeTitle)
                .foregroundColor(DesignBook.Color.Text.primary)

            Text("Created by Giga Khizanishvili")
                .font(DesignBook.Font.headline)
                .foregroundColor(DesignBook.Color.Text.secondary)
        }
    }

    var aboutSection: some View {
        infoCard(title: "About") {
            Text("HatGame is a modern take on the classic party game. It focuses on fast rounds, simple onboarding, and bright visuals powered by DesignBook.")
                .font(DesignBook.Font.body)
                .foregroundColor(DesignBook.Color.Text.secondary)
        }
    }

    var technologiesSection: some View {
        infoCard(title: "Technologies") {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
                bullet("SwiftUI + Observation")
                bullet("Custom navigation system")
                bullet("DesignBook design tokens")
            }
        }
    }

    var contactSection: some View {
        infoCard(title: "Contact") {
            Text("Feel free to reach out on GitHub: @gigakhizanishvili")
                .font(DesignBook.Font.body)
                .foregroundColor(DesignBook.Color.Text.secondary)
        }
    }

    func infoCard(title: String, @ViewBuilder content: () -> some View) -> some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
                Text(title)
                    .font(DesignBook.Font.headline)
                    .foregroundColor(DesignBook.Color.Text.primary)
                content()
            }
        }
    }

    func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: DesignBook.Spacing.sm) {
            Circle()
                .fill(DesignBook.Color.Text.accent)
                .frame(width: 6, height: 6)
                .padding(.top, 6)
            Text(text)
                .font(DesignBook.Font.body)
                .foregroundColor(DesignBook.Color.Text.secondary)
        }
    }
}

#Preview {
    NavigationView {
        DeveloperInfoView()
    }
    .environment(GameManager())
}

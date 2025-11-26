//
//  SettingsSection.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 26.11.25.
//

import SwiftUI

/// A reusable section component for organizing settings
struct SettingsSection<Content: View>: View {
    let title: String?
    let footer: String?
    let content: () -> Content

    init(
        title: String? = nil,
        footer: String? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.footer = footer
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
            if let title {
                sectionHeader(title)
            }

            VStack(spacing: DesignBook.Spacing.sm) {
                content()
            }

            if let footer {
                sectionFooter(footer)
            }
        }
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(DesignBook.Font.caption)
            .foregroundColor(DesignBook.Color.Text.secondary)
            .textCase(.uppercase)
            .padding(.horizontal, DesignBook.Spacing.sm)
            .padding(.bottom, DesignBook.Spacing.xs)
    }

    private func sectionFooter(_ text: String) -> some View {
        Text(text)
            .font(DesignBook.Font.caption)
            .foregroundColor(DesignBook.Color.Text.tertiary)
            .padding(.horizontal, DesignBook.Spacing.sm)
            .padding(.top, DesignBook.Spacing.xs)
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: DesignBook.Spacing.xl) {
            SettingsSection(
                title: "Appearance",
                footer: "Customize the look and feel of the app"
            ) {
                SettingsRow(
                    icon: "paintbrush",
                    title: "Theme",
                    subtitle: "Light, Dark, or Auto"
                )

                SettingsRow(
                    icon: "app.gift.fill",
                    title: "App Icon",
                    subtitle: "Classic"
                )
            }

            SettingsSection(title: "Game Defaults") {
                SettingsRow(
                    icon: "text.bubble",
                    iconColor: .orange,
                    title: "Words per Player",
                    subtitle: "10 words"
                )

                SettingsRow(
                    icon: "timer",
                    iconColor: .blue,
                    title: "Round Duration",
                    subtitle: "60 seconds"
                )
            }
        }
        .paddingHorizontalDefault()
        .padding(.top, DesignBook.Spacing.lg)
    }
    .setDefaultBackground()
}

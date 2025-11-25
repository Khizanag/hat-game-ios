//
//  DefaultsSettingsView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct DefaultsSettingsView: View {
    private let appConfiguration = AppConfiguration.shared

    var body: some View {
        content
            .setDefaultStyle(title: String(localized: "settings.defaults.title"))
    }
}

// MARK: - Private
private extension DefaultsSettingsView {
    var content: some View {
        ScrollView {
            VStack(spacing: DesignBook.Spacing.lg) {
                headerCard
                defaultsCard
                Spacer()
                    .frame(height: DesignBook.Spacing.xl)
            }
            .paddingHorizontalDefault()
            .padding(.top, DesignBook.Spacing.lg)
        }
    }

    var headerCard: some View {
        HeaderCard(
            title: String(localized: "settings.defaults.title"),
            description: String(localized: "settings.defaults.description")
        )
    }

    var defaultsCard: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                defaultWordsPerPlayerSection

                Divider()
                    .background(DesignBook.Color.Text.tertiary.opacity(0.3))

                defaultRoundDurationSection
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    var defaultWordsPerPlayerSection: some View {
        VStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
            HStack {
                HStack(spacing: DesignBook.Spacing.sm) {
                    Image(systemName: "text.bubble")
                        .font(DesignBook.Font.headline)
                        .foregroundColor(DesignBook.Color.Text.accent)

                    Text("settings.defaultWordsPerPlayer.title")
                        .font(DesignBook.Font.headline)
                        .foregroundColor(DesignBook.Color.Text.primary)
                }

                Spacer()

                Text("\(appConfiguration.defaultWordsPerPlayer)")
                    .font(DesignBook.Font.title3)
                    .foregroundColor(DesignBook.Color.Text.accent)
            }

            Stepper(
                value: Binding(
                    get: { appConfiguration.defaultWordsPerPlayer },
                    set: { appConfiguration.defaultWordsPerPlayer = $0 }
                ),
                in: 3...20
            ) {
                Text("settings.defaultWordsPerPlayer.description")
                    .font(DesignBook.Font.caption)
                    .foregroundColor(DesignBook.Color.Text.secondary)
            }
        }
    }

    var defaultRoundDurationSection: some View {
        VStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
            HStack {
                HStack(spacing: DesignBook.Spacing.sm) {
                    Image(systemName: "timer")
                        .font(DesignBook.Font.headline)
                        .foregroundColor(DesignBook.Color.Text.accent)

                    Text("settings.defaultRoundDuration.title")
                        .font(DesignBook.Font.headline)
                        .foregroundColor(DesignBook.Color.Text.primary)
                }

                Spacer()

                Text("\(appConfiguration.defaultRoundDuration)s")
                    .font(DesignBook.Font.title3)
                    .foregroundColor(DesignBook.Color.Text.accent)
            }

            Stepper(
                value: Binding(
                    get: { appConfiguration.defaultRoundDuration },
                    set: { appConfiguration.defaultRoundDuration = $0 }
                ),
                in: 5...120,
                step: 5
            ) {
                Text("settings.defaultRoundDuration.description")
                    .font(DesignBook.Font.caption)
                    .foregroundColor(DesignBook.Color.Text.secondary)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        Page.defaultsSettings.view()
    }
}


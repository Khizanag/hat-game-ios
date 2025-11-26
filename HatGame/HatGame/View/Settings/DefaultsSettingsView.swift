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
            VStack(spacing: DesignBook.Spacing.xl) {
                descriptionText
                wordsPerPlayerSection
                roundDurationSection
                duplicateWordsSection
            }
            .paddingHorizontalDefault()
            .padding(.top, DesignBook.Spacing.lg)
            .padding(.bottom, DesignBook.Spacing.xxl)
        }
    }

    var descriptionText: some View {
        Text("settings.defaults.description")
            .font(DesignBook.Font.body)
            .foregroundColor(DesignBook.Color.Text.secondary)
            .padding(.horizontal, DesignBook.Spacing.sm)
    }

    // MARK: - Words Per Player
    var wordsPerPlayerSection: some View {
        SettingsSection(
            title: String(localized: "settings.defaultWordsPerPlayer.title"),
            footer: String(localized: "settings.defaultWordsPerPlayer.description")
        ) {
            VStack(spacing: DesignBook.Spacing.md) {
                HStack {
                    Image(systemName: "text.bubble.fill")
                        .font(DesignBook.Font.body)
                        .foregroundColor(.orange)

                    Text("settings.defaultWordsPerPlayer.title")
                        .font(DesignBook.Font.headline)
                        .foregroundColor(DesignBook.Color.Text.primary)

                    Spacer()

                    Text("\(appConfiguration.defaultWordsPerPlayer)")
                        .font(DesignBook.Font.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }

                Stepper(
                    "",
                    value: Binding(
                        get: { appConfiguration.defaultWordsPerPlayer },
                        set: { appConfiguration.defaultWordsPerPlayer = $0 }
                    ),
                    in: 3...20
                )
                .labelsHidden()
            }
            .padding(DesignBook.Spacing.md)
            .background(DesignBook.Color.Background.card)
            .cornerRadius(DesignBook.Size.cardCornerRadius)
        }
    }

    // MARK: - Round Duration
    var roundDurationSection: some View {
        SettingsSection(
            title: String(localized: "settings.defaultRoundDuration.title"),
            footer: String(localized: "settings.defaultRoundDuration.description")
        ) {
            VStack(spacing: DesignBook.Spacing.md) {
                HStack {
                    Image(systemName: "timer.circle.fill")
                        .font(DesignBook.Font.body)
                        .foregroundColor(.blue)

                    Text("settings.defaultRoundDuration.title")
                        .font(DesignBook.Font.headline)
                        .foregroundColor(DesignBook.Color.Text.primary)

                    Spacer()

                    Text("\(appConfiguration.defaultRoundDuration)s")
                        .font(DesignBook.Font.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }

                Stepper(
                    "",
                    value: Binding(
                        get: { appConfiguration.defaultRoundDuration },
                        set: { appConfiguration.defaultRoundDuration = $0 }
                    ),
                    in: 5...120,
                    step: 5
                )
                .labelsHidden()
            }
            .padding(DesignBook.Spacing.md)
            .background(DesignBook.Color.Background.card)
            .cornerRadius(DesignBook.Size.cardCornerRadius)
        }
    }

    // MARK: - Duplicate Words
    var duplicateWordsSection: some View {
        SettingsSection(
            title: String(localized: "settings.allowDuplicateWords.title"),
            footer: String(localized: "settings.allowDuplicateWords.description")
        ) {
            VStack(spacing: DesignBook.Spacing.md) {
                Toggle(isOn: Binding(
                    get: { appConfiguration.allowDuplicateWords },
                    set: { appConfiguration.allowDuplicateWords = $0 }
                )) {
                    HStack(spacing: DesignBook.Spacing.sm) {
                        Image(systemName: "doc.on.doc.fill")
                            .font(DesignBook.Font.body)
                            .foregroundColor(.purple)

                        Text("settings.allowDuplicateWords.title")
                            .font(DesignBook.Font.headline)
                            .foregroundColor(DesignBook.Color.Text.primary)
                    }
                }
                .tint(.purple)
            }
            .padding(DesignBook.Spacing.md)
            .background(DesignBook.Color.Background.card)
            .cornerRadius(DesignBook.Size.cardCornerRadius)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        Page.defaultsSettings.view()
    }
}

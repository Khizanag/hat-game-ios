//
//  DeveloperInfoView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct DeveloperInfoView: View {
    private let appConfiguration = AppConfiguration.shared

    var body: some View {
        ScrollView {
            VStack(spacing: DesignBook.Spacing.lg) {
                headerCard
                technologiesSection
                testModeSection
                contactSection
                aboutSection
                Spacer()
                    .frame(height: DesignBook.Spacing.xl)
            }
            .paddingHorizontalDefault()
            .padding(.top, DesignBook.Spacing.lg)
        }
        .setDefaultStyle(title: String(localized: "settings.developerInfo.title"))
    }
}

// MARK: - Private
private extension DeveloperInfoView {
    var headerCard: some View {
        HeaderCard(
            title: String(localized: "settings.developerInfo.title"),
            description: String(localized: "settings.developerInfo.createdBy")
        )
    }

    var aboutSection: some View {
        infoCard(title: "settings.developerInfo.about.title") {
            Text("settings.developerInfo.about.description")
                .font(DesignBook.Font.body)
                .foregroundColor(DesignBook.Color.Text.secondary)
        }
    }

    var technologiesSection: some View {
        infoCard(title: "settings.developerInfo.technologies.title") {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
                bullet("settings.technologies.swiftui")
                bullet("settings.technologies.navigation")
                bullet("settings.technologies.designbook")
            }
        }
    }

    var testModeSection: some View {
        infoCard(title: "settings.testMode.title") {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                Toggle(
                    isOn: Binding(
                        get: { appConfiguration.isTestMode },
                        set: { appConfiguration.isTestMode = $0 }
                    )
                ) {
                    Text("settings.testMode.description")
                        .font(DesignBook.Font.body)
                        .foregroundColor(DesignBook.Color.Text.secondary)
                }
                .toggleStyle(SwitchToggleStyle(tint: DesignBook.Color.Text.accent))
            }
        }
    }

    var contactSection: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                HStack(spacing: DesignBook.Spacing.sm) {
                    Image(systemName: "envelope")
                        .font(DesignBook.Font.headline)
                        .foregroundColor(DesignBook.Color.Text.accent)

                    Text("settings.developerInfo.contact.title")
                        .font(DesignBook.Font.headline)
                        .foregroundColor(DesignBook.Color.Text.primary)
                }

                Text("settings.developerInfo.contact.message")
                    .font(DesignBook.Font.body)
                    .foregroundColor(DesignBook.Color.Text.secondary)

                Link(destination: URL(string: "https://github.com/gigakhizanishvili")!) {
                    HStack(spacing: DesignBook.Spacing.sm) {
                        Image(systemName: "link")
                            .font(DesignBook.Font.body)
                            .foregroundColor(DesignBook.Color.Text.accent)

                        Text("GitHub: @gigakhizanishvili")
                            .font(DesignBook.Font.body)
                            .foregroundColor(DesignBook.Color.Text.accent)
                    }
                }
            }
        }
    }

    func infoCard(title: String, @ViewBuilder content: () -> some View) -> some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
                Text(LocalizedStringKey(title))
                    .font(DesignBook.Font.headline)
                    .foregroundColor(DesignBook.Color.Text.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)

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

            Text(LocalizedStringKey(text))
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

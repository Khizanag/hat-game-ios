//
//  DeveloperInfoView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI
import DesignBook

struct DeveloperInfoView: View {
    private let appConfiguration = AppConfiguration.shared

    var body: some View {
        ScrollView {
            VStack(spacing: DesignBook.Spacing.xl) {
                headerText
                aboutSection
                technologiesSection
                creditsSection
                testModeSection
                contactSection
            }
            .paddingHorizontalDefault()
            .padding(.top, DesignBook.Spacing.lg)
            .padding(.bottom, DesignBook.Spacing.xxl)
        }
        .setDefaultStyle(title: String(localized: "settings.developerInfo.title"))
    }
}

// MARK: - Private
private extension DeveloperInfoView {
    var headerText: some View {
        Text("settings.developerInfo.createdBy")
            .font(DesignBook.Font.body)
            .foregroundColor(DesignBook.Color.Text.secondary)
            .padding(.horizontal, DesignBook.Spacing.sm)
    }

    // MARK: - Credits Section
    var creditsSection: some View {
        SettingsSection(
            title: String(localized: "settings.developerInfo.credits.title")
        ) {
            VStack(spacing: DesignBook.Spacing.md) {
                HStack(spacing: DesignBook.Spacing.sm) {
                    Image(systemName: "star.circle.fill")
                        .font(DesignBook.Font.body)
                        .foregroundColor(.yellow)

                    Text("settings.developerInfo.credits.title")
                        .font(DesignBook.Font.headline)
                        .foregroundColor(DesignBook.Color.Text.primary)

                    Spacer()
                }

                HStack(alignment: .center, spacing: DesignBook.Spacing.sm) {
                    Image(systemName: "person.fill")
                        .font(DesignBook.Font.body)
                        .foregroundColor(.yellow)

                    VStack(alignment: .leading, spacing: DesignBook.Spacing.xs) {
                        Text("home.director.name")
                            .font(DesignBook.Font.body)
                            .foregroundColor(DesignBook.Color.Text.primary)

                        HStack(spacing: DesignBook.Spacing.xs) {
                            Image(systemName: "sparkles")
                                .font(DesignBook.Font.caption)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.yellow, .orange],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )

                            Text("settings.developerInfo.credits.rulesExplainer")
                                .font(DesignBook.Font.caption)
                                .italic()
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.yellow, .orange],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        }
                    }

                    Spacer()
                }
            }
            .padding(DesignBook.Spacing.md)
            .background(DesignBook.Color.Background.card)
            .cornerRadius(DesignBook.Size.cardCornerRadius)
        }
    }

    // MARK: - About Section
    var aboutSection: some View {
        SettingsSection(
            title: String(localized: "settings.developerInfo.about.title")
        ) {
            VStack(spacing: DesignBook.Spacing.md) {
                HStack(spacing: DesignBook.Spacing.sm) {
                    Image(systemName: "person.circle.fill")
                        .font(DesignBook.Font.body)
                        .foregroundColor(.purple)

                    Text("settings.developerInfo.about.title")
                        .font(DesignBook.Font.headline)
                        .foregroundColor(DesignBook.Color.Text.primary)

                    Spacer()
                }

                Text("settings.developerInfo.about.description")
                    .font(DesignBook.Font.body)
                    .foregroundColor(DesignBook.Color.Text.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(DesignBook.Spacing.md)
            .background(DesignBook.Color.Background.card)
            .cornerRadius(DesignBook.Size.cardCornerRadius)
        }
    }

    // MARK: - Technologies Section
    var technologiesSection: some View {
        SettingsSection(
            title: String(localized: "settings.developerInfo.technologies.title")
        ) {
            VStack(spacing: DesignBook.Spacing.md) {
                HStack(spacing: DesignBook.Spacing.sm) {
                    Image(systemName: "hammer.circle.fill")
                        .font(DesignBook.Font.body)
                        .foregroundColor(.blue)

                    Text("settings.developerInfo.technologies.title")
                        .font(DesignBook.Font.headline)
                        .foregroundColor(DesignBook.Color.Text.primary)

                    Spacer()
                }

                VStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
                    techBullet("settings.technologies.swiftui")
                    techBullet("settings.technologies.navigation")
                    techBullet("settings.technologies.designbook")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(DesignBook.Spacing.md)
            .background(DesignBook.Color.Background.card)
            .cornerRadius(DesignBook.Size.cardCornerRadius)
        }
    }

    func techBullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: DesignBook.Spacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .font(DesignBook.Font.caption)
                .foregroundColor(.blue)
                .padding(.top, 2)

            Text(LocalizedStringKey(text))
                .font(DesignBook.Font.body)
                .foregroundColor(DesignBook.Color.Text.secondary)
        }
    }

    // MARK: - Test Mode Section
    var testModeSection: some View {
        SettingsSection(
            title: String(localized: "settings.testMode.title"),
            footer: String(localized: "settings.testMode.description")
        ) {
            VStack(spacing: DesignBook.Spacing.md) {
                Toggle(isOn: Binding(
                    get: { appConfiguration.isTestMode },
                    set: { appConfiguration.isTestMode = $0 }
                )) {
                    HStack(spacing: DesignBook.Spacing.sm) {
                        Image(systemName: appConfiguration.isTestMode ? "testtube.2.fill" : "testtube.2")
                            .font(DesignBook.Font.body)
                            .foregroundColor(.orange)
                            .contentTransition(.symbolEffect(.replace))

                        Text("settings.testMode.title")
                            .font(DesignBook.Font.headline)
                            .foregroundColor(DesignBook.Color.Text.primary)
                    }
                }
                .tint(.orange)
            }
            .padding(DesignBook.Spacing.md)
            .background(DesignBook.Color.Background.card)
            .cornerRadius(DesignBook.Size.cardCornerRadius)
        }
    }

    // MARK: - Contact Section
    var contactSection: some View {
        SettingsSection(
            title: String(localized: "settings.developerInfo.contact.title")
        ) {
            VStack(spacing: DesignBook.Spacing.md) {
                HStack(spacing: DesignBook.Spacing.sm) {
                    Image(systemName: "envelope.circle.fill")
                        .font(DesignBook.Font.body)
                        .foregroundColor(.green)

                    Text("settings.developerInfo.contact.title")
                        .font(DesignBook.Font.headline)
                        .foregroundColor(DesignBook.Color.Text.primary)

                    Spacer()
                }

                VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                    Text("settings.developerInfo.contact.message")
                        .font(DesignBook.Font.body)
                        .foregroundColor(DesignBook.Color.Text.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Link(destination: URL(string: "https://github.com/gigakhizanishvili")!) {
                        HStack(spacing: DesignBook.Spacing.sm) {
                            Image(systemName: "link.circle.fill")
                                .font(DesignBook.Font.body)
                                .foregroundColor(.green)

                            Text("GitHub: @gigakhizanishvili")
                                .font(DesignBook.Font.body)
                                .foregroundColor(.green)

                            Spacer()

                            Image(systemName: "arrow.up.right")
                                .font(DesignBook.Font.caption)
                                .foregroundColor(.green)
                        }
                        .padding(DesignBook.Spacing.sm)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(DesignBook.Size.smallCardCornerRadius)
                    }
                }
            }
            .padding(DesignBook.Spacing.md)
            .background(DesignBook.Color.Background.card)
            .cornerRadius(DesignBook.Size.cardCornerRadius)
        }
    }
}

#Preview {
    NavigationView {
        DeveloperInfoView()
    }
    .environment(GameManager())
}

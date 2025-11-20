//
//  SettingsView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct SettingsView: View {
    private let appConfiguration = AppConfiguration.shared

    @SceneStorage("SettingsView.isTestModeExpanded") private var isTestModeExpanded = false
    @SceneStorage("SettingsView.isDefaultsExpanded") private var isDefaultsExpanded = true
    @SceneStorage("SettingsView.isAboutExpanded") private var isAboutExpanded = true
    @SceneStorage("SettingsView.isDeveloperInfoExpanded") private var isDeveloperInfoExpanded = true
    @SceneStorage("SettingsView.isHandednessExpanded") private var isHandednessExpanded = false
    @SceneStorage("SettingsView.isAppearanceExpanded") private var isAppearanceExpanded = true

    var body: some View {
        content
            .setDefaultStyle(title: "Settings")
    }
}

private extension SettingsView {
    var content: some View {
        ScrollView {
            VStack(spacing: DesignBook.Spacing.xl) {
                appearanceCard
                defaultsCard
                handednessCard
                aboutCard
                developerInfoCard
                testModeCard
                Spacer()
                    .frame(height: DesignBook.Spacing.xl)
            }
            .paddingHorizontalDefault()
            .padding(.top, DesignBook.Spacing.lg)
        }
    }

    var appearanceCard: some View {
        FoldableCard(
            isExpanded: $isAppearanceExpanded,
            title: "settings.appearance.title",
            icon: "paintbrush"
        ) {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                Text("settings.appearance.description")
                    .font(DesignBook.Font.body)
                    .foregroundColor(DesignBook.Color.Text.secondary)

                colorSchemeSelector
            }
        }
    }

    var colorSchemeSelector: some View {
        SegmentedSelectionView(
            items: colorSchemeItems,
            selection: Binding(
                get: { appConfiguration.colorScheme },
                set: { appConfiguration.colorScheme = $0 }
            )
        )
    }

    var colorSchemeItems: [SegmentedSelectionItem<AppColorScheme>] {
        [
            SegmentedSelectionItem(
                id: .light,
                title: "settings.appearance.light",
                subtitle: nil,
                icon: Image(systemName: "sun.max.fill")
            ),
            SegmentedSelectionItem(
                id: .dark,
                title: "settings.appearance.dark",
                subtitle: nil,
                icon: Image(systemName: "moon.fill")
            ),
            SegmentedSelectionItem(
                id: .system,
                title: "settings.appearance.system",
                subtitle: "settings.appearance.auto",
                icon: Image(systemName: "circle.lefthalf.filled")
            )
        ]
    }

    var testModeCard: some View {
        FoldableCard(
            isExpanded: $isTestModeExpanded,
            title: "settings.testMode.title",
            icon: "flask",
            titleFont: DesignBook.Font.headline
        ) {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
                Toggle(
                    isOn: Binding(
                        get: { appConfiguration.isTestMode },
                        set: { handleTestModeChange($0) }
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

    var defaultsCard: some View {
        FoldableCard(
            isExpanded: $isDefaultsExpanded,
            title: "settings.defaults.title",
            icon: "slider.horizontal.3"
        ) {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                Text("settings.defaults.description")
                    .font(DesignBook.Font.body)
                    .foregroundColor(DesignBook.Color.Text.secondary)

                defaultWordsPerPlayerSection

                Divider()
                    .background(DesignBook.Color.Text.tertiary.opacity(0.3))

                defaultRoundDurationSection
            }
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

    var handednessCard: some View {
        FoldableCard(
            isExpanded: $isHandednessExpanded,
            title: "settings.handedness.title",
            icon: "hand.raised"
        ) {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
                Text("settings.handedness.description")
                    .font(DesignBook.Font.body)
                    .foregroundColor(DesignBook.Color.Text.secondary)

                Picker("settings.handedness.title", selection: Binding(
                    get: { appConfiguration.isRightHanded ? "right" : "left" },
                    set: { appConfiguration.isRightHanded = $0 == "right" }
                )) {
                    Text("settings.handedness.left").tag("left")
                    Text("settings.handedness.right").tag("right")
                }
                .pickerStyle(.segmented)
            }
        }
    }

    var aboutCard: some View {
        FoldableCard(
            isExpanded: $isAboutExpanded,
            title: "settings.about.title",
            icon: "info.circle"
        ) {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                appInfoSection

                Divider()
                    .background(DesignBook.Color.Text.tertiary.opacity(0.3))

                versionSection
            }
        }
    }

    var appInfoSection: some View {
        VStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
            Text("settings.about.appName")
                .font(DesignBook.Font.title3)
                .foregroundColor(DesignBook.Color.Text.primary)

            Text("settings.about.description")
                .font(DesignBook.Font.body)
                .foregroundColor(DesignBook.Color.Text.secondary)
        }
    }

    var versionSection: some View {
        VStack(alignment: .leading, spacing: DesignBook.Spacing.xs) {
            if let version = appVersion {
                HStack {
                    HStack(spacing: DesignBook.Spacing.sm) {
                        Image(systemName: "number")
                            .font(DesignBook.Font.body)
                            .foregroundColor(DesignBook.Color.Text.tertiary)

                        Text("settings.about.version")
                            .font(DesignBook.Font.body)
                            .foregroundColor(DesignBook.Color.Text.secondary)
                    }

                    Spacer()

                    Text(version)
                        .font(DesignBook.Font.body)
                        .foregroundColor(DesignBook.Color.Text.primary)
                }
            }

            if let build = appBuild {
                HStack {
                    HStack(spacing: DesignBook.Spacing.sm) {
                        Image(systemName: "wrench.and.screwdriver")
                            .font(DesignBook.Font.body)
                            .foregroundColor(DesignBook.Color.Text.tertiary)

                        Text("settings.about.build")
                            .font(DesignBook.Font.body)
                            .foregroundColor(DesignBook.Color.Text.secondary)
                    }

                    Spacer()

                    Text(build)
                        .font(DesignBook.Font.body)
                        .foregroundColor(DesignBook.Color.Text.primary)
                }
            }
        }
    }

    var appVersion: String? {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }

    var appBuild: String? {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    }

    var developerInfoCard: some View {
        FoldableCard(
            isExpanded: $isDeveloperInfoExpanded,
            title: "settings.developerInfo.title",
            icon: "person.circle"
        ) {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                developerHeader

                Divider()
                    .background(DesignBook.Color.Text.tertiary.opacity(0.3))

                developerAboutSection

                Divider()
                    .background(DesignBook.Color.Text.tertiary.opacity(0.3))

                technologiesSection

                Divider()
                    .background(DesignBook.Color.Text.tertiary.opacity(0.3))

                contactSection
            }
        }
    }

    var developerHeader: some View {
        VStack(alignment: .leading, spacing: DesignBook.Spacing.xs) {
            Text("settings.developerInfo.appName")
                .font(DesignBook.Font.title2)
                .foregroundColor(DesignBook.Color.Text.primary)

            Text("settings.developerInfo.createdBy")
                .font(DesignBook.Font.headline)
                .foregroundColor(DesignBook.Color.Text.secondary)
        }
    }

    var developerAboutSection: some View {
        VStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
            Text("settings.developerInfo.about.title")
                .font(DesignBook.Font.headline)
                .foregroundColor(DesignBook.Color.Text.primary)

            Text("settings.developerInfo.about.description")
                .font(DesignBook.Font.body)
                .foregroundColor(DesignBook.Color.Text.secondary)
        }
    }

    var technologiesSection: some View {
        VStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
            Text("settings.developerInfo.technologies.title")
                .font(DesignBook.Font.headline)
                .foregroundColor(DesignBook.Color.Text.primary)

            VStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
                bullet("settings.technologies.swiftui")
                bullet("settings.technologies.navigation")
                bullet("settings.technologies.designbook")
            }
        }
    }

    var contactSection: some View {
        VStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
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

    func handleTestModeChange(_ enabled: Bool) {
        appConfiguration.isTestMode = enabled
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        Page.settings.view()
    }
}

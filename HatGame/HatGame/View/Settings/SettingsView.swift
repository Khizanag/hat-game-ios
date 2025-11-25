//
//  SettingsView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct SettingsView: View {
    private let appConfiguration = AppConfiguration.shared
    @Environment(Navigator.self) private var navigator

    @SceneStorage("SettingsView.isAboutExpanded") private var isAboutExpanded = true
    @SceneStorage("SettingsView.isHandednessExpanded") private var isHandednessExpanded = false
    @SceneStorage("SettingsView.isAppearanceExpanded") private var isAppearanceExpanded = true

    var body: some View {
        content
            .setDefaultStyle(title: String(localized: "settings.title"))
    }
}

// MARK: - Private
private extension SettingsView {
    var content: some View {
        ScrollView {
            VStack(spacing: DesignBook.Spacing.xl) {
                appearanceCard
                appIconCard
                defaultsCard
                handednessCard
                developerInfoCard
                aboutCard
            }
            .paddingHorizontalDefault()
            .padding(.top, DesignBook.Spacing.lg)
        }
    }

    var appearanceCard: some View {
        FoldableCard(
            isExpanded: $isAppearanceExpanded,
            title: String(localized: "settings.appearance.title"),
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

    var appIconCard: some View {
        NavigationCard(
            icon: "app.gift.fill",
            title: String(localized: "settings.appIcon.title"),
            description: String(localized: "settings.appIcon.description")
        ) {
            navigator.push(.appIconSelection)
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
                title: String(localized: "settings.appearance.light"),
                subtitle: nil,
                icon: Image(systemName: "sun.max.fill")
            ),
            SegmentedSelectionItem(
                id: .dark,
                title: String(localized: "settings.appearance.dark"),
                subtitle: nil,
                icon: Image(systemName: "moon.fill")
            ),
            SegmentedSelectionItem(
                id: .system,
                title: String(localized: "settings.appearance.system"),
                subtitle: "settings.appearance.auto",
                icon: Image(systemName: "circle.lefthalf.filled")
            )
        ]
    }


    var defaultsCard: some View {
        NavigationCard(
            icon: "slider.horizontal.3",
            title: String(localized: "settings.defaults.title"),
            description: String(localized: "settings.defaults.description")
        ) {
            navigator.push(.defaultsSettings)
        }
    }

    var handednessCard: some View {
        FoldableCard(
            isExpanded: $isHandednessExpanded,
            title: String(localized: "settings.handedness.title"),
            icon: "hand.raised"
        ) {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                Text("settings.handedness.description")
                    .font(DesignBook.Font.body)
                    .foregroundColor(DesignBook.Color.Text.secondary)

                Picker(
                    "settings.handedness.title",
                    selection: Binding(
                        get: { appConfiguration.isRightHanded ? "right" : "left" },
                        set: { appConfiguration.isRightHanded = ($0 == "right") }
                    )
                ) {
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
            title: String(localized: "settings.about.title"),
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
        VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
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
                infoRow(
                    icon: "number",
                    label: String(localized: "settings.about.version"),
                    value: version
                )
            }

            if let build = appBuild {
                infoRow(
                    icon: "wrench.and.screwdriver",
                    label: String(localized: "settings.about.build"),
                    value: build
                )
            }
        }
    }

    func infoRow(icon: String, label: String, value: String) -> some View {
        HStack {
            HStack(spacing: DesignBook.Spacing.sm) {
                Image(systemName: icon)
                    .font(DesignBook.Font.body)
                    .foregroundColor(DesignBook.Color.Text.tertiary)

                Text(label)
                    .font(DesignBook.Font.body)
                    .foregroundColor(DesignBook.Color.Text.secondary)
            }

            Spacer()

            Text(value)
                .font(DesignBook.Font.body)
                .foregroundColor(DesignBook.Color.Text.primary)
        }
    }

    var appVersion: String? {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }

    var appBuild: String? {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    }

    var developerInfoCard: some View {
        NavigationCard(
            icon: "person.circle.fill",
            title: String(localized: "settings.developerInfo.title"),
            description: String(localized: "settings.developerInfo.description")
        ) {
            navigator.push(.developerInfo)
        }
    }

}

// MARK: - Preview
#Preview {
    NavigationView {
        Page.settings.view()
    }
}

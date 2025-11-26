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
                appearanceSection
                gameDefaultsSection
                accessibilitySection
                aboutSection
            }
            .paddingHorizontalDefault()
            .padding(.top, DesignBook.Spacing.lg)
            .padding(.bottom, DesignBook.Spacing.xxl)
        }
    }

    // MARK: - Appearance Section
    var appearanceSection: some View {
        SettingsSection(
            title: String(localized: "settings.appearance.title"),
            footer: String(localized: "settings.appearance.description")
        ) {
            VStack(spacing: DesignBook.Spacing.md) {
                colorSchemeCard
                appIconRow
            }
        }
    }

    var colorSchemeCard: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            HStack {
                Image(systemName: "paintbrush.fill")
                    .font(DesignBook.Font.body)
                    .foregroundColor(DesignBook.Color.Text.accent)

                Text("settings.appearance.colorScheme")
                    .font(DesignBook.Font.headline)
                    .foregroundColor(DesignBook.Color.Text.primary)

                Spacer()
            }

            SegmentedSelectionView(
                items: colorSchemeItems,
                selection: Binding(
                    get: { appConfiguration.colorScheme },
                    set: { appConfiguration.colorScheme = $0 }
                )
            )
        }
        .padding(DesignBook.Spacing.md)
        .background(DesignBook.Color.Background.card)
        .cornerRadius(DesignBook.Size.cardCornerRadius)
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

    var appIconRow: some View {
        Button {
            navigator.push(.appIconSelection)
        } label: {
            SettingsRow(
                icon: "app.gift.fill",
                title: String(localized: "settings.appIcon.title"),
                subtitle: appConfiguration.appIcon.title
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Game Defaults Section
    var gameDefaultsSection: some View {
        SettingsSection(
            title: String(localized: "settings.defaults.sectionTitle"),
            footer: String(localized: "settings.defaults.description")
        ) {
            Button {
                navigator.push(.defaultsSettings)
            } label: {
                SettingsRow(
                    icon: "slider.horizontal.3",
                    iconColor: .orange,
                    title: String(localized: "settings.defaults.title"),
                    subtitle: defaultsSummary
                )
            }
            .buttonStyle(.plain)
        }
    }

    var defaultsSummary: String {
        String(
            format: "%d words • %d seconds",
            appConfiguration.defaultWordsPerPlayer,
            appConfiguration.defaultRoundDuration
        )
    }

    // MARK: - Accessibility Section
    var accessibilitySection: some View {
        SettingsSection(
            title: String(localized: "settings.accessibility.title"),
            footer: String(localized: "settings.handedness.description")
        ) {
            handednessCard
        }
    }

    var handednessCard: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            HStack {
                Image(systemName: "hand.raised.fill")
                    .font(DesignBook.Font.body)
                    .foregroundColor(DesignBook.Color.Text.accent)

                Text("settings.handedness.title")
                    .font(DesignBook.Font.headline)
                    .foregroundColor(DesignBook.Color.Text.primary)

                Spacer()
            }

            SegmentedSelectionView(
                items: handednessItems,
                selection: Binding(
                    get: { appConfiguration.isRightHanded ? .right : .left },
                    set: { appConfiguration.isRightHanded = ($0 == .right) }
                )
            )
        }
        .padding(DesignBook.Spacing.md)
        .background(DesignBook.Color.Background.card)
        .cornerRadius(DesignBook.Size.cardCornerRadius)
    }

    var handednessItems: [SegmentedSelectionItem<Handedness>] {
        [
            SegmentedSelectionItem(
                id: .left,
                title: String(localized: "settings.handedness.left"),
                subtitle: nil,
                icon: Image(systemName: "hand.point.left.fill")
            ),
            SegmentedSelectionItem(
                id: .right,
                title: String(localized: "settings.handedness.right"),
                subtitle: nil,
                icon: Image(systemName: "hand.point.right.fill")
            )
        ]
    }

    // MARK: - About Section
    var aboutSection: some View {
        SettingsSection(title: String(localized: "settings.about.sectionTitle")) {
            VStack(spacing: DesignBook.Spacing.sm) {
                Button {
                    navigator.push(.developerInfo)
                } label: {
                    SettingsRow(
                        icon: "person.circle.fill",
                        iconColor: .purple,
                        title: String(localized: "settings.developerInfo.title"),
                        subtitle: String(localized: "settings.developerInfo.description")
                    )
                }
                .buttonStyle(.plain)

                appInfoRow
            }
        }
    }

    var appInfoRow: some View {
        VStack(spacing: DesignBook.Spacing.sm) {
            if let version = appVersion {
                SettingsRow(
                    icon: "number",
                    iconColor: .blue,
                    title: String(localized: "settings.about.version"),
                    subtitle: version,
                    showChevron: false
                ) {
                    EmptyView()
                }
            }

            if let build = appBuild {
                SettingsRow(
                    icon: "wrench.and.screwdriver",
                    iconColor: .green,
                    title: String(localized: "settings.about.build"),
                    subtitle: build,
                    showChevron: false
                ) {
                    EmptyView()
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
}

// MARK: - Preview
#Preview {
    NavigationView {
        Page.settings.view()
    }
}

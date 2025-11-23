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
        .setDefaultStyle(title: String(localized: "settings.developerInfo.title"))
    }
}

// MARK: - Private
private extension DeveloperInfoView {
    var header: some View {
        VStack(alignment: .leading, spacing: DesignBook.Spacing.xs) {
            Text("settings.developerInfo.appName")
                .font(DesignBook.Font.largeTitle)
                .foregroundColor(DesignBook.Color.Text.primary)

            Text("settings.developerInfo.createdBy")
                .font(DesignBook.Font.headline)
                .foregroundColor(DesignBook.Color.Text.secondary)
        }
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

    var contactSection: some View {
        GameCard {
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
    }

    func infoCard(title: String, @ViewBuilder content: () -> some View) -> some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
                Text(LocalizedStringKey(title))
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
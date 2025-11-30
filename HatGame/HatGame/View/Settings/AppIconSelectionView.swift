//
//  AppIconSelectionView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 20.11.25.
//

import SwiftUI
import DesignBook
import Navigation

struct AppIconSelectionView: View {
    @Environment(Navigator.self) private var navigator
    private let appConfiguration = AppConfiguration.shared

    var body: some View {
        content
            .setDefaultStyle(title: String(localized: "settings.appIcon.title"))
    }
}

// MARK: - Private
private extension AppIconSelectionView {
    var content: some View {
        ScrollView {
            VStack(spacing: DesignBook.Spacing.xl) {
                descriptionText
                currentSelectionCard
                iconGrid
            }
            .paddingHorizontalDefault()
            .padding(.top, DesignBook.Spacing.lg)
            .padding(.bottom, DesignBook.Spacing.xxl)
        }
    }

    var descriptionText: some View {
        Text("settings.appIcon.description")
            .font(DesignBook.Font.body)
            .foregroundColor(DesignBook.Color.Text.secondary)
            .padding(.horizontal, DesignBook.Spacing.sm)
    }

    var currentSelectionCard: some View {
        SettingsSection(
            title: String(localized: "settings.appIcon.current"),
            footer: String(localized: "settings.appIcon.current.description")
        ) {
            HStack(spacing: DesignBook.Spacing.md) {
                // Current icon preview
                ZStack {
                    LinearGradient(
                        colors: appConfiguration.appIcon.gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(width: 60, height: 60)
                    .cornerRadius(DesignBook.Size.smallCardCornerRadius)

                    Image(systemName: appConfiguration.appIcon.iconSymbol)
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                }

                VStack(alignment: .leading, spacing: DesignBook.Spacing.xs) {
                    Text(appConfiguration.appIcon.title)
                        .font(DesignBook.Font.headline)
                        .foregroundColor(DesignBook.Color.Text.primary)

                    Text(appConfiguration.appIcon.subtitle)
                        .font(DesignBook.Font.caption)
                        .foregroundColor(DesignBook.Color.Text.secondary)
                }

                Spacer()
            }
            .padding(DesignBook.Spacing.md)
            .background(DesignBook.Color.Background.card)
            .cornerRadius(DesignBook.Size.cardCornerRadius)
        }
    }

    var iconGrid: some View {
        SettingsSection(
            title: String(localized: "settings.appIcon.available")
        ) {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: DesignBook.Spacing.md),
                    GridItem(.flexible(), spacing: DesignBook.Spacing.md)
                ],
                spacing: DesignBook.Spacing.lg
            ) {
                ForEach(AppIcon.allCases) { icon in
                    iconCard(for: icon)
                }
            }
        }
    }

    func iconCard(for icon: AppIcon) -> some View {
        let isSelected = appConfiguration.appIcon == icon

        return Button {
            guard appConfiguration.appIcon != icon else { return }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                appConfiguration.appIcon = icon
            }
        } label: {
            VStack(spacing: DesignBook.Spacing.md) {
                // Icon preview with gradient
                ZStack {
                    // Gradient background
                    LinearGradient(
                        colors: icon.gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(width: 100, height: 100)
                    .cornerRadius(DesignBook.Size.smallCardCornerRadius)
                    .shadow(color: icon.displayColor.opacity(0.3), radius: 8, x: 0, y: 4)

                    // Icon symbol
                    Image(systemName: icon.iconSymbol)
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)

                    // Selection indicator
                    if isSelected {
                        VStack {
                            HStack {
                                Spacer()
                                ZStack {
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 28, height: 28)
                                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)

                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(icon.displayColor)
                                }
                                .offset(x: 8, y: -8)
                            }
                            Spacer()
                        }
                        .frame(width: 100, height: 100)
                    }
                }

                // Title and subtitle
                VStack(spacing: DesignBook.Spacing.xs) {
                    Text(icon.title)
                        .font(DesignBook.Font.headline)
                        .foregroundColor(DesignBook.Color.Text.primary)

                    Text(icon.subtitle)
                        .font(DesignBook.Font.caption)
                        .foregroundColor(DesignBook.Color.Text.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(DesignBook.Spacing.md)
            .frame(maxWidth: .infinity)
            .background(DesignBook.Color.Background.card)
            .cornerRadius(DesignBook.Size.cardCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: DesignBook.Size.cardCornerRadius)
                    .stroke(
                        isSelected ? icon.displayColor : Color.clear,
                        lineWidth: isSelected ? 2 : 0
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        AppIconSelectionView()
    }
    .environment(AppConfiguration.shared)
    .environment(Navigator())
}

//
//  AppIconSelectionView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 20.11.25.
//

import SwiftUI

struct AppIconSelectionView: View {
    @Environment(Navigator.self) private var navigator
    @Environment(\.colorScheme) private var colorScheme
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
                headerCard

                iconGrid

                Spacer()
                    .frame(height: DesignBook.Spacing.xl)
            }
            .paddingHorizontalDefault()
            .padding(.top, DesignBook.Spacing.lg)
        }
    }

    var headerCard: some View {
        HeaderCard(
            title: String(localized: "settings.appIcon.title"),
            description: String(localized: "settings.appIcon.description")
        )
    }

    var iconGrid: some View {
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


    func iconCard(for icon: AppIcon) -> some View {
        let isSelected = appConfiguration.appIcon == icon

        return Button {
            guard appConfiguration.appIcon != icon else { return }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                appConfiguration.appIcon = icon
            }
        } label: {
            VStack(spacing: DesignBook.Spacing.md) {
                iconPreview(for: icon, isSelected: isSelected)

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
            .padding(DesignBook.Spacing.lg)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: DesignBook.Size.cardCornerRadius)
                    .fill(DesignBook.Color.Background.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignBook.Size.cardCornerRadius)
                    .stroke(
                        isSelected ? DesignBook.Color.Text.accent : Color.clear,
                        lineWidth: isSelected ? 3 : 0
                    )
            )
            .shadow(isSelected ? .accent : .small)
            .scaleEffect(isSelected ? 1.0 : 0.98)
        }
        .buttonStyle(.plain)
    }

    func iconPreview(for icon: AppIcon, isSelected: Bool) -> some View {
        let assetName = colorScheme == .dark ? icon.previewNameDark : icon.previewNameLight

        return ZStack {
            RoundedRectangle(cornerRadius: DesignBook.Size.smallCardCornerRadius)
                .fill(DesignBook.Color.Background.secondary)
                .frame(width: 120, height: 120)

            Image(assetName)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: DesignBook.Size.smallCardCornerRadius))
                .shadow(.small)

            if isSelected {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(DesignBook.Color.Background.card)
                                .frame(width: 32, height: 32)
                                .shadow(.small)

                            Image(systemName: "checkmark.circle.fill")
                                .font(DesignBook.IconFont.medium)
                                .foregroundColor(DesignBook.Color.Text.accent)
                        }
                        .padding(DesignBook.Spacing.sm)
                    }
                }
                .frame(width: 120, height: 120)
            }
        }
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
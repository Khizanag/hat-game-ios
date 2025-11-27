//
//  SettingsRow.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 26.11.25.
//

import SwiftUI

/// A reusable row component for settings with consistent styling
struct SettingsRow<Content: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String?
    let showChevron: Bool
    let content: (() -> Content)?

    init(
        icon: String,
        iconColor: Color = DesignBook.Color.Text.accent,
        title: String,
        subtitle: String? = nil,
        showChevron: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.showChevron = showChevron
        self.content = content
    }

    var body: some View {
        HStack(spacing: DesignBook.Spacing.md) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: DesignBook.Size.smallCardCornerRadius)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 32, height: 32)

                Image(systemName: icon)
                    .font(DesignBook.Font.body)
                    .foregroundColor(iconColor)
            }

            // Title and subtitle
            VStack(alignment: .leading, spacing: DesignBook.Spacing.xs) {
                Text(title)
                    .font(DesignBook.Font.body)
                    .foregroundColor(DesignBook.Color.Text.primary)

                if let subtitle {
                    Text(subtitle)
                        .font(DesignBook.Font.caption)
                        .foregroundColor(DesignBook.Color.Text.secondary)
                }
            }

            Spacer()

            content?()

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(DesignBook.Font.caption)
                    .foregroundColor(DesignBook.Color.Text.tertiary)
            }
        }
        .padding(DesignBook.Spacing.md)
        .background(DesignBook.Color.Background.card)
        .cornerRadius(DesignBook.Size.cardCornerRadius)
    }
}

/// Settings row without custom content (navigation only)
extension SettingsRow where Content == EmptyView {
    init(
        icon: String,
        iconColor: Color = DesignBook.Color.Text.accent,
        title: String,
        subtitle: String? = nil,
        showChevron: Bool = true
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.showChevron = showChevron
        self.content = nil
    }
}

// MARK: - Preview
#Preview("Navigation Row") {
    VStack {
        SettingsRow(
            icon: "app.gift.fill",
            title: "App Icon",
            subtitle: "Customize your home screen"
        )

        SettingsRow(
            icon: "slider.horizontal.3",
            iconColor: .orange,
            title: "Defaults",
            subtitle: "Configure default game settings"
        )
    }
    .padding()
    .setDefaultBackground()
}

#Preview("Toggle Row") {
    SettingsRow(
        icon: "doc.on.doc",
        title: "Allow Duplicates",
        subtitle: "Enable duplicate words"
    ) {
        Toggle("", isOn: .constant(false))
            .labelsHidden()
    }
    .padding()
    .setDefaultBackground()
}

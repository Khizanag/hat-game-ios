//
//  NumberBadge.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 26.11.25.
//

import SwiftUI
import DesignBook

struct NumberBadge: View {
    let number: Int
    let size: CGFloat
    let backgroundColor: Color
    let textColor: Color
    let font: Font

    init(
        number: Int,
        size: CGFloat = DesignBook.Size.badgeSize,
        backgroundColor: Color = DesignBook.Color.Text.accent,
        textColor: Color = .white,
        font: Font = DesignBook.Font.captionBold
    ) {
        self.number = number
        self.size = size
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.font = font
    }

    var body: some View {
        Text("\(number)")
            .font(font)
            .foregroundColor(textColor)
            .frame(width: size, height: size)
            .background(backgroundColor)
            .clipShape(Circle())
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: DesignBook.Spacing.lg) {
        // Default style
        NumberBadge(number: 1)

        // Custom size
        NumberBadge(
            number: 42,
            size: DesignBook.Size.mediumIconSize,
            backgroundColor: .green
        )

        // Player number style
        NumberBadge(
            number: 3,
            size: DesignBook.Size.playerNumberBadgeSize,
            backgroundColor: DesignBook.Color.Text.accent.opacity(DesignBook.Opacity.highlight),
            textColor: DesignBook.Color.Text.accent
        )

        // Rank indicator
        NumberBadge(
            number: 5,
            size: DesignBook.Size.dotLarge,
            backgroundColor: DesignBook.Color.Status.success,
            font: DesignBook.Font.caption
        )
    }
    .padding()
}

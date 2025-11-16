//
//  LegendTag.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct LegendTag: View {
    let title: String
    let range: String
    let isHighlighted: Bool
    
    var body: some View {
        VStack(spacing: DesignBook.Spacing.xs) {
            Text(title)
                .font(DesignBook.Font.captionBold)
                .foregroundColor(isHighlighted ? DesignBook.Color.Text.accent : DesignBook.Color.Text.primary)
            Text(range)
                .font(DesignBook.Font.caption)
                .foregroundColor(isHighlighted ? DesignBook.Color.Text.accent : DesignBook.Color.Text.secondary)
        }
        .padding(.vertical, DesignBook.Spacing.sm)
        .padding(.horizontal, DesignBook.Spacing.md)
        .background(isHighlighted ? DesignBook.Color.Text.accent.opacity(DesignBook.Opacity.highlight) : DesignBook.Color.Background.secondary)
        .cornerRadius(DesignBook.Size.smallCardCornerRadius)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview
#Preview {
    HStack(spacing: DesignBook.Spacing.md) {
        LegendTag(title: "Lightning", range: "5-30s", isHighlighted: true)
        LegendTag(title: "Classic", range: "60s", isHighlighted: false)
        LegendTag(title: "Marathon", range: "90-120s", isHighlighted: false)
    }
    .padding()
}


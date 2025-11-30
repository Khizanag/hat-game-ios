//
//  ProgressDotIndicator.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 26.11.25.
//

import SwiftUI
import DesignBook

struct ProgressDotIndicator: View {
    let count: Int
    let currentIndex: Int
    let dotSize: CGFloat
    let spacing: CGFloat
    let completedColor: Color
    let currentColor: Color
    let pendingColor: Color
    let showStroke: Bool

    init(
        count: Int,
        currentIndex: Int,
        dotSize: CGFloat = DesignBook.Size.dotMedium,
        spacing: CGFloat = DesignBook.Spacing.xs,
        completedColor: Color = DesignBook.Color.Status.success,
        currentColor: Color = DesignBook.Color.Text.accent,
        pendingColor: Color = DesignBook.Color.Background.secondary,
        showStroke: Bool = false
    ) {
        self.count = count
        self.currentIndex = currentIndex
        self.dotSize = dotSize
        self.spacing = spacing
        self.completedColor = completedColor
        self.currentColor = currentColor
        self.pendingColor = pendingColor
        self.showStroke = showStroke
    }

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .fill(colorForIndex(index))
                    .frame(width: dotSize, height: dotSize)
                    .overlay {
                        if showStroke, index == currentIndex {
                            Circle()
                                .stroke(currentColor, lineWidth: 2)
                        }
                    }
            }
        }
    }

    private func colorForIndex(_ index: Int) -> Color {
        if index < currentIndex {
            return completedColor
        } else if index == currentIndex {
            return currentColor
        } else {
            return pendingColor
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: DesignBook.Spacing.xl) {
        // Default style
        ProgressDotIndicator(
            count: 5,
            currentIndex: 2
        )

        // With stroke indicator
        ProgressDotIndicator(
            count: 4,
            currentIndex: 1,
            showStroke: true
        )

        // Larger dots
        ProgressDotIndicator(
            count: 6,
            currentIndex: 3,
            dotSize: DesignBook.Size.dotLarge,
            spacing: DesignBook.Spacing.sm
        )

        // Custom colors
        ProgressDotIndicator(
            count: 3,
            currentIndex: 0,
            completedColor: .purple,
            currentColor: .orange,
            pendingColor: .gray.opacity(DesignBook.Opacity.light)
        )
    }
    .padding()
}

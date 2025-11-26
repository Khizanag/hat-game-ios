//
//  DesignBook+Size.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 20.11.25.
//

import SwiftUI

extension DesignBook {
    enum Size {
        // MARK: - Button Sizes
        static let buttonHeight: CGFloat = 56
        static let floatingButtonSize: CGFloat = 56
        static let pauseButtonWidth: CGFloat = 216
        static let touchTargetSize: CGFloat = 44

        // MARK: - Corner Radius
        static let cardCornerRadius: CGFloat = 20
        static let smallCardCornerRadius: CGFloat = 12

        // MARK: - Icon Sizes
        static let iconSize: CGFloat = 24
        static let smallIconSize: CGFloat = 20
        static let mediumIconSize: CGFloat = 32
        static let largeIconSize: CGFloat = 48
        static let extraLargeIconSize: CGFloat = 80

        // MARK: - Badge & Indicator Sizes
        static let badgeSize: CGFloat = 24
        static let colorSwatchSize: CGFloat = 44
        static let playerNumberBadgeSize: CGFloat = 24
        static let selectionIndicatorSize: CGFloat = 24
        static let rankIndicatorWidth: CGFloat = 40

        // MARK: - Dot Indicators
        static let dotSmall: CGFloat = 6
        static let dotMedium: CGFloat = 8
        static let dotLarge: CGFloat = 12

        // MARK: - Card & Circle Sizes
        static let cardSmall: CGFloat = 50
        static let cardMedium: CGFloat = 60
        static let cardLarge: CGFloat = 70
        static let cardXLarge: CGFloat = 80
        static let cardMassive: CGFloat = 100

        // MARK: - Component-Specific Sizes
        static let settingsIconBoxSize: CGFloat = 32
        static let footerGradientHeight: CGFloat = 120
    }
}
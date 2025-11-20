//
//  DesignBook.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

enum DesignBook {
    enum Color {
        enum Background {
            static let primary = SwiftUI.Color(red: 0.05, green: 0.05, blue: 0.1)
            static let secondary = SwiftUI.Color(red: 0.1, green: 0.1, blue: 0.15)
            static let card = SwiftUI.Color(red: 0.15, green: 0.15, blue: 0.2)
        }

        enum Text {
            static let primary = SwiftUI.Color.white
            static let secondary = SwiftUI.Color(red: 0.8, green: 0.8, blue: 0.85)
            static let tertiary = SwiftUI.Color(red: 0.6, green: 0.6, blue: 0.65)
            static let accent = SwiftUI.Color(red: 0.3, green: 0.6, blue: 1.0)
        }

        enum Status {
            static let success = SwiftUI.Color(red: 0.2, green: 0.8, blue: 0.4)
            static let error = SwiftUI.Color(red: 1.0, green: 0.3, blue: 0.3)
            static let warning = SwiftUI.Color(red: 1.0, green: 0.7, blue: 0.2)
        }

        enum Button {
            static let primary = SwiftUI.Color(red: 0.3, green: 0.6, blue: 1.0)
            static let primaryPressed = SwiftUI.Color(red: 0.2, green: 0.5, blue: 0.9)
            static let secondary = SwiftUI.Color(red: 0.2, green: 0.2, blue: 0.25)
            static let secondaryPressed = SwiftUI.Color(red: 0.15, green: 0.15, blue: 0.2)
        }
    }

    enum Font {
        static let title = SwiftUI.Font.system(size: 42, weight: .bold, design: .rounded)
        static let title2 = SwiftUI.Font.system(size: 32, weight: .bold, design: .rounded)
        static let title3 = SwiftUI.Font.system(size: 28, weight: .semibold, design: .rounded)
        static let headline = SwiftUI.Font.system(size: 20, weight: .semibold, design: .rounded)
        static let body = SwiftUI.Font.system(size: 17, weight: .regular, design: .rounded)
        static let bodyBold = SwiftUI.Font.system(size: 17, weight: .semibold, design: .rounded)
        static let caption = SwiftUI.Font.system(size: 15, weight: .regular, design: .rounded)
        static let captionBold = SwiftUI.Font.system(size: 15, weight: .semibold, design: .rounded)
        static let largeTitle = SwiftUI.Font.system(size: 56, weight: .bold, design: .rounded)
    }

    enum Spacing {
        /// 4
        static let xs: CGFloat = 4
        /// 8
        static let sm: CGFloat = 8
        /// 16
        static let md: CGFloat = 16
        /// 24
        static let lg: CGFloat = 24
        /// 32
        static let xl: CGFloat = 32
        /// 48
        static let xxl: CGFloat = 48
    }

    enum Size {
        static let buttonHeight: CGFloat = 56
        static let cardCornerRadius: CGFloat = 20
        static let smallCardCornerRadius: CGFloat = 12
        static let iconSize: CGFloat = 24
        static let largeIconSize: CGFloat = 48
    }

    enum Opacity {
        static let enabled: Double = 1.0
        static let disabled: Double = 0.4
        static let highlight: Double = 0.2
    }

    enum Shadow {
        case small
        case medium
        case large
        case accent
        case none

        var style: ShadowStyle {
            switch self {
            case .small:
                return ShadowStyle(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            case .medium:
                return ShadowStyle(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            case .large:
                return ShadowStyle(color: .black.opacity(0.2), radius: 16, x: 0, y: 8)
            case .accent:
                return ShadowStyle(color: SwiftUI.Color(red: 0.3, green: 0.6, blue: 1.0).opacity(0.2), radius: 8, x: 0, y: 4)
            case .none:
                return ShadowStyle(color: .clear, radius: 0, x: 0, y: 0)
            }
        }

        struct ShadowStyle {
            let color: SwiftUI.Color
            let radius: CGFloat
            let x: CGFloat
            let y: CGFloat
        }
    }
}

extension View {
    func shadow(_ shadow: DesignBook.Shadow) -> some View {
        let style = shadow.style
        return self.shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
}

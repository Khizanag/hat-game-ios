//
//  DesignBook+Shadow.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 20.11.25.
//

import SwiftUI

extension DesignBook {
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
                return ShadowStyle(
                    color: SwiftUI.Color(red: 0.3, green: 0.6, blue: 1.0).opacity(0.2),
                    radius: 8,
                    x: 0,
                    y: 4
                )
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


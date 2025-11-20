//
//  TeamDefaultColorGenerator.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 16.11.25.
//

import Foundation
import SwiftUI
import UIKit

struct TeamDefaultColorGenerator {
    static let defaultColors: [Color] = [
        Color(red: 0.3, green: 0.6, blue: 1.0),
        Color(red: 1.0, green: 0.4, blue: 0.4),
        Color(red: 0.4, green: 0.8, blue: 0.4),
        Color(red: 1.0, green: 0.7, blue: 0.2),
        Color(red: 0.8, green: 0.3, blue: 0.8),
        Color(red: 0.2, green: 0.8, blue: 0.8),
        Color(red: 1.0, green: 0.5, blue: 0.7),
        Color(red: 0.6, green: 0.4, blue: 0.9),
        Color(red: 0.9, green: 0.9, blue: 0.3),
        Color(red: 0.5, green: 0.3, blue: 0.2),
    ]

    func generateDefaultColor(for configuration: GameConfiguration) -> Color {
        let occupiedColors = configuration.teams.map { $0.color }

        for color in Self.defaultColors {
            if !isColorOccupied(color, in: occupiedColors) {
                return color
            }
        }

        // If all default colors are occupied, return the first one
        return Self.defaultColors[0]
    }

    private func isColorOccupied(_ color: Color, in occupiedColors: [Color]) -> Bool {
        occupiedColors.contains { occupiedColor in
            areColorsEqual(color, occupiedColor)
        }
    }

    private func areColorsEqual(_ color1: Color, _ color2: Color) -> Bool {
        let uiColor1 = UIColor(color1)
        let uiColor2 = UIColor(color2)

        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0

        guard uiColor1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1),
              uiColor2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2) else {
            return false
        }

        return abs(r1 - r2) < 0.01 && abs(g1 - g2) < 0.01 && abs(b1 - b2) < 0.01
    }
}

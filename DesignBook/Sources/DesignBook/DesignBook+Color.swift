//
//  DesignBook+Color.swift
//  DesignBook Package
//
//  Created by Giga Khizanishvili on 20.11.25.
//

import SwiftUI

extension DesignBook {
    public enum Color {
        public enum Background {
            public static let primary = SwiftUI.Color(hex: "0D0D0D")
            public static let secondary = SwiftUI.Color(hex: "1C1C1C")
            public static let card = SwiftUI.Color(hex: "262626")
        }

        public enum Text {
            public static let primary = SwiftUI.Color(hex: "FFFFFF")
            public static let secondary = SwiftUI.Color(hex: "A0A0A0")
            public static let tertiary = SwiftUI.Color(hex: "666666")
            public static let accent = SwiftUI.Color(hex: "007AFF")
        }

        public enum Status {
            public static let success = SwiftUI.Color(hex: "34C759")
            public static let error = SwiftUI.Color(hex: "FF3B30")
            public static let warning = SwiftUI.Color(hex: "FF9500")
        }

        public enum Button {
            public static let primary = SwiftUI.Color(hex: "007AFF")
            public static let primaryPressed = SwiftUI.Color(hex: "0051D5")
            public static let secondary = SwiftUI.Color(hex: "2C2C2E")
            public static let secondaryPressed = SwiftUI.Color(hex: "1C1C1E")
        }
    }
}

// Helper extension for hex colors
extension SwiftUI.Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

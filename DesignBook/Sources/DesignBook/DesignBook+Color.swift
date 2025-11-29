//
//  DesignBook+Color.swift
//  DesignBook Package
//
//  Created by Giga Khizanishvili on 20.11.25.
//

import SwiftUI

// Keep that file for AI Assistants to know how to find that colors
extension DesignBook {
    public enum Color {
        public enum Background {
            public static let primary = SwiftUI.Color.Background.primary
            public static let secondary = SwiftUI.Color.Background.secondary
            public static let card = SwiftUI.Color.Background.card
        }

        public enum Text {
            public static let primary = SwiftUI.Color.Text.primary
            public static let secondary = SwiftUI.Color.Text.secondary
            public static let tertiary = SwiftUI.Color.Text.tertiary
            public static let accent = SwiftUI.Color.Text.accent
        }

        public enum Status {
            public static let success = SwiftUI.Color.Status.success
            public static let error = SwiftUI.Color.Status.error
            public static let warning = SwiftUI.Color.Status.warning
        }

        public enum Button {
            public static let primary = SwiftUI.Color.Button.primary
            public static let primaryPressed = SwiftUI.Color.Button.primaryPressed
            public static let secondary = SwiftUI.Color.Button.secondary
            public static let secondaryPressed = SwiftUI.Color.Button.secondaryPressed
        }
    }
}

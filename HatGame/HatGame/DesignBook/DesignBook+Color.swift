//
//  DesignBook+Color.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 20.11.25.
//

import SwiftUI

// Keep that file for AI Assistants to know how to find that colors
extension DesignBook {
    enum Color {
        enum Background {
            static let primary = SwiftUI.Color.Background.primary
            static let secondary = SwiftUI.Color.Background.secondary
            static let card = SwiftUI.Color.Background.card
        }

        enum Text {
            static let primary = SwiftUI.Color.Text.primary
            static let secondary = SwiftUI.Color.Text.secondary
            static let tertiary = SwiftUI.Color.Text.tertiary
            static let accent = SwiftUI.Color.Text.accent
        }

        enum Status {
            static let success = SwiftUI.Color.Status.success
            static let error = SwiftUI.Color.Status.error
            static let warning = SwiftUI.Color.Status.warning
        }

        enum Button {
            static let primary = SwiftUI.Color.Button.primary
            static let primaryPressed = SwiftUI.Color.Button.primaryPressed
            static let secondary = SwiftUI.Color.Button.secondary
            static let secondaryPressed = SwiftUI.Color.Button.secondaryPressed
        }
    }
}

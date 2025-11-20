//
//  DesignBook+Color.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 20.11.25.
//

import SwiftUI

extension DesignBook {
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
}


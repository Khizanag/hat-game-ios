//
//  AppColorScheme.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 20.11.25.
//

import SwiftUI

enum AppColorScheme: String, CaseIterable {
    case light = "light"
    case dark = "dark"
    case system = "system"

    var displayName: String {
        switch self {
        case .light:
            return String(localized: "settings.appearance.light")
        case .dark:
            return String(localized: "settings.appearance.dark")
        case .system:
            return String(localized: "settings.appearance.system")
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .light:
            .light
        case .dark:
            .dark
        case .system:
            nil
        }
    }
}


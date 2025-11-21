//
//  AppIcon.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 20.11.25.
//

import SwiftUI

enum AppIcon: String, CaseIterable, Identifiable {
    case classic = "AppIcon"
    case sunset = "AppIconSunset"
    case neon = "AppIconNeon"
    case vintage = "AppIconVintage"
    case minimal = "AppIconMinimal"

    var id: String {
        rawValue
    }

    var title: String {
        String(localized: "settings.appIcon.\(identifier).title")
    }

    var subtitle: String {
        String(localized: "settings.appIcon.\(identifier).subtitle")
    }

    var previewNameLight: String {
        "\(previewBaseName)Light"
    }

    var previewNameDark: String {
        "\(previewBaseName)Dark"
    }

    var alternateIconName: String? {
        self == .classic ? nil : rawValue
    }

    private var identifier: String {
        switch self {
        case .classic:
            "classic"
        case .sunset:
            "sunset"
        case .neon:
            "neon"
        case .vintage:
            "vintage"
        case .minimal:
            "minimal"
        }
    }

    private var previewBaseName: String {
        switch self {
        case .classic:
            "AppIconClassic"
        case .sunset:
            "AppIconSunset"
        case .neon:
            "AppIconNeon"
        case .vintage:
            "AppIconVintage"
        case .minimal:
            "AppIconMinimal"
        }
    }
}
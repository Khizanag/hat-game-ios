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

    var alternateIconName: String? {
        self == .classic ? nil : rawValue
    }

    // MARK: - Visual Properties

    var displayColor: Color {
        switch self {
        case .classic:
            .blue
        case .sunset:
            .orange
        case .neon:
            .purple
        case .vintage:
            .brown
        case .minimal:
            .gray
        }
    }

    var iconSymbol: String {
        switch self {
        case .classic:
            "star.fill"
        case .sunset:
            "sun.max.fill"
        case .neon:
            "bolt.fill"
        case .vintage:
            "photo.fill"
        case .minimal:
            "circle.fill"
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .classic:
            [Color.blue, Color.indigo]
        case .sunset:
            [Color.orange, Color.pink]
        case .neon:
            [Color.purple, Color.blue]
        case .vintage:
            [Color.brown, Color.orange.opacity(0.7)]
        case .minimal:
            [Color.gray, Color.white.opacity(0.5)]
        }
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
}

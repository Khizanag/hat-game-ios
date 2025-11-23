//
//  AppConfiguration.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import Foundation
import Observation
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

@Observable
final class AppConfiguration {
    static let shared = AppConfiguration()

    private static let testModeKey = "HatGame.isTestMode"
    private static let defaultWordsPerPlayerKey = "HatGame.defaultWordsPerPlayer"
    private static let defaultRoundDurationKey = "HatGame.defaultRoundDuration"
    private static let isRightHandedKey = "HatGame.isRightHanded"
    private static let colorSchemeKey = "HatGame.colorScheme"
    private static let appIconKey = "HatGame.appIcon"

    var isTestMode: Bool {
        didSet {
            UserDefaults.standard.set(isTestMode, forKey: Self.testModeKey)
        }
    }

    var defaultWordsPerPlayer: Int {
        didSet {
            UserDefaults.standard.set(defaultWordsPerPlayer, forKey: Self.defaultWordsPerPlayerKey)
        }
    }

    var defaultRoundDuration: Int {
        didSet {
            UserDefaults.standard.set(defaultRoundDuration, forKey: Self.defaultRoundDurationKey)
        }
    }

    var isRightHanded: Bool {
        didSet {
            UserDefaults.standard.set(isRightHanded, forKey: Self.isRightHandedKey)
        }
    }

    var colorScheme: AppColorScheme {
        didSet {
            UserDefaults.standard.set(colorScheme.rawValue, forKey: Self.colorSchemeKey)
        }
    }

    var appIcon: AppIcon {
        didSet {
            UserDefaults.standard.set(appIcon.rawValue, forKey: Self.appIconKey)
            applyAppIcon(appIcon)
        }
    }

    private init() {
        isTestMode = UserDefaults.standard.bool(forKey: Self.testModeKey)
        defaultWordsPerPlayer = UserDefaults.standard.object(forKey: Self.defaultWordsPerPlayerKey) as? Int ?? 10
        defaultRoundDuration = UserDefaults.standard.object(forKey: Self.defaultRoundDurationKey) as? Int ?? 60
        isRightHanded = UserDefaults.standard.object(forKey: Self.isRightHandedKey) as? Bool ?? true

        if let rawValue = UserDefaults.standard.string(forKey: Self.colorSchemeKey),
           let scheme = AppColorScheme(rawValue: rawValue) {
            colorScheme = scheme
        } else {
            colorScheme = .system
        }

        if let storedIcon = UserDefaults.standard.string(forKey: Self.appIconKey),
           let icon = AppIcon(rawValue: storedIcon) {
            appIcon = icon
        } else {
            appIcon = .classic
        }
    }

    func applyStoredAppIcon() {
        applyAppIcon(appIcon)
    }

    private func applyAppIcon(_ icon: AppIcon) {
        #if os(iOS)
        guard UIApplication.shared.supportsAlternateIcons else {
            print("Alternate icons are not supported on this device")
            return
        }
        
        let desiredName = icon.alternateIconName
        let currentName = UIApplication.shared.alternateIconName
        
        if currentName == desiredName {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            UIApplication.shared.setAlternateIconName(desiredName) { error in
                if let error = error {
                    print("Failed to set app icon '\(desiredName ?? "primary")': \(error.localizedDescription)")
                    print("Error domain: \(error._domain), code: \(error._code)")
                } else {
                    print("Successfully set app icon to '\(desiredName ?? "primary")'")
                }
            }
        }
        #endif
    }
}
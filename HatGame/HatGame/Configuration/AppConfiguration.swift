//
//  AppConfiguration.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import Foundation
import Observation
import SwiftUI

@Observable
final class AppConfiguration {
    static let shared = AppConfiguration()

    private static let testModeKey = "HatGame.isTestMode"
    private static let defaultWordsPerPlayerKey = "HatGame.defaultWordsPerPlayer"
    private static let defaultRoundDurationKey = "HatGame.defaultRoundDuration"
    private static let isRightHandedKey = "HatGame.isRightHanded"
    private static let colorSchemeKey = "HatGame.colorScheme"

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
    }
}

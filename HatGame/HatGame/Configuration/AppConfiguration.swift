//
//  AppConfiguration.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import Foundation
import Observation

@Observable
final class AppConfiguration {
    private static let testModeKey = "HatGame.isTestMode"
    private static let defaultWordsPerPlayerKey = "HatGame.defaultWordsPerPlayer"
    private static let defaultRoundDurationKey = "HatGame.defaultRoundDuration"
    
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
    
    init() {
        isTestMode = UserDefaults.standard.bool(forKey: Self.testModeKey)
        defaultWordsPerPlayer = UserDefaults.standard.object(forKey: Self.defaultWordsPerPlayerKey) as? Int ?? 10
        defaultRoundDuration = UserDefaults.standard.object(forKey: Self.defaultRoundDurationKey) as? Int ?? 60
    }
}
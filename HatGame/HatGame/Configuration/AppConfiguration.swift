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
    
    var isTestMode: Bool {
        didSet {
            UserDefaults.standard.set(isTestMode, forKey: Self.testModeKey)
        }
    }
    
    init() {
        isTestMode = UserDefaults.standard.bool(forKey: Self.testModeKey)
    }
}
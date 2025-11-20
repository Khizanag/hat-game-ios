//
//  AppIconManager.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 20.11.25.
//

import SwiftUI
import UIKit

@MainActor
final class AppIconManager {
    static let shared = AppIconManager()

    private var currentIconName: String?

    private init() {
        currentIconName = UIApplication.shared.alternateIconName
    }

    func updateIcon(for colorScheme: ColorScheme) {
        guard UIApplication.shared.supportsAlternateIcons else { return }
        let desiredName = colorScheme == .dark ? "AppIconDark" : nil
        guard desiredName != currentIconName else { return }

        UIApplication.shared.setAlternateIconName(desiredName) { [weak self] error in
            if error == nil {
                self?.currentIconName = desiredName
            }
        }
    }
}
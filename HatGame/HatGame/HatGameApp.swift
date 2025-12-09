//
//  HatGameApp.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI
import Navigation

@main
struct HatGameApp: App {
    @State private var appConfiguration = AppConfiguration.shared

    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView()
            }
            .needsCloseButton()
            .environment(Navigator())
            .environment(GameManager())
            .preferredColorScheme(appConfiguration.colorScheme.colorScheme)
        }
    }
}

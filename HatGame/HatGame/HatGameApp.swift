//
//  HatGameApp.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

@main
struct HatGameApp: App {
    @State private var appConfiguration = AppConfiguration.shared

    var body: some Scene {
        WindowGroup {
            NavigationView {
                Page.home.view()
            }
            .environment(appConfiguration)
            .preferredColorScheme(appConfiguration.colorScheme.colorScheme)
        }
    }
}

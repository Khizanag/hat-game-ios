//
//  HatGameApp.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

@main
struct HatGameApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
    }
}

struct AppRootView: View {
    @State private var appConfiguration = AppConfiguration.shared

    var body: some View {
        NavigationView {
            Page.home.view()
        }
        .preferredColorScheme(appConfiguration.colorScheme.colorScheme)
        .environment(appConfiguration)
    }
}

//
//  HatGameApp.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

@main
struct HatGameApp: App {
    @State private var gameManager = GameManager()
    @State private var appConfiguration = AppConfiguration()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                Page.welcome.view()
            }
            .environment(gameManager)
            .environment(appConfiguration)
        }
    }
}

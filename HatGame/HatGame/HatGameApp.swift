//
//  HatGameApp.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI
import Navigation
import Networking

@main
struct HatGameApp: App {
    @State private var appConfiguration = AppConfiguration.shared
    @State private var roomManager = RoomManager()
    @State private var gameSyncManager = GameSyncManager()

    init() {
        Networking.configure()
    }

    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView()
            }
            .environment(roomManager)
            .environment(gameSyncManager)
            .preferredColorScheme(appConfiguration.colorScheme.colorScheme)
        }
    }
}

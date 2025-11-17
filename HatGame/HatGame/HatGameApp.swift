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
            NavigationView {
                Page.home.view()
            }
            .presentationBackground(Color.red)
        }
    }
}
//
//  Networking.swift
//  Networking
//
//  Created by Giga Khizanishvili on 22.12.24.
//

import Foundation
import FirebaseCore
import FirebaseDatabase

public enum Networking {
    public static func configure() {
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseApp.configure()
            // Enable offline persistence and ensure connection
            Database.database().isPersistenceEnabled = true
            Database.database().goOnline()
        } else {
            print("⚠️ GoogleService-Info.plist not found. Firebase features will be disabled.")
            print("   Download it from https://console.firebase.google.com/")
        }
    }

    public static var isConfigured: Bool {
        FirebaseApp.app() != nil
    }
}

// Re-export models for convenience
@_exported import struct Foundation.UUID

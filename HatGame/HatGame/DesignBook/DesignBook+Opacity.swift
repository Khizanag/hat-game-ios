//
//  DesignBook+Opacity.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 20.11.25.
//

extension DesignBook {
    enum Opacity {
        // MARK: - State Opacities
        static let enabled: Double = 1.0
        static let disabled: Double = 0.4

        // MARK: - Overlay & Background Opacities
        static let veryLight: Double = 0.05
        static let light: Double = 0.1
        static let subtle: Double = 0.15
        static let highlight: Double = 0.2
        static let medium: Double = 0.3
        static let semiTransparent: Double = 0.6
        static let semiOpaque: Double = 0.7
        static let mostlyOpaque: Double = 0.8
    }
}

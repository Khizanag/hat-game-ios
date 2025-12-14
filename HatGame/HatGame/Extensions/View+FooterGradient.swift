//
//  View+FooterGradient.swift
//  HatGame
//
//  Created by Giga Khizanishvili
//

import SwiftUI
import DesignBook

extension View {
    /// Adds a gradient fade effect to footer content
    /// Top is almost fully transparent, bottom has the solid background color
    func withFooterGradient() -> some View {
        self
            .background {
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: DesignBook.Color.Background.primary.opacity(0), location: 0.0),
                        .init(color: DesignBook.Color.Background.primary.opacity(0.02), location: 0.3),
                        .init(color: DesignBook.Color.Background.primary.opacity(0.1), location: 0.5),
                        .init(color: DesignBook.Color.Background.primary.opacity(0.4), location: 0.7),
                        .init(color: DesignBook.Color.Background.primary.opacity(0.8), location: 0.85),
                        .init(color: DesignBook.Color.Background.primary, location: 1.0)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
    }
}

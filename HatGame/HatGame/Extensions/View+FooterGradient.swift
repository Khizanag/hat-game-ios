//
//  View+FooterGradient.swift
//  HatGame
//
//  Created by Giga Khizanishvili
//

import DesignBook
import SwiftUI

extension View {
    /// Adds a soft scroll-edge fade above footer content and an opaque body
    /// behind it, so scrolling content never bleeds through buttons. The
    /// background extends into the bottom safe area for visual continuity
    /// with the home indicator zone.
    func withFooterGradient() -> some View {
        self
            .background {
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: DesignBook.Color.Background.primary.opacity(0), location: 0.0),
                        .init(color: DesignBook.Color.Background.primary.opacity(0.85), location: 0.18),
                        .init(color: DesignBook.Color.Background.primary, location: 0.32),
                        .init(color: DesignBook.Color.Background.primary, location: 1.0),
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea(.container, edges: .bottom)
            }
    }
}

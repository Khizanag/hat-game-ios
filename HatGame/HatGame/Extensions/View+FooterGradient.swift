//
//  View+FooterGradient.swift
//  HatGame
//
//  Created by Claude Code
//

import SwiftUI

extension View {
    /// Adds a gradient fade effect to footer content, similar to iOS 26 toolbar
    /// Creates a smooth fade from transparent to background color
    func withFooterGradient() -> some View {
        self
            .background {
                VStack(spacing: 0) {
                    // Gradient fade from transparent to background
                    LinearGradient(
                        gradient: Gradient(colors: [
                            DesignBook.Color.Background.primary.opacity(0),
                            DesignBook.Color.Background.primary.opacity(0.8),
                            DesignBook.Color.Background.primary
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 40)

                    // Solid background for button area
                    DesignBook.Color.Background.primary
                }
                .ignoresSafeArea(edges: .bottom)
            }
            .background(.ultraThinMaterial.opacity(0.5))
    }
}

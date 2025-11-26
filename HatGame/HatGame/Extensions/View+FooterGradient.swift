//
//  View+FooterGradient.swift
//  HatGame
//
//  Created by Claude Code
//

import SwiftUI

extension View {
    /// Adds a gradient fade effect to footer content, similar to iOS 26 toolbar
    /// Creates a smooth, transparent linear fade from visible content to background
    func withFooterGradient() -> some View {
        self
            .background {
                VStack(spacing: 0) {
                    // Smooth linear gradient fade - top half is very transparent
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: DesignBook.Color.Background.primary.opacity(0), location: 0.0),
                            .init(color: DesignBook.Color.Background.primary.opacity(DesignBook.Opacity.veryLight), location: 0.2),
                            .init(color: DesignBook.Color.Background.primary.opacity(DesignBook.Opacity.veryLight), location: 0.35),
                            .init(color: DesignBook.Color.Background.primary.opacity(DesignBook.Opacity.light), location: 0.45),
                            .init(color: DesignBook.Color.Background.primary.opacity(DesignBook.Opacity.highlight), location: 0.55),
                            .init(color: DesignBook.Color.Background.primary.opacity(DesignBook.Opacity.disabled), location: 0.65),
                            .init(color: DesignBook.Color.Background.primary.opacity(DesignBook.Opacity.semiTransparent + 0.05), location: 0.8),
                            .init(color: DesignBook.Color.Background.primary.opacity(DesignBook.Opacity.mostlyOpaque + 0.1), location: 0.95),
                            .init(color: DesignBook.Color.Background.primary, location: 1.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: DesignBook.Size.footerGradientHeight)

                    // Solid background for button area
                    DesignBook.Color.Background.primary
                }
                .ignoresSafeArea(edges: .bottom)
            }
            .background(.ultraThinMaterial.opacity(DesignBook.Opacity.light))
    }
}

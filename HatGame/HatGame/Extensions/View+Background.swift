//
//  View+Background.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI
import DesignBook

extension View {
    func setDefaultBackground() -> some View {
        background(
            DesignBook.Color.Background.primary
                .ignoresSafeArea()
        )
    }

    @ViewBuilder
    func setDefaultStyle(title: String? = nil) -> some View {
        if let title {
            self
                .setDefaultBackground()
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbarBackground(DesignBook.Color.Background.primary, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .needsCloseButton()
                .closeButtonToolbar()
        } else {
            self
                .setDefaultBackground()
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbarBackground(DesignBook.Color.Background.primary, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .needsCloseButton()
                .closeButtonToolbar()
        }
    }
}

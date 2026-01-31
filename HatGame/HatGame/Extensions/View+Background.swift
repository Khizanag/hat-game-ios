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
        )
    }

    @ViewBuilder
    func setDefaultStyle(title: String? = nil, showCloseButton: Bool = false) -> some View {
        if let title {
            if showCloseButton {
                self
                    .setDefaultBackground()
                    .navigationTitle(title)
                    .navigationBarTitleDisplayMode(.inline)
                    .closeButtonToolbar()
            } else {
                self
                    .setDefaultBackground()
                    .navigationTitle(title)
                    .navigationBarTitleDisplayMode(.inline)
            }
        } else {
            if showCloseButton {
                self
                    .setDefaultBackground()
                    .closeButtonToolbar()
            } else {
                self
                    .setDefaultBackground()
            }
        }
    }
}

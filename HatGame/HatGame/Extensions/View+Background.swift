//
//  View+Background.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

extension View {
    func setDefaultBackground() -> some View {
        background(
            DesignBook.Color.Background.primary
                .ignoresSafeArea()
        )
    }
}
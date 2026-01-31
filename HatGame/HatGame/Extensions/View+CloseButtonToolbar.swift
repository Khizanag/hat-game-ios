//
//  View+CloseButtonToolbar.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI
import DesignBook
import Navigation

private struct CloseButtonToolbarModifier: ViewModifier {
    @Environment(Navigator.self) private var navigator

    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    navigator.dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(DesignBook.Color.Text.primary)
                }
            }
        }
    }
}

extension View {
    func closeButtonToolbar() -> some View {
        modifier(CloseButtonToolbarModifier())
    }
}

//
//  View+CloseButtonToolbar.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

private struct NeedsCloseButtonKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var needsCloseButton: Bool {
        get { self[NeedsCloseButtonKey.self] }
        set { self[NeedsCloseButtonKey.self] = newValue }
    }
}

private struct CloseButtonToolbarModifier: ViewModifier {
    @Environment(\.needsCloseButton) private var needsCloseButton
    @Environment(Navigator.self) private var navigator
    
    func body(content: Content) -> some View {
        content.toolbar {
            if needsCloseButton {
                ToolbarItem(placement: .navigationBarTrailing) {
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
}

extension View {
    func closeButtonToolbar() -> some View {
        modifier(CloseButtonToolbarModifier())
    }
    
    func needsCloseButton(_ value: Bool = true) -> some View {
        environment(\.needsCloseButton, value)
    }
}


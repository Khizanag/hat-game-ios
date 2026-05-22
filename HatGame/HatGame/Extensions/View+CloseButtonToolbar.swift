//
//  View+CloseButtonToolbar.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import DesignBook
import Navigation
import SwiftUI

// MARK: - Automatic Navigation Button
/// Shows a trailing close (X) only when this view is the root of a modal flow
/// (the navigator's path is empty). Pushed screens keep the native leading
/// back button so iOS can supply the previous screen's title and standard chevron.
private struct NavigationButtonToolbarModifier: ViewModifier {
    @Environment(Navigator.self) private var navigator

    func body(content: Content) -> some View {
        content
            .toolbar {
                if navigator.navigationPath.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
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

// MARK: - Navigation toolbar
extension View {
    func navigationButtonToolbar() -> some View {
        modifier(NavigationButtonToolbarModifier())
    }
}

//
//  NavigationView.swift
//  Navigation Package
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

public struct NavigationView<RootContent: View>: View {
    @State private var navigator = Navigator()
    @ViewBuilder private let rootContent: () -> RootContent
    @Environment(\.dismiss) private var dismiss

    public init(@ViewBuilder rootContent: @escaping () -> RootContent) {
        self.rootContent = rootContent
    }

    public var body: some View {
        NavigationStack(path: $navigator.navigationPath) {
            rootContent()
                .navigationDestination(for: AnyPage.self) { page in
                    page.view()
                }
        }
        .environment(navigator)
        .fullScreenCover(item: $navigator.presentedPage) { page in
            page.view()
                .environment(navigator)
        }
        .onReceive(navigator.pleaseDismissViewPublisher) {
            dismiss()
        }
    }
}

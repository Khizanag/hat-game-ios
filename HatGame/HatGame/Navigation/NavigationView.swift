//
//  NavigationView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct NavigationView<RootContent: View>: View {
    @State private var navigator = Navigator()
    @ViewBuilder private let rootContent: () -> RootContent
    @Environment(\.dismiss) private var dismiss
    
    init(@ViewBuilder rootContent: @escaping () -> RootContent) {
        self.rootContent = rootContent
    }
    
    var body: some View {
        NavigationStack(path: $navigator.navigationPath) {
            rootContent()
                .navigationDestination(for: Page.self) { page in
                    page.view()
                }
        }
        .environment(navigator)
        .fullScreenCover(item: $navigator.presentedPage) { page in
            page.view()
        }
        .onReceive(navigator.pleaseDismissViewPublisher) {
            dismiss()
        }
    }
}

#Preview {
    NavigationView {
        Page.welcome.view()
    }
    .environment(GameManager())
}
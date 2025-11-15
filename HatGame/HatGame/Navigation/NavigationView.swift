//
//  NavigationView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct NavigationView<RootContent: View>: View {
    @State private var navigator = Navigator()
    let rootContent: () -> RootContent
    
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
    }
}

#Preview {
    NavigationView {
        Page.welcome.view()
    }
    .environment(GameManager())
}


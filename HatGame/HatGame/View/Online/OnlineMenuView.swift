//
//  OnlineMenuView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 22.12.24.
//

import SwiftUI
import DesignBook
import Navigation

struct OnlineMenuView: View {
    @Environment(Navigator.self) private var navigator

    var body: some View {
        content
            .navigationTitle(String(localized: "online.title"))
            .setDefaultBackground()
    }
}

// MARK: - Private
private extension OnlineMenuView {
    var content: some View {
        VStack(spacing: DesignBook.Spacing.xl) {
            Spacer()

            headerSection

            Spacer()

            actionButtons
        }
        .paddingHorizontalDefault()
    }

    var headerSection: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            Image(systemName: "globe")
                .font(.system(size: 80))
                .foregroundStyle(DesignBook.Color.Text.primary)

            Text("online.description")
                .font(DesignBook.Font.body)
                .foregroundColor(DesignBook.Color.Text.secondary)
                .multilineTextAlignment(.center)
        }
    }

    var actionButtons: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            PrimaryButton(title: String(localized: "online.createRoom"), icon: "plus.circle.fill") {
                navigator.push(.createRoom)
            }

            SecondaryButton(title: String(localized: "online.joinRoom"), icon: "arrow.right.circle") {
                navigator.push(.joinRoom)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: DesignBook.Spacing.xl)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        OnlineMenuView()
    }
    .environment(Navigator())
}

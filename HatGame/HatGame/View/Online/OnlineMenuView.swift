//
//  OnlineMenuView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 22.12.24.
//

import DesignBook
import Navigation
import SwiftUI

struct OnlineMenuView: View {
    @Environment(Navigator.self) private var navigator
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var isPulsing: Bool = false

    var body: some View {
        content
            .navigationTitle(String(localized: "online.title"))
            .setDefaultStyle()
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
    }
}

// MARK: - Composition
private extension OnlineMenuView {
    var content: some View {
        VStack(spacing: DesignBook.Spacing.xl) {
            Spacer()
            hero
            Spacer()
            actionButtons
        }
        .paddingHorizontalDefault()
        .padding(.bottom, DesignBook.Spacing.lg)
    }

    var hero: some View {
        VStack(spacing: DesignBook.Spacing.lg) {
            ZStack {
                Circle()
                    .fill(DesignBook.Gradient.primary)
                    .frame(width: 156, height: 156)
                    .blur(radius: 36)
                    .opacity(0.55)

                Circle()
                    .fill(DesignBook.Color.Background.card)
                    .frame(width: 136, height: 136)
                    .overlay {
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        DesignBook.Color.Text.accent.opacity(0.4),
                                        DesignBook.Color.Text.accent.opacity(0.0),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    }
                    .shadow(.large)

                Image(systemName: "globe.americas.fill")
                    .font(.system(size: 64, weight: .bold))
                    .foregroundStyle(DesignBook.Gradient.primary)
                    .scaleEffect(reduceMotion ? 1.0 : (isPulsing ? 1.04 : 0.96))
            }
            .accessibilityHidden(true)

            VStack(spacing: DesignBook.Spacing.xs) {
                Text("online.title")
                    .font(DesignBook.Font.largeTitle)
                    .foregroundStyle(DesignBook.Color.Text.primary)

                Text("online.description")
                    .font(DesignBook.Font.body)
                    .foregroundStyle(DesignBook.Color.Text.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignBook.Spacing.lg)
            }
        }
    }

    var actionButtons: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            PrimaryButton(title: String(localized: "online.createRoom"), icon: "plus.circle.fill") {
                DesignBook.Haptics.tap()
                navigator.push(.createRoom)
            }
            SecondaryButton(title: String(localized: "online.joinRoom"), icon: "arrow.right.circle") {
                DesignBook.Haptics.tap()
                navigator.push(.joinRoom)
            }
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

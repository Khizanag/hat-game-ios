//
//  LocalMenuView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 21.05.26.
//

import DesignBook
import Navigation
import SwiftUI

/// Entry screen for the nearby (MC) flow — mirrors `OnlineMenuView`.
struct LocalMenuView: View {
    @Environment(Navigator.self) private var navigator
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var isPulsing: Bool = false

    var body: some View {
        VStack(spacing: DesignBook.Spacing.xl) {
            Spacer()
            hero
            Spacer()
            actions
        }
        .paddingHorizontalDefault()
        .padding(.bottom, DesignBook.Spacing.lg)
        .navigationTitle(String(localized: "local.title"))
        .setDefaultStyle()
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }

    private var hero: some View {
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
                    .shadow(.large)
                Image(systemName: "dot.radiowaves.left.and.right")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundStyle(DesignBook.Gradient.primary)
                    .symbolEffect(.variableColor.iterative, options: .repeating, isActive: !reduceMotion)
                    .scaleEffect(reduceMotion ? 1.0 : (isPulsing ? 1.04 : 0.96))
            }
            .accessibilityHidden(true)

            VStack(spacing: DesignBook.Spacing.xs) {
                Text("local.title")
                    .font(DesignBook.Font.largeTitle)
                    .foregroundStyle(DesignBook.Color.Text.primary)
                Text("local.description")
                    .font(DesignBook.Font.body)
                    .foregroundStyle(DesignBook.Color.Text.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignBook.Spacing.lg)
            }
        }
    }

    private var actions: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            PrimaryButton(title: String(localized: "local.host"), icon: "antenna.radiowaves.left.and.right") {
                DesignBook.Haptics.tap()
                navigator.push(.localHostSetup)
            }
            SecondaryButton(title: String(localized: "local.join"), icon: "magnifyingglass") {
                DesignBook.Haptics.tap()
                navigator.push(.localBrowser)
            }
        }
    }
}

//
//  WordSettingsView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct WordSettingsView: View {
    @Environment(GameManager.self) private var gameManager
    private let appConfiguration = AppConfiguration.shared
    @Environment(Navigator.self) private var navigator

    @State private var selectedWordCount: Int

    init() {
        _selectedWordCount = State(initialValue: 10)
    }

    var body: some View {
        content
            .setDefaultStyle(title: String(localized: "Word Settings"))
            .onAppear {
                selectedWordCount = appConfiguration.defaultWordsPerPlayer
            }
    }
}

private extension WordSettingsView {
    var content: some View {
        ScrollView {
            VStack(spacing: DesignBook.Spacing.lg) {
                headerCard
                controlsCard
            }
            .paddingHorizontalDefault()
            .padding(.bottom, DesignBook.Spacing.xxl)
        }
        .safeAreaInset(edge: .bottom) {
            continueButton
                .paddingHorizontalDefault()
        }
    }

    var headerCard: some View {
        HeaderCard(
            title: String(localized: "How many words?"),
            description: String(localized: "Every player will add the same number of words. Choose what feels right for today's game.")
        )
    }

    var controlsCard: some View {
        GameCard {
            VStack(spacing: DesignBook.Spacing.md) {
                header
                slider
                stepper
                legendTags
            }
        }
    }

    var header: some View {
        HStack {
            Text("wordSettings.wordsPerPlayer")
                .font(DesignBook.Font.headline)
                .foregroundColor(DesignBook.Color.Text.primary)

            Spacer()

            Text("\(selectedWordCount)")
                .font(DesignBook.Font.title2)
                .foregroundColor(DesignBook.Color.Text.accent)
        }
    }

    var slider: some View {
        Slider(value: wordCountBinding, in: 3...20, step: 1)
            .tint(DesignBook.Color.Text.accent)
    }

    var stepper: some View {
        Stepper(value: $selectedWordCount, in: 3...20) {
            Text("common.tapOrHoldToAdjust")
                .font(DesignBook.Font.caption)
                .foregroundColor(DesignBook.Color.Text.secondary)
        }
    }

    var legendTags: some View {
        HStack(spacing: DesignBook.Spacing.md) {
            LegendTag(title: String(localized: "Short & speedy"), range: "3-7", isHighlighted: selectedWordCount.isBetween(3, and: 7))
            LegendTag(title: String(localized: "Balanced"), range: "8-12", isHighlighted: selectedWordCount.isBetween(8, and: 12))
            LegendTag(title: String(localized: "Epic round"), range: "13-20", isHighlighted: selectedWordCount.isBetween(13, and: 20))
        }
    }

    var continueButton: some View {
        PrimaryButton(title: String(localized: "Continue"), icon: "arrow.right.circle.fill") {
            handleContinue()
        }
    }

    var wordCountBinding: Binding<Double> {
        Binding(
            get: { Double(selectedWordCount) },
            set: { selectedWordCount = Int($0) }
        )
    }

    func handleContinue() {
        gameManager.configuration.wordsPerPlayer = selectedWordCount
        navigator.push(.timerSettings)
    }
}

private extension Int {
    func isBetween(_ lower: Int, and upper: Int) -> Bool {
        self >= lower && self <= upper
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        Page.wordSettings.view()
    }
    .environment(GameManager())
}

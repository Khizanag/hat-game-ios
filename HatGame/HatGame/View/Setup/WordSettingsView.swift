//
//  WordSettingsView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct WordSettingsView: View {
    @Environment(GameManager.self) private var gameManager
    @Environment(Navigator.self) private var navigator
    
    @State private var selectedWordCount: Int = 3 // TODO: Update to 10
    
    var body: some View {
        content
            .setDefaultStyle(title: "Word Settings")
    }
}

private extension WordSettingsView {
    var content: some View {
        ScrollView {
            VStack(spacing: DesignBook.Spacing.lg) {
                headerCard
                controlsCard
            }
            .padding(.horizontal, DesignBook.Spacing.lg)
        }
        .overlay(alignment: .bottom) {
            continueButton
                .padding(.horizontal, DesignBook.Spacing.lg)
        }
    }
    
    var headerCard: some View {
        HeaderCard(
            title: "How many words?",
            description: "Every player will add the same number of words. Choose what feels right for today's game."
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
            Text("Words per player")
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
            Text("Tap or hold to adjust")
                .font(DesignBook.Font.caption)
                .foregroundColor(DesignBook.Color.Text.secondary)
        }
    }
    
    var legendTags: some View {
        HStack(spacing: DesignBook.Spacing.md) {
            LegendTag(title: "Short & speedy", range: "3-7", isHighlighted: selectedWordCount.isBetween(3, and: 7))
            LegendTag(title: "Balanced", range: "8-12", isHighlighted: selectedWordCount.isBetween(8, and: 12))
            LegendTag(title: "Epic round", range: "13-20", isHighlighted: selectedWordCount.isBetween(13, and: 20))
        }
    }
    
    var continueButton: some View {
        PrimaryButton(title: "Continue") {
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
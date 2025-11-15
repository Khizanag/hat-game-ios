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
    
    @State private var selectedWordCount: Int = 10
    
    var body: some View {
        content
            .setDefaultBackground()
            .navigationTitle("Word Settings")
            .navigationBarTitleDisplayMode(.inline)
            .closeButtonToolbar()
    }
}

private extension WordSettingsView {
    var content: some View {
        VStack(spacing: DesignBook.Spacing.lg) {
            descriptionCard
            controlsCard
            Spacer()
            continueButton
        }
    }
    
    var descriptionCard: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                Text("How many words?")
                    .font(DesignBook.Font.title2)
                    .foregroundColor(DesignBook.Color.Text.primary)
                
                Text("Every player will add the same number of words. Choose what feels right for today's game.")
                    .font(DesignBook.Font.body)
                    .foregroundColor(DesignBook.Color.Text.secondary)
            }
        }
        .padding(.horizontal, DesignBook.Spacing.lg)
        .padding(.top, DesignBook.Spacing.lg)
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
        .padding(.horizontal, DesignBook.Spacing.lg)
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
        .padding(.horizontal, DesignBook.Spacing.lg)
        .padding(.bottom, DesignBook.Spacing.lg)
    }
    
    var wordCountBinding: Binding<Double> {
        Binding(
            get: { Double(selectedWordCount) },
            set: { selectedWordCount = Int($0) }
        )
    }
    
    func handleContinue() {
        gameManager.wordsPerPlayer = selectedWordCount
        navigator.push(.timerSettings)
    }
}

private extension Int {
    func isBetween(_ lower: Int, and upper: Int) -> Bool {
        self >= lower && self <= upper
    }
}

private struct LegendTag: View {
    let title: String
    let range: String
    let isHighlighted: Bool
    
    var body: some View {
        VStack(spacing: DesignBook.Spacing.xs) {
            Text(title)
                .font(DesignBook.Font.captionBold)
                .foregroundColor(isHighlighted ? DesignBook.Color.Text.accent : DesignBook.Color.Text.primary)
            Text(range)
                .font(DesignBook.Font.caption)
                .foregroundColor(isHighlighted ? DesignBook.Color.Text.accent : DesignBook.Color.Text.secondary)
        }
        .padding(.vertical, DesignBook.Spacing.sm)
        .padding(.horizontal, DesignBook.Spacing.md)
        .background(isHighlighted ? DesignBook.Color.Text.accent.opacity(0.2) : DesignBook.Color.Background.secondary)
        .cornerRadius(DesignBook.Size.smallCardCornerRadius)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        Page.wordSettings.view()
    }
    .environment(GameManager())
}



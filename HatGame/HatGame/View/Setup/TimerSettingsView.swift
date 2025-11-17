//
//  TimerSettingsView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct TimerSettingsView: View {
    @Environment(GameManager.self) private var gameManager
    private let appConfiguration = AppConfiguration.shared
    @Environment(Navigator.self) private var navigator

    @State private var selectedDuration: Int

    init() {
        _selectedDuration = State(initialValue: 60)
    }
    
    var body: some View {
        content
            .setDefaultStyle(title: "Timer Settings")
            .onAppear {
                selectedDuration = appConfiguration.defaultRoundDuration
            }
    }
}

// MARK: - Components
private extension TimerSettingsView {
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
            title: "Round timer",
            description: "Each team gets the same amount of time per turn. Choose how intense you want the round to be."
        )
    }
    
    var controlsCard: some View {
        GameCard {
            VStack(spacing: DesignBook.Spacing.md) {
                durationHeader
                durationSlider
                durationStepper
                timerTags
            }
        }
    }
    
    var durationHeader: some View {
        HStack {
            Text("Seconds per team")
                .font(DesignBook.Font.headline)
                .foregroundColor(DesignBook.Color.Text.primary)
            
            Spacer()
            
            Text("\(selectedDuration)s")
                .font(DesignBook.Font.title2)
                .foregroundColor(DesignBook.Color.Text.accent)
        }
    }
    
    var durationSlider: some View {
        Slider(value: durationBinding, in: 5...120, step: 5)
            .tint(DesignBook.Color.Text.accent)
    }
    
    var durationStepper: some View {
        Stepper(value: $selectedDuration, in: 5...120, step: 5) {
            Text("Tap or hold to adjust")
                .font(DesignBook.Font.caption)
                .foregroundColor(DesignBook.Color.Text.secondary)
        }
    }
    
    var timerTags: some View {
        HStack(spacing: DesignBook.Spacing.md) {
            LegendTag(title: "Lightning", range: "5-30s", isHighlighted: selectedDuration.isBetween(5, and: 30))
            LegendTag(title: "Classic", range: "60s", isHighlighted: selectedDuration == 60)
            LegendTag(title: "Marathon", range: "90-120s", isHighlighted: selectedDuration.isBetween(90, and: 120))
        }
    }
    
    var continueButton: some View {
        PrimaryButton(title: "Continue", icon: "arrow.right.circle.fill") {
            handleContinue()
        }
    }
    
    var durationBinding: Binding<Double> {
        Binding(
            get: { Double(selectedDuration) },
            set: { selectedDuration = Int($0) }
        )
    }
    
    func handleContinue() {
        gameManager.configuration.roundDuration = selectedDuration
        navigator.push(.wordInput)
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
        Page.timerSettings.view()
    }
    .environment(GameManager())
}
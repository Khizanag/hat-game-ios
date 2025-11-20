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
            .setDefaultStyle(title: String(localized: "timer_settings.title"))
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
            title: String(localized: "timer_settings.header_title"),
            description: String(localized: "timer_settings.header_description")
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
            Text(String(localized: "timer_settings.seconds_per_team"))
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
            Text(String(localized: "common.tap_or_hold_to_adjust"))
                .font(DesignBook.Font.caption)
                .foregroundColor(DesignBook.Color.Text.secondary)
        }
    }

    var timerTags: some View {
        HStack(spacing: DesignBook.Spacing.md) {
            LegendTag(title: String(localized: "timer_settings.legend.lightning"), range: "5-30s", isHighlighted: selectedDuration.isBetween(5, and: 30))
            LegendTag(title: String(localized: "timer_settings.legend.classic"), range: "60s", isHighlighted: selectedDuration == 60)
            LegendTag(title: String(localized: "timer_settings.legend.marathon"), range: "90-120s", isHighlighted: selectedDuration.isBetween(90, and: 120))
        }
    }

    var continueButton: some View {
        PrimaryButton(title: String(localized: "common.buttons.continue"), icon: "arrow.right.circle.fill") {
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

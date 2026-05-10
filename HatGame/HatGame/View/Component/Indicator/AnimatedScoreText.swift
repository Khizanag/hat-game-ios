//
//  AnimatedScoreText.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 19.05.26.
//

import DesignBook
import SwiftUI

/// A text view that counts up to its target value when it appears or when the value changes.
struct AnimatedScoreText: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let value: Int
    var font: Font = DesignBook.Font.title2
    var color: Color = DesignBook.Color.Text.primary
    var duration: Double = 0.9

    @State private var displayValue: Int = 0

    var body: some View {
        Text(verbatim: "\(displayValue)")
            .font(font)
            .monospacedDigit()
            .foregroundStyle(color)
            .contentTransition(.numericText(value: Double(displayValue)))
            .onAppear { animate(to: value) }
            .onChange(of: value) { _, newValue in animate(to: newValue) }
    }
}

// MARK: - Helpers
private extension AnimatedScoreText {
    func animate(to target: Int) {
        guard !reduceMotion else {
            displayValue = target
            return
        }

        let start = displayValue
        let delta = target - start
        guard delta != 0 else { return }

        let steps = min(max(abs(delta), 8), 30)
        let stepDuration = duration / Double(steps)

        for step in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(step)) {
                withAnimation(.easeOut(duration: stepDuration)) {
                    let progress = Double(step) / Double(steps)
                    displayValue = start + Int((Double(delta) * progress).rounded())
                }
            }
        }
    }
}

#Preview {
    AnimatedScoreText(value: 42, font: DesignBook.Font.largeTitle, color: .blue)
        .padding()
}

//
//  GameSettingsRow.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 22.05.26.
//

import DesignBook
import SwiftUI

/// A labelled +/- stepper row used to tune game settings (words per
/// player, round duration). Shared by `RoomCreationView` and
/// `LocalHostSetupView` so the two flows look and behave the same.
struct GameSettingsRow: View {
    let icon: String
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int
    var suffix: String?

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(DesignBook.IconFont.small)
                .foregroundStyle(DesignBook.Color.Text.tertiary)
                .frame(width: 24)
            Text(title)
                .font(DesignBook.Font.body)
                .foregroundStyle(DesignBook.Color.Text.primary)
            Spacer()
            HStack(spacing: DesignBook.Spacing.sm) {
                stepperButton(systemName: "minus.circle.fill", enabled: value - step >= range.lowerBound) {
                    DesignBook.Haptics.selection()
                    value -= step
                }
                Text(suffix.map { "\(value) \($0)" } ?? "\(value)")
                    .font(DesignBook.Font.headline)
                    .foregroundStyle(DesignBook.Color.Text.primary)
                    .monospacedDigit()
                    .frame(minWidth: 50)
                    .contentTransition(.numericText(value: Double(value)))
                stepperButton(systemName: "plus.circle.fill", enabled: value + step <= range.upperBound) {
                    DesignBook.Haptics.selection()
                    value += step
                }
            }
        }
        .padding(.vertical, DesignBook.Spacing.xs)
    }

    private func stepperButton(systemName: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(DesignBook.Font.title3)
                .foregroundStyle(enabled ? DesignBook.Color.Text.accent : DesignBook.Color.Text.tertiary)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

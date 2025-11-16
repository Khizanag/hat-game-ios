//
//  TeamFormView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 16.11.25.
//

import SwiftUI

struct TeamFormView: View {
    @Binding var teamName: String
    @Binding var playerNames: [String]
    
    let title: String
    let primaryButtonTitle: String
    let onPrimaryAction: () -> Void
    let onCancel: () -> Void
    
    private var canSave: Bool {
        !teamName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        playerNames.allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
    
    var body: some View {
        VStack(spacing: DesignBook.Spacing.lg) {
            teamNameField
            playersSection
            Spacer()
            actionButtons
        }
        .padding(.horizontal, DesignBook.Spacing.lg)
        .padding(.top, DesignBook.Spacing.lg)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension TeamFormView {
    var teamNameField: some View {
        VStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
            Text("Team Name")
                .font(DesignBook.Font.captionBold)
                .foregroundColor(DesignBook.Color.Text.secondary)
            
            TextField("Enter team name", text: $teamName)
                .textFieldStyle(.plain)
                .font(DesignBook.Font.headline)
                .foregroundColor(DesignBook.Color.Text.primary)
                .padding(DesignBook.Spacing.md)
                .background(DesignBook.Color.Background.secondary)
                .cornerRadius(DesignBook.Size.smallCardCornerRadius)
        }
    }
    
    var playersSection: some View {
        VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
            Text("Players")
                .font(DesignBook.Font.captionBold)
                .foregroundColor(DesignBook.Color.Text.secondary)
            
            ForEach(playerNames.indices, id: \.self) { index in
                playerField(index: index)
            }
        }
    }
    
    func playerField(index: Int) -> some View {
        VStack(alignment: .leading, spacing: DesignBook.Spacing.xs) {
            Text("Player \(index + 1)")
                .font(DesignBook.Font.caption)
                .foregroundColor(DesignBook.Color.Text.secondary)
            
            TextField("Enter player name", text: Binding(
                get: { playerNames[index] },
                set: { playerNames[index] = $0 }
            ))
            .textFieldStyle(.plain)
            .font(DesignBook.Font.body)
            .foregroundColor(DesignBook.Color.Text.primary)
            .padding(DesignBook.Spacing.md)
            .background(DesignBook.Color.Background.secondary)
            .cornerRadius(DesignBook.Size.smallCardCornerRadius)
        }
    }
    
    var actionButtons: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            PrimaryButton(title: primaryButtonTitle) {
                onPrimaryAction()
            }
            .disabled(!canSave)
            .opacity(canSave ? DesignBook.Opacity.enabled : DesignBook.Opacity.disabled)
            
            DestructiveButton(title: "Cancel") {
                onCancel()
            }
        }
        .padding(.bottom, DesignBook.Spacing.lg)
    }
}
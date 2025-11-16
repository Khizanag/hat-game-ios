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
        ScrollView {
            VStack(spacing: DesignBook.Spacing.lg) {
                teamNameCard
                playersCard
            }
            .padding(.horizontal, DesignBook.Spacing.lg)
            .padding(.top, DesignBook.Spacing.lg)
            .padding(.bottom, DesignBook.Spacing.xxl)
        }
        .safeAreaInset(edge: .bottom) {
            actionButtons
        }
        .setDefaultStyle(title: title)
    }
}

private extension TeamFormView {
    var teamNameCard: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                HStack(spacing: DesignBook.Spacing.sm) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: DesignBook.Size.iconSize))
                        .foregroundColor(DesignBook.Color.Text.accent)
                    
                    Text("Team Name")
                        .font(DesignBook.Font.captionBold)
                        .foregroundColor(DesignBook.Color.Text.secondary)
                }
                
                TextField("Enter team name", text: $teamName)
                    .textFieldStyle(.plain)
                    .font(DesignBook.Font.headline)
                    .foregroundColor(DesignBook.Color.Text.primary)
                    .padding(DesignBook.Spacing.md)
                    .background(DesignBook.Color.Background.secondary)
                    .cornerRadius(DesignBook.Size.smallCardCornerRadius)
            }
        }
    }
    
    var playersCard: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                HStack(spacing: DesignBook.Spacing.sm) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: DesignBook.Size.iconSize))
                        .foregroundColor(DesignBook.Color.Text.accent)
                    
                    Text("Players")
                        .font(DesignBook.Font.captionBold)
                        .foregroundColor(DesignBook.Color.Text.secondary)
                    
                    Spacer()
                    
                    Text("\(playerNames.count)")
                        .font(DesignBook.Font.captionBold)
                        .foregroundColor(DesignBook.Color.Text.tertiary)
                }
                
                VStack(spacing: DesignBook.Spacing.md) {
                    ForEach(playerNames.indices, id: \.self) { index in
                        playerField(index: index)
                    }
                }
            }
        }
    }
    
    func playerField(index: Int) -> some View {
        HStack(spacing: DesignBook.Spacing.md) {
            Text("\(index + 1)")
                .font(DesignBook.Font.captionBold)
                .foregroundColor(DesignBook.Color.Text.accent)
                .frame(width: 24, height: 24)
                .background(DesignBook.Color.Text.accent.opacity(DesignBook.Opacity.highlight))
                .clipShape(Circle())
            
            TextField("Player name", text: Binding(
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
        .padding(.horizontal, DesignBook.Spacing.lg)
        .padding(.top, DesignBook.Spacing.md)
        .padding(.bottom, DesignBook.Spacing.lg)
    }
}
//
//  TeamFormView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 16.11.25.
//

import SwiftUI
import UIKit

struct TeamFormView: View {
    @Binding var teamName: String
    @Binding var playerNames: [String]
    @Binding var teamColor: Color
    
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
                colorCard
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
    
    var colorCard: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                HStack(spacing: DesignBook.Spacing.sm) {
                    Image(systemName: "paintpalette.fill")
                        .font(.system(size: DesignBook.Size.iconSize))
                        .foregroundColor(DesignBook.Color.Text.accent)
                    
                    Text("Team Color")
                        .font(DesignBook.Font.captionBold)
                        .foregroundColor(DesignBook.Color.Text.secondary)
                }
                
                colorPicker
            }
        }
    }
    
    var colorPicker: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            suggestedColors
            
            ColorPicker("Custom Color", selection: $teamColor, supportsOpacity: false)
                .labelsHidden()
                .frame(height: 44)
                .padding(DesignBook.Spacing.md)
                .background(DesignBook.Color.Background.secondary)
                .cornerRadius(DesignBook.Size.smallCardCornerRadius)
        }
    }
    
    var suggestedColors: some View {
        VStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
            Text("Suggested Colors")
                .font(DesignBook.Font.caption)
                .foregroundColor(DesignBook.Color.Text.tertiary)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: DesignBook.Spacing.md) {
                ForEach(suggestedColorOptions.indices, id: \.self) { index in
                    colorOption(color: suggestedColorOptions[index], index: index)
                }
            }
        }
    }
    
    var suggestedColorOptions: [Color] {
        TeamDefaultColorGenerator.defaultColors
    }
    
    func colorOption(color: Color, index: Int) -> some View {
        Button {
            teamColor = color
        } label: {
            Circle()
                .fill(color)
                .frame(width: 44, height: 44)
                .overlay {
                    if isSuggestedColorSelected(index) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
        }
        .buttonStyle(.plain)
    }
    
    func isSuggestedColorSelected(_ index: Int) -> Bool {
        guard index < suggestedColorOptions.count else { return false }
        let suggestedColor = suggestedColorOptions[index]
        return isColorSelected(suggestedColor)
    }
    
    func isColorSelected(_ color: Color) -> Bool {
        // Compare colors by converting to UIColor and comparing components
        let uiColor1 = UIColor(teamColor)
        let uiColor2 = UIColor(color)
        
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        guard uiColor1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1),
              uiColor2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2) else {
            return false
        }
        
        return abs(r1 - r2) < 0.01 && abs(g1 - g2) < 0.01 && abs(b1 - b2) < 0.01
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
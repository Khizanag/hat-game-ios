//
//  TimerSettingsView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct TimerSettingsView: View {
    @Bindable var gameManager: GameManager
    @State private var selectedDuration: Int
    
    init(gameManager: GameManager) {
        self._gameManager = Bindable(gameManager)
        _selectedDuration = State(initialValue: gameManager.roundDuration)
    }
    
    var body: some View {
        ZStack {
            DesignBook.Color.Background.primary
                .ignoresSafeArea()
            
            VStack(spacing: DesignBook.Spacing.lg) {
                GameCard {
                    VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                        Text("Round timer")
                            .font(DesignBook.Font.title2)
                            .foregroundColor(DesignBook.Color.Text.primary)
                        
                        Text("Each team gets the same amount of time per turn. Choose how intense you want the round to be.")
                            .font(DesignBook.Font.body)
                            .foregroundColor(DesignBook.Color.Text.secondary)
                    }
                }
                .padding(.horizontal, DesignBook.Spacing.lg)
                .padding(.top, DesignBook.Spacing.lg)
                
                GameCard {
                    VStack(spacing: DesignBook.Spacing.md) {
                        HStack {
                            Text("Seconds per team")
                                .font(DesignBook.Font.headline)
                                .foregroundColor(DesignBook.Color.Text.primary)
                            
                            Spacer()
                            
                            Text("\(selectedDuration)s")
                                .font(DesignBook.Font.title2)
                                .foregroundColor(DesignBook.Color.Text.accent)
                        }
                        
                        Slider(value: Binding(
                            get: { Double(selectedDuration) },
                            set: { selectedDuration = Int($0) }
                        ), in: 30...120, step: 5)
                        .tint(DesignBook.Color.Text.accent)
                        
                        Stepper(value: $selectedDuration, in: 30...120, step: 5) {
                            Text("Tap or hold to adjust")
                                .font(DesignBook.Font.caption)
                                .foregroundColor(DesignBook.Color.Text.secondary)
                        }
                        
                        HStack(spacing: DesignBook.Spacing.md) {
                            TimerTag(title: "Sprint", range: "30-45s")
                            TimerTag(title: "Classic", range: "60s")
                            TimerTag(title: "Marathon", range: "90-120s")
                        }
                        .padding(.horizontal, -DesignBook.Spacing.md)
                    }
                }
                .padding(.horizontal, DesignBook.Spacing.lg)
                
                Spacer()
                
                PrimaryButton(title: "Continue") {
                    gameManager.roundDuration = selectedDuration
                    gameManager.state = .wordInput
                }
                .padding(.horizontal, DesignBook.Spacing.lg)
                .padding(.bottom, DesignBook.Spacing.lg)
            }
        }
    }
}

private struct TimerTag: View {
    let title: String
    let range: String
    
    var body: some View {
        VStack(spacing: DesignBook.Spacing.xs) {
            Text(title)
                .font(DesignBook.Font.captionBold)
                .foregroundColor(DesignBook.Color.Text.primary)
            Text(range)
                .font(DesignBook.Font.caption)
                .foregroundColor(DesignBook.Color.Text.secondary)
        }
        .padding(.vertical, DesignBook.Spacing.sm)
        .padding(.horizontal, DesignBook.Spacing.md)
        .background(DesignBook.Color.Background.secondary)
        .cornerRadius(DesignBook.Size.smallCardCornerRadius)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    TimerSettingsView(gameManager: GameManager())
}



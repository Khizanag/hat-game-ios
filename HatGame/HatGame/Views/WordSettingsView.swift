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
    @State private var selectedWordCount: Int
    
    init() {
        _selectedWordCount = State(initialValue: 10)
    }
    
    var body: some View {
        ZStack {
            DesignBook.Color.Background.primary
                .ignoresSafeArea()
            
            VStack(spacing: DesignBook.Spacing.lg) {
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
                
                GameCard {
                    VStack(spacing: DesignBook.Spacing.md) {
                        HStack {
                            Text("Words per player")
                                .font(DesignBook.Font.headline)
                                .foregroundColor(DesignBook.Color.Text.primary)
                            
                            Spacer()
                            
                            Text("\(selectedWordCount)")
                                .font(DesignBook.Font.title2)
                                .foregroundColor(DesignBook.Color.Text.accent)
                        }
                        
                        Slider(value: Binding(
                            get: { Double(selectedWordCount) },
                            set: { selectedWordCount = Int($0) }
                        ), in: 3...20, step: 1)
                        .tint(DesignBook.Color.Text.accent)
                        
                        Stepper(value: $selectedWordCount, in: 3...20) {
                            Text("Tap or hold to adjust")
                                .font(DesignBook.Font.caption)
                                .foregroundColor(DesignBook.Color.Text.secondary)
                        }
                        
                        HStack(spacing: DesignBook.Spacing.md) {
                            LegendTag(title: "Short & speedy", range: "3-7")
                            LegendTag(title: "Balanced", range: "8-12")
                            LegendTag(title: "Epic round", range: "13-20")
                        }
                    }
                }
                .padding(.horizontal, DesignBook.Spacing.lg)
                
                Spacer()
                
                PrimaryButton(title: "Continue") {
                    gameManager.wordsPerPlayer = selectedWordCount
                    navigator.push(.timerSettings)
                }
                .padding(.horizontal, DesignBook.Spacing.lg)
                .padding(.bottom, DesignBook.Spacing.lg)
            }
        }
    }
}

private struct LegendTag: View {
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
    NavigationView {
        Page.wordSettings.view()
    }
    .environment(GameManager())
}



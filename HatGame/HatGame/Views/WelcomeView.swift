//
//  WelcomeView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct WelcomeView: View {
    @Bindable var gameManager: GameManager
    
    var body: some View {
        ZStack {
            DesignBook.Color.Background.primary
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: DesignBook.Spacing.xl) {
                    Spacer()
                        .frame(height: DesignBook.Spacing.xxl)
                    
                    VStack(spacing: DesignBook.Spacing.md) {
                        Text("🎩")
                            .font(.system(size: 80))
                        
                        Text("Hat Game")
                            .font(DesignBook.Font.largeTitle)
                            .foregroundColor(DesignBook.Color.Text.primary)
                    }
                    
                    GameCard {
                        VStack(alignment: .leading, spacing: DesignBook.Spacing.lg) {
                            Text("How to Play")
                                .font(DesignBook.Font.title3)
                                .foregroundColor(DesignBook.Color.Text.primary)
                            
                            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                                InstructionRow(number: "1", text: "Create teams and add players")
                                InstructionRow(number: "2", text: "Each player adds words to the hat")
                                InstructionRow(number: "3", text: "Words are randomized")
                                InstructionRow(number: "4", text: "Round 1: No restrictions - guess as many as you can")
                                InstructionRow(number: "5", text: "Round 2: One word only to describe")
                                InstructionRow(number: "6", text: "Round 3: Gestures and miming only")
                                InstructionRow(number: "7", text: "Team with most points wins!")
                            }
                        }
                    }
                    .padding(.horizontal, DesignBook.Spacing.lg)
                    
                    VStack(spacing: DesignBook.Spacing.md) {
                        PrimaryButton(title: "Start Game") {
                            gameManager.state = .teamSetup
                        }
                        
                        SecondaryButton(title: "Developer Info") {
                            // TODO: Show developer info
                        }
                    }
                    .padding(.horizontal, DesignBook.Spacing.lg)
                    
                    Spacer()
                        .frame(height: DesignBook.Spacing.xl)
                }
            }
        }
    }
}

private struct InstructionRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: DesignBook.Spacing.md) {
            Text(number)
                .font(DesignBook.Font.bodyBold)
                .foregroundColor(DesignBook.Color.Text.accent)
                .frame(width: 24, height: 24)
                .background(DesignBook.Color.Text.accent.opacity(0.2))
                .cornerRadius(12)
            
            Text(text)
                .font(DesignBook.Font.body)
                .foregroundColor(DesignBook.Color.Text.secondary)
            
            Spacer()
        }
    }
}

#Preview {
    WelcomeView(gameManager: GameManager())
}


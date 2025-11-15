//
//  WelcomeView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct WelcomeView {
    @Environment(GameManager.self) private var gameManager
    @Environment(Navigator.self) private var navigator
}

// MARK: - View
extension WelcomeView: View {
    var body: some View {
        ZStack {
            backgroundLayer
            content
        }
    }
}

private extension WelcomeView {
    var backgroundLayer: some View {
        DesignBook.Color.Background.primary
            .ignoresSafeArea()
    }
    
    var content: some View {
        ScrollView {
            VStack(spacing: DesignBook.Spacing.xl) {
                header
                howToPlayCard
                actionButtons
                testModeCard
                Spacer()
                    .frame(height: DesignBook.Spacing.xl)
            }
        }
    }
    
    var header: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            Text("🎩")
                .font(.system(size: 80))
            
            Text("Hat Game")
                .font(DesignBook.Font.largeTitle)
                .foregroundColor(DesignBook.Color.Text.primary)
        }
    }
    
    var howToPlayCard: some View {
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
    }
    
    var actionButtons: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            PrimaryButton(title: "Start Game") {
                navigator.present(.teamSetup)
            }
            
            SecondaryButton(title: "Developer Info") {
                // TODO: Show developer info
            }
        }
        .padding(.horizontal, DesignBook.Spacing.lg)
    }
    
    var testModeCard: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
                Toggle(
                    isOn: Binding(
                        get: { gameManager.isTestMode },
                        set: { gameManager.setTestMode($0) }
                    )
                ) {
                    VStack(alignment: .leading, spacing: DesignBook.Spacing.xs) {
                        Text("Quick Test Mode")
                            .font(DesignBook.Font.headline)
                            .foregroundColor(DesignBook.Color.Text.primary)
                        
                        Text("Prefill teams, players, and sample words so you can explore the flow instantly. You can still edit everything after enabling it.")
                            .font(DesignBook.Font.body)
                            .foregroundColor(DesignBook.Color.Text.secondary)
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: DesignBook.Color.Text.accent))
            }
        }
        .padding(.horizontal, DesignBook.Spacing.lg)
    }
}

private struct InstructionRow {
    let number: String
    let text: String
}

// MARK: - View
extension InstructionRow: View {
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

// MARK: - Preview
#Preview {
    NavigationView {
        Page.welcome.view()
    }
    .environment(GameManager())
}


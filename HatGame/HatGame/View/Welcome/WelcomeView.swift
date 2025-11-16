//
//  WelcomeView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(AppConfiguration.self) private var appConfiguration
    @Environment(Navigator.self) private var navigator
    @SceneStorage("WelcomeView.isHowToPlayExpanded") private var isHowToPlayExpanded: Bool = true
    @SceneStorage("WelcomeView.isTestModeExpanded") private var isTestModeExpanded: Bool = true
    
    var body: some View {
        content
            .setDefaultBackground()
    }
}

private extension WelcomeView {
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
                .padding(.top, DesignBook.Spacing.md)
            
            Text("Hat Game")
                .font(DesignBook.Font.largeTitle)
                .foregroundColor(DesignBook.Color.Text.primary)
        }
    }
    
    var howToPlayCard: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                Button {
                    withAnimation(.easeInOut) {
                        isHowToPlayExpanded.toggle()
                    }
                } label: {
                    HStack {
                        Text("How to Play")
                            .font(DesignBook.Font.title3)
                            .foregroundColor(DesignBook.Color.Text.primary)
                        Spacer()
                        Image(systemName: isHowToPlayExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(DesignBook.Color.Text.secondary)
                    }
                }
                
                if isHowToPlayExpanded {
                    VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                        InstructionRow(number: "1", text: "Create teams and add players")
                        InstructionRow(number: "2", text: "Each player adds words to the hat")
                        InstructionRow(number: "3", text: "Words are randomized")
                        InstructionRow(number: "4", text: "Round 1: No restrictions - guess as many as you can")
                        InstructionRow(number: "5", text: "Round 2: One word only to describe")
                        InstructionRow(number: "6", text: "Round 3: Gestures and miming only")
                        InstructionRow(number: "7", text: "Team with most points wins!")
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
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
                navigator.push(.developerInfo)
            }
        }
        .padding(.horizontal, DesignBook.Spacing.lg)
    }
    
    var testModeCard: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
                Button {
                    withAnimation(.easeInOut) {
                        isTestModeExpanded.toggle()
                    }
                } label: {
                    HStack(alignment: .top) {
                        Text("Test Mode")
                            .font(DesignBook.Font.headline)
                            .foregroundColor(DesignBook.Color.Text.primary)
                        Spacer()
                        Image(systemName: isTestModeExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(DesignBook.Color.Text.secondary)
                    }
                }
                
                if isTestModeExpanded {
                    VStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
                        Toggle(
                            isOn: Binding(
                                get: { appConfiguration.isTestMode },
                                set: { handleTestModeChange($0) }
                            )
                        ) {
                            Text("Prefill teams, players, and sample words so you can explore the flow instantly. You can still edit everything after enabling it.")
                                .font(DesignBook.Font.body)
                                .foregroundColor(DesignBook.Color.Text.secondary)
                        }
                        .toggleStyle(SwitchToggleStyle(tint: DesignBook.Color.Text.accent))
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .padding(.horizontal, DesignBook.Spacing.lg)
    }
    
    func handleTestModeChange(_ enabled: Bool) {
        appConfiguration.isTestMode = enabled
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

// MARK: - Preview
#Preview {
    NavigationView {
        Page.welcome.view()
    }
    .environment(GameManager())
    .environment(AppConfiguration())
}
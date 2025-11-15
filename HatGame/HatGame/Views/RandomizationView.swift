//
//  RandomizationView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct RandomizationView {
    @Environment(GameManager.self) private var gameManager
    @Environment(Navigator.self) private var navigator
    @State private var isShuffling: Bool = false
    @State private var selectedStartingTeamIndex: Int = 0
}

// MARK: - View
extension RandomizationView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundLayer
                content
            }
            .navigationTitle("Randomize")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                navigationToolbar
            }
        }
    }
}

private extension RandomizationView {
    var backgroundLayer: some View {
        DesignBook.Color.Background.primary
            .ignoresSafeArea()
    }
    
    var content: some View {
        VStack(spacing: DesignBook.Spacing.xl) {
            Spacer()
            shuffleCard
            startingTeamSection
            Spacer()
        }
    }
    
    var shuffleCard: some View {
        GameCard {
            VStack(spacing: DesignBook.Spacing.lg) {
                if isShuffling {
                    shufflingContent
                } else {
                    readyContent
                }
            }
        }
        .padding(.horizontal, DesignBook.Spacing.lg)
    }
    
    var shufflingContent: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Shuffling words...")
                .font(DesignBook.Font.headline)
                .foregroundColor(DesignBook.Color.Text.secondary)
        }
        .frame(height: 200)
    }
    
    var readyContent: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            Text("🎲")
                .font(.system(size: 80))
            
            Text("Randomize Words")
                .font(DesignBook.Font.title2)
                .foregroundColor(DesignBook.Color.Text.primary)
            
            Text("\(gameManager.allWords.count) words ready")
                .font(DesignBook.Font.body)
                .foregroundColor(DesignBook.Color.Text.secondary)
        }
        .frame(height: 200)
    }
    
    @ViewBuilder
    var startingTeamSection: some View {
        if !isShuffling {
            VStack(spacing: DesignBook.Spacing.md) {
                startingTeamPickerCard
                shuffleButton
            }
        }
    }
    
    var startingTeamPickerCard: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                Text("Which team starts?")
                    .font(DesignBook.Font.headline)
                    .foregroundColor(DesignBook.Color.Text.primary)
                
                Picker("Starting Team", selection: $selectedStartingTeamIndex) {
                    ForEach(Array(gameManager.teams.enumerated()), id: \.offset) { index, team in
                        Text(team.name)
                            .tag(index)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
            }
        }
        .padding(.horizontal, DesignBook.Spacing.lg)
    }
    
    var shuffleButton: some View {
        PrimaryButton(title: "Shuffle & Start") {
            shuffleAndStart()
        }
        .padding(.horizontal, DesignBook.Spacing.lg)
    }
    
    @ToolbarContentBuilder
    var navigationToolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                navigator.dismiss()
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(DesignBook.Color.Text.primary)
            }
        }
    }
    
    func shuffleAndStart() {
        isShuffling = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            gameManager.shuffleWords()
            gameManager.startRound(.one, startingTeamIndex: selectedStartingTeamIndex)
            navigator.push(.playing(round: .one, currentTeamIndex: selectedStartingTeamIndex))
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        Page.randomization.view()
    }
    .environment(GameManager())
}


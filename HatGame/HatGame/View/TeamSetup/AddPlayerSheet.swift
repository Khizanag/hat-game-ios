//
//  AddPlayerSheet.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct AddPlayerSheet: View {
    @Binding var playerName: String
    let playersAddedProvider: () -> Int
    let playersPerTeam: Int
    let onAdd: () -> Void
    let onCancel: () -> Void
    
    private var playersAdded: Int {
        playersAddedProvider()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundLayer
                content
            }
            .navigationTitle("Add Player")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
    }
}

private extension AddPlayerSheet {
    var backgroundLayer: some View {
        DesignBook.Color.Background.primary
            .ignoresSafeArea()
    }
    
    var content: some View {
        VStack(spacing: DesignBook.Spacing.lg) {
            title
            nameField
                .padding(.top, DesignBook.Spacing.xl)
            Spacer()
            actionButtons
        }
    }
    
    var title: some View {
        Text("Player \(playersAdded + 1) of \(playersPerTeam)")
            .font(DesignBook.Font.headline)
            .foregroundColor(DesignBook.Color.Text.secondary)
    }
    
    var nameField: some View {
        TextField("Player Name", text: $playerName)
            .textFieldStyle(.plain)
            .font(DesignBook.Font.headline)
            .foregroundColor(DesignBook.Color.Text.primary)
            .padding(DesignBook.Spacing.lg)
            .background(DesignBook.Color.Background.card)
            .cornerRadius(DesignBook.Size.cardCornerRadius)
            .applyShadow(DesignBook.Shadow.medium)
            .padding(.horizontal, DesignBook.Spacing.lg)
    }
    
    var actionButtons: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            PrimaryButton(title: "Add Player") {
                onAdd()
            }
            .disabled(playerName.trimmingCharacters(in: .whitespaces).isEmpty || playersAdded >= playersPerTeam)
            
            SecondaryButton(title: "Cancel") {
                onCancel()
            }
        }
        .padding(.horizontal, DesignBook.Spacing.lg)
        .padding(.bottom, DesignBook.Spacing.lg)
    }
}


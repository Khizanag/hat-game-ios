//
//  TeamEditView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct TeamEditView: View {
    @Environment(GameManager.self) private var gameManager
    @Environment(Navigator.self) private var navigator

    let team: Team

    @State private var teamName: String = ""
    @State private var playerNames: [Player: String] = [:]

    private var trimmedTeamName: String {
        teamName.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var canSaveChanges: Bool {
        guard !trimmedTeamName.isEmpty else { return false }
        return team.players.allSatisfy { player in
            !currentName(for: player).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    
    var body: some View {
        content
            .setDefaultBackground()
            .navigationTitle("Edit group")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadDataIfNeeded()
            }
            .presentationDetents([.large])
    }
}

private extension TeamEditView {
    @ViewBuilder
    var content: some View {
        ScrollView {
            VStack(spacing: DesignBook.Spacing.lg) {
                teamNameCard
                playersCard
                actionSection
            }
            .padding(.horizontal, DesignBook.Spacing.lg)
            .padding(.top, DesignBook.Spacing.lg)
            .padding(.bottom, DesignBook.Spacing.lg)
        }
    }
    
    var teamNameCard: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                Text("Team name")
                    .font(DesignBook.Font.captionBold)
                    .foregroundColor(DesignBook.Color.Text.secondary)
                
                TextField("Team name", text: $teamName)
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
                Text("Players")
                    .font(DesignBook.Font.captionBold)
                    .foregroundColor(DesignBook.Color.Text.secondary)
                
                ForEach(team.players.enumerated(), id: \.offset) { (index, player) in
                    playerField(for: player, index: index)
                }
            }
        }
    }
    
    func playerField(for player: Player, index: Int?) -> some View {
        VStack(alignment: .leading, spacing: DesignBook.Spacing.xs) {
            if let index {
                Text("Player \(index + 1)")
                    .font(DesignBook.Font.caption)
                    .foregroundColor(DesignBook.Color.Text.secondary)
            }
            
            TextField("Player name", text: playerBinding(for: player))
                .textFieldStyle(.plain)
                .font(DesignBook.Font.body)
                .foregroundColor(DesignBook.Color.Text.primary)
                .padding(DesignBook.Spacing.md)
                .background(DesignBook.Color.Background.secondary)
                .cornerRadius(DesignBook.Size.smallCardCornerRadius)
        }
    }
    
    var actionSection: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            PrimaryButton(title: "Save changes") {
                handleSaveChanges()
                navigator.dismiss()
            }
            .disabled(!canSaveChanges)
            .opacity(canSaveChanges ? DesignBook.Opacity.enabled : DesignBook.Opacity.disabled)
            
            DestructiveButton(title: "Cancel") {
                navigator.dismiss()
            }
        }
    }
    
    var missingTeamView: some View {
        Text("Team not found")
            .font(DesignBook.Font.body)
            .foregroundColor(DesignBook.Color.Text.secondary)
    }
    
    func playerBinding(for player: Player) -> Binding<String> {
        Binding(
            get: { currentName(for: player) },
            set: { playerNames[player] = $0 }
        )
    }
    
    func currentName(for player: Player) -> String {
        playerNames[player] ?? player.name
    }
    
    func loadDataIfNeeded() {
        guard teamName.isEmpty else { return }
        teamName = team.name
        team.players.forEach { player in
            playerNames[player] = player.name
        }
    }
    
    func handleSaveChanges() {
        applyTeamNameChange()
        applyPlayerNameChanges()
    }
    
    func applyTeamNameChange() {
        guard !trimmedTeamName.isEmpty else { return }
//        gameManager.updateTeamName(team: team, name: trimmedTeamName)
    }
    
    func applyPlayerNameChanges() {
        team.players.forEach { player in
            let trimmedName = currentName(for: player).trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedName.isEmpty, trimmedName != player.name else { return }
//            gameManager.updatePlayerName(playerId: player.id, name: trimmedName)
        }
    }
}

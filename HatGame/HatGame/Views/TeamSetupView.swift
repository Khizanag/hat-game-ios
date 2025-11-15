//
//  TeamSetupView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct TeamSetupView: View {
    @Bindable var gameManager: GameManager
    @State private var newTeamName: String = ""
    @State private var showingAddPlayer: Bool = false
    @State private var selectedTeamId: UUID?
    @State private var newPlayerName: String = ""
    
    private var canContinue: Bool {
        gameManager.teams.count >= 2 && gameManager.teams.allSatisfy { !$0.players.isEmpty }
    }
    
    var body: some View {
        ZStack {
            DesignBook.Color.Background.primary
                .ignoresSafeArea()
            
            VStack(spacing: DesignBook.Spacing.lg) {
                GameCard {
                    VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                        Text("Setup Teams")
                            .font(DesignBook.Font.title2)
                            .foregroundColor(DesignBook.Color.Text.primary)
                        
                        Text("Create teams and add players to each team")
                            .font(DesignBook.Font.body)
                            .foregroundColor(DesignBook.Color.Text.secondary)
                    }
                }
                .padding(.horizontal, DesignBook.Spacing.lg)
                .padding(.top, DesignBook.Spacing.lg)
                
                ScrollView {
                    VStack(spacing: DesignBook.Spacing.md) {
                        ForEach(gameManager.teams) { team in
                            TeamCard(
                                team: team,
                                gameManager: gameManager,
                                onAddPlayer: {
                                    selectedTeamId = team.id
                                    showingAddPlayer = true
                                },
                                onRemoveTeam: {
                                    gameManager.removeTeam(team.id)
                                }
                            )
                        }
                        
                        if gameManager.teams.count < 6 {
                            AddTeamCard(
                                teamName: $newTeamName,
                                onAdd: {
                                    guard !newTeamName.isEmpty else { return }
                                    gameManager.addTeam(name: newTeamName)
                                    newTeamName = ""
                                }
                            )
                        }
                    }
                    .padding(.horizontal, DesignBook.Spacing.lg)
                }
                
                PrimaryButton(title: "Continue") {
                    gameManager.state = .wordInput
                }
                .padding(.horizontal, DesignBook.Spacing.lg)
                .padding(.bottom, DesignBook.Spacing.sm)
                .disabled(!canContinue)
                .opacity(canContinue ? 1 : 0.4)
                
                if !canContinue {
                    Text("Add at least two teams and one player in each team to continue.")
                        .font(DesignBook.Font.caption)
                        .foregroundColor(DesignBook.Color.Text.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DesignBook.Spacing.lg)
                        .padding(.bottom, DesignBook.Spacing.lg)
                } else {
                    Spacer()
                        .frame(height: DesignBook.Spacing.lg)
                }
            }
        }
        .sheet(isPresented: $showingAddPlayer) {
            AddPlayerSheet(
                playerName: $newPlayerName,
                onAdd: {
                    guard let teamId = selectedTeamId, !newPlayerName.isEmpty else { return }
                    gameManager.addPlayer(name: newPlayerName, to: teamId)
                    newPlayerName = ""
                    showingAddPlayer = false
                },
                onCancel: {
                    newPlayerName = ""
                    showingAddPlayer = false
                }
            )
        }
    }
}

private struct TeamCard: View {
    let team: Team
    @Bindable var gameManager: GameManager
    let onAddPlayer: () -> Void
    let onRemoveTeam: () -> Void
    
    var body: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                HStack {
                    Text(team.name)
                        .font(DesignBook.Font.headline)
                        .foregroundColor(DesignBook.Color.Team.color(for: gameManager.teams.firstIndex(where: { $0.id == team.id }) ?? 0))
                    
                    Spacer()
                    
                    Button(action: onRemoveTeam) {
                        Image(systemName: "trash")
                            .foregroundColor(DesignBook.Color.Status.error)
                            .font(DesignBook.Font.body)
                    }
                }
                
                VStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
                    ForEach(team.players) { player in
                        HStack {
                            Circle()
                                .fill(DesignBook.Color.Team.color(for: gameManager.teams.firstIndex(where: { $0.id == team.id }) ?? 0))
                                .frame(width: 8, height: 8)
                            
                            Text(player.name)
                                .font(DesignBook.Font.body)
                                .foregroundColor(DesignBook.Color.Text.secondary)
                        }
                    }
                }
                
                Button(action: onAddPlayer) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Player")
                    }
                    .font(DesignBook.Font.body)
                    .foregroundColor(DesignBook.Color.Text.accent)
                }
            }
        }
    }
}

private struct AddTeamCard: View {
    @Binding var teamName: String
    let onAdd: () -> Void
    
    var body: some View {
        GameCard {
            HStack {
                TextField("Team Name", text: $teamName)
                    .textFieldStyle(.plain)
                    .font(DesignBook.Font.body)
                    .foregroundColor(DesignBook.Color.Text.primary)
                    .padding(DesignBook.Spacing.md)
                    .background(DesignBook.Color.Background.secondary)
                    .cornerRadius(DesignBook.Size.smallCardCornerRadius)
                
                Button(action: onAdd) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(DesignBook.Color.Button.primary)
                }
            }
        }
    }
}

private struct AddPlayerSheet: View {
    @Binding var playerName: String
    let onAdd: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignBook.Color.Background.primary
                    .ignoresSafeArea()
                
                VStack(spacing: DesignBook.Spacing.lg) {
                    TextField("Player Name", text: $playerName)
                        .textFieldStyle(.plain)
                        .font(DesignBook.Font.headline)
                        .foregroundColor(DesignBook.Color.Text.primary)
                        .padding(DesignBook.Spacing.lg)
                        .background(DesignBook.Color.Background.card)
                        .cornerRadius(DesignBook.Size.cardCornerRadius)
                        .applyShadow(DesignBook.Shadow.medium)
                        .padding(.horizontal, DesignBook.Spacing.lg)
                        .padding(.top, DesignBook.Spacing.xl)
                    
                    Spacer()
                    
                    VStack(spacing: DesignBook.Spacing.md) {
                        PrimaryButton(title: "Add Player") {
                            onAdd()
                        }
                        
                        SecondaryButton(title: "Cancel") {
                            onCancel()
                        }
                    }
                    .padding(.horizontal, DesignBook.Spacing.lg)
                    .padding(.bottom, DesignBook.Spacing.lg)
                }
            }
            .navigationTitle("Add Player")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    TeamSetupView(gameManager: GameManager())
}


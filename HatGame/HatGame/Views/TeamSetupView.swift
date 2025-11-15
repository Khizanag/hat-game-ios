//
//  TeamSetupView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct TeamSetupView {
    @Environment(GameManager.self) private var gameManager
    @Environment(Navigator.self) private var navigator
    @State private var newTeamName: String = ""
    @State private var showingAddPlayer: Bool = false
    @State private var selectedTeamId: UUID?
    @State private var editingTeamId: UUID?
    @State private var newPlayerName: String = ""
    @State private var teamToDelete: UUID?

    private let playersPerTeam = 2

    private var canContinue: Bool {
        gameManager.teams.count >= 2 && gameManager.teams.allSatisfy { $0.players.count == playersPerTeam }
    }

    private var selectedTeamPlayersCount: Int {
        guard let id = selectedTeamId else { return 0 }
        return gameManager.teams.first(where: { $0.id == id })?.players.count ?? 0
    }

}

// MARK: - View
extension TeamSetupView: View {
    var body: some View {
        ZStack {
            backgroundLayer
            content
        }
        .navigationTitle("Setup Teams")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            navigationToolbar
        }
        .sheet(isPresented: $showingAddPlayer) {
            addPlayerSheet
        }
        .sheet(isPresented: editTeamBinding) {
            editTeamSheet
        }
        .alert("Delete Team", isPresented: deleteAlertBinding) {
            deleteTeamAlertActions
        } message: {
            deleteTeamAlertMessage
        }
    }
}

private extension TeamSetupView {
    var backgroundLayer: some View {
        DesignBook.Color.Background.primary
            .ignoresSafeArea()
    }
    
    var content: some View {
        VStack(spacing: DesignBook.Spacing.lg) {
            headerCard
            teamsList
            continueSection
        }
    }
    
    var headerCard: some View {
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
    }
    
    var teamsList: some View {
        ScrollView {
            VStack(spacing: DesignBook.Spacing.md) {
                ForEach(gameManager.teams) { team in
                    TeamCard(
                        team: team,
                        playersPerTeam: playersPerTeam,
                        gameManager: gameManager,
                        onAddPlayer: {
                            selectedTeamId = team.id
                            showingAddPlayer = true
                        },
                        onRemoveTeam: {
                            teamToDelete = team.id
                        },
                        onEditTeam: {
                            editingTeamId = team.id
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
    }
    
    var continueSection: some View {
        VStack(spacing: DesignBook.Spacing.sm) {
            PrimaryButton(title: "Continue") {
                navigator.push(.wordSettings)
            }
            .padding(.horizontal, DesignBook.Spacing.lg)
            .disabled(!canContinue)
            .opacity(canContinue ? 1 : 0.4)
            
            if !canContinue {
                requirementText
            }
        }
        .padding(.bottom, DesignBook.Spacing.lg)
    }
    
    var requirementText: some View {
        Text("Add at least two teams and make sure each team has exactly two players to continue.")
            .font(DesignBook.Font.caption)
            .foregroundColor(DesignBook.Color.Text.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, DesignBook.Spacing.lg)
    }
    
    @ToolbarContentBuilder
    var navigationToolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                navigator.dismissPresented()
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(DesignBook.Color.Text.primary)
            }
        }
    }
    
    var addPlayerSheet: some View {
        AddPlayerSheet(
            playerName: $newPlayerName,
            playersAddedProvider: { selectedTeamPlayersCount },
            playersPerTeam: playersPerTeam,
            onAdd: {
                handleAddPlayer()
            },
            onCancel: {
                handleCancelAddPlayer()
            }
        )
    }
    
    var editTeamBinding: Binding<Bool> {
        Binding(
            get: { editingTeamId != nil },
            set: { if !$0 { editingTeamId = nil } }
        )
    }
    
    @ViewBuilder
    var editTeamSheet: some View {
        if let teamId = editingTeamId {
            TeamEditView(teamId: teamId)
        }
    }
    
    var deleteAlertBinding: Binding<Bool> {
        Binding(
            get: { teamToDelete != nil },
            set: { if !$0 { teamToDelete = nil } }
        )
    }
    
    @ViewBuilder
    var deleteTeamAlertActions: some View {
        Button("Cancel", role: .cancel) {
            teamToDelete = nil
        }
        Button("Delete", role: .destructive) {
            if let teamId = teamToDelete {
                gameManager.removeTeam(teamId)
                teamToDelete = nil
            }
        }
    }
    
    @ViewBuilder
    var deleteTeamAlertMessage: some View {
        if let teamId = teamToDelete,
           let team = gameManager.teams.first(where: { $0.id == teamId }) {
            Text("Are you sure you want to delete \"\(team.name)\"? This action cannot be undone.")
        }
    }
    
    func handleAddPlayer() {
        guard let teamId = selectedTeamId, !newPlayerName.isEmpty else { return }
        gameManager.addPlayer(name: newPlayerName, to: teamId, limit: playersPerTeam)
        newPlayerName = ""
        
        if selectedTeamPlayersCount >= playersPerTeam {
            showingAddPlayer = false
            selectedTeamId = nil
        }
    }
    
    func handleCancelAddPlayer() {
        newPlayerName = ""
        showingAddPlayer = false
        selectedTeamId = nil
    }
}

private struct TeamCard {
    let team: Team
    let playersPerTeam: Int
    @Bindable var gameManager: GameManager
    let onAddPlayer: () -> Void
    let onRemoveTeam: () -> Void
    let onEditTeam: () -> Void
}

// MARK: - View
extension TeamCard: View {
    var body: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                header
                playersList
                actions
            }
        }
    }
}

private extension TeamCard {
    var teamColor: Color {
        DesignBook.Color.Team.color(
            for: gameManager.teams.firstIndex(where: { $0.id == team.id }) ?? 0
        )
    }
    
    var header: some View {
        HStack {
            Text(team.name)
                .font(DesignBook.Font.headline)
                .foregroundColor(teamColor)
            
            Spacer()
            
            Text("\(team.players.count)/\(playersPerTeam)")
                .font(DesignBook.Font.captionBold)
                .foregroundColor(DesignBook.Color.Text.secondary)
        }
    }
    
    var playersList: some View {
        VStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
            ForEach(team.players) { player in
                HStack {
                    Circle()
                        .fill(teamColor)
                        .frame(width: 8, height: 8)
                    
                    Text(player.name)
                        .font(DesignBook.Font.body)
                        .foregroundColor(DesignBook.Color.Text.secondary)
                }
            }
        }
    }
    
    var actions: some View {
        HStack {
            addPlayerButton
            Spacer()
            editButton
            deleteButton
        }
    }
    
    var addPlayerButton: some View {
        Button(action: onAddPlayer) {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text(team.players.count < playersPerTeam ? "Add Player" : "Team is full")
            }
            .font(DesignBook.Font.body)
            .foregroundColor(team.players.count < playersPerTeam ? DesignBook.Color.Text.accent : DesignBook.Color.Text.tertiary)
        }
        .disabled(team.players.count >= playersPerTeam)
    }
    
    var editButton: some View {
        Button(action: onEditTeam) {
            Image(systemName: "pencil.circle")
                .foregroundColor(DesignBook.Color.Text.accent)
                .font(DesignBook.Font.body)
        }
    }
    
    var deleteButton: some View {
        Button(action: onRemoveTeam) {
            Image(systemName: "trash")
                .foregroundColor(DesignBook.Color.Status.error)
                .font(DesignBook.Font.body)
        }
    }
}

private struct AddTeamCard {
    @Binding var teamName: String
    let onAdd: () -> Void
}

// MARK: - View
extension AddTeamCard: View {
    var body: some View {
        GameCard {
            HStack {
                teamNameField
                addButton
            }
        }
    }
}

private extension AddTeamCard {
    var teamNameField: some View {
        TextField("Team Name", text: $teamName)
            .textFieldStyle(.plain)
            .font(DesignBook.Font.body)
            .foregroundColor(DesignBook.Color.Text.primary)
            .padding(DesignBook.Spacing.md)
            .background(DesignBook.Color.Background.secondary)
            .cornerRadius(DesignBook.Size.smallCardCornerRadius)
    }
    
    var addButton: some View {
        Button(action: onAdd) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 32))
                .foregroundColor(DesignBook.Color.Button.primary)
        }
    }
}

private struct AddPlayerSheet {
    @Binding var playerName: String
    let playersAddedProvider: () -> Int
    let playersPerTeam: Int
    let onAdd: () -> Void
    let onCancel: () -> Void

    private var playersAdded: Int {
        playersAddedProvider()
    }

}

// MARK: - View
extension AddPlayerSheet: View {
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

// MARK: - Preview
#Preview {
    NavigationView {
        Page.teamSetup.view()
    }
    .environment(GameManager())
}

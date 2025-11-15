//
//  TeamSetupView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct TeamSetupView: View {
    @Environment(GameManager.self) private var gameManager
    @Environment(Navigator.self) private var navigator

    @State private var isAddTeamSheetPresented: Bool = false
    @State private var newTeamName: String = ""
    @State private var showingAddPlayer: Bool = false
    @State private var selectedTeamId: UUID?
    @State private var editingTeamId: UUID?
    @State private var newPlayerName: String = ""
    @State private var teamToDelete: UUID?

    private let playersPerTeam = 2

    private var canContinue: Bool {
        gameManager.teams.count >= 2 && gameManager.teams.allSatisfy {
            $0.players.count == playersPerTeam
        }
    }

    private var selectedTeamPlayersCount: Int {
        guard let id = selectedTeamId else { return 0 }
        return gameManager.teams.first(where: { $0.id == id })?.players.count ?? 0
    }

    var body: some View {
        content
            .background(
                DesignBook.Color.Background.primary
                    .ignoresSafeArea()
            )
            .navigationTitle("Setup Teams")
            .navigationBarTitleDisplayMode(.inline)
            .closeButtonToolbar()
            .sheet(isPresented: $isAddTeamSheetPresented) {
                AddTeamSheet(
                    playersPerTeam: playersPerTeam,
                    onCreateTeam: { name, players in
                        gameManager.addTeam(name: name)
                        guard let teamId = gameManager.teams.last?.id else { return }
                        players.forEach { playerName in
                            gameManager.addPlayer(name: playerName, to: teamId)
                        }
                    }
                )
            }
            .sheet(isPresented: $showingAddPlayer) {
                addPlayerSheet
            }
            .sheet(isPresented: editTeamBinding) {
                editTeamSheet
            }
            .alert("Delete Team", isPresented: isDeleteTeamAlertPresented) {
                deleteTeamAlertActions
            } message: {
                deleteTeamAlertMessage
            }
    }
}

private extension TeamSetupView {
    var content: some View {
        ScrollView {
            VStack(spacing: DesignBook.Spacing.lg) {
                headerCard
                teamsList
                continueSection
            }
            .padding(.horizontal, DesignBook.Spacing.lg)
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
        VStack(spacing: DesignBook.Spacing.md) {
            ForEach(gameManager.teams) { team in
                TeamCard(
                    team: team,
                    playersPerTeam: playersPerTeam,
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
                Button {
                    newTeamName = ""
                    isAddTeamSheetPresented = true
                } label: {
                    HStack(spacing: DesignBook.Spacing.sm) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Team")
                    }
                    .font(DesignBook.Font.body)
                    .foregroundColor(DesignBook.Color.Text.accent)
                    .frame(maxWidth: .infinity)
                    .padding(DesignBook.Spacing.md)
                    .background(DesignBook.Color.Background.secondary)
                    .cornerRadius(DesignBook.Size.smallCardCornerRadius)
                }
            }
        }
    }

    var continueSection: some View {
        VStack(spacing: DesignBook.Spacing.sm) {
            PrimaryButton(title: "Continue") {
                navigator.push(.wordSettings)
            }
            .disabled(!canContinue)
            .opacity(canContinue ? DesignBook.Opacity.enabled : DesignBook.Opacity.disabled)

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

    var isDeleteTeamAlertPresented: Binding<Bool> {
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

// MARK: - Preview
#Preview {
    NavigationView {
        Page.teamSetup.view()
    }
    .environment(GameManager())
}

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
    @State private var selectedTeam: Team?
    @State private var editingTeam: Team?
    @State private var newPlayerName: String = ""
    @State private var deletingTeam: Team?

    private let playersPerTeam = 2

    private var canContinue: Bool {
        gameManager.configuration.teams.count >= gameManager.configuration.maxTeams
    }

    var body: some View {
        content
            .setDefaultStyle(title: "Setup Teams")
            .sheet(isPresented: $isAddTeamSheetPresented) {
                NavigationView {
                    AddTeamView(
                        playersPerTeam: playersPerTeam,
                        onTeamCreate: { team in
                            gameManager.addTeam(team)
                        }
                    )
                }
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
            }
            .padding(.horizontal, DesignBook.Spacing.lg)
        }
        .safeAreaInset(edge: .bottom) {
            continueSection
                .padding(.horizontal, DesignBook.Spacing.lg)
        }
    }

    var headerCard: some View {
        HeaderCard(
            title: "Setup Teams",
            description: "Create teams and add players to each team"
        )
    }

    var teamsList: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            ForEach(gameManager.configuration.teams) { team in
                TeamCard(
                    team: team,
                    playersPerTeam: playersPerTeam,
                    onAddPlayer: {
                        selectedTeam = team
                    },
                    onRemoveTeam: {
                        deletingTeam = team
                    },
                    onEditTeam: {
                        editingTeam = team
                    }
                )
            }
            
            if gameManager.configuration.teams.count < 6 {
                SecondaryButton(title: "Add Team") {
                    newTeamName = ""
                    isAddTeamSheetPresented = true
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
    }

    var requirementText: some View {
        Text("Add at least two teams and make sure each team has exactly two players to continue.")
            .font(DesignBook.Font.caption)
            .foregroundColor(DesignBook.Color.Text.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, DesignBook.Spacing.lg)
    }

    var editTeamBinding: Binding<Bool> {
        Binding(
            get: { editingTeam != nil },
            set: { if !$0 { editingTeam = nil } }
        )
    }

    @ViewBuilder
    var editTeamSheet: some View {
        if let team = editingTeam {
            NavigationView {
                TeamEditView(team: team)
            }
        }
    }

    var isDeleteTeamAlertPresented: Binding<Bool> {
        Binding(
            get: { deletingTeam != nil },
            set: { if !$0 { deletingTeam = nil } }
        )
    }

    @ViewBuilder
    var deleteTeamAlertActions: some View {
        Button("Cancel", role: .cancel) {
            deletingTeam = nil
        }
        Button("Delete", role: .destructive) {
            if let deletingTeam {
                gameManager.removeTeamById(deletingTeam.id)
                self.deletingTeam = nil
            }
        }
    }

    @ViewBuilder
    var deleteTeamAlertMessage: some View {
        if let deletingTeam {
            Text("Are you sure you want to delete \"\(deletingTeam.name)\"? This action cannot be undone.")
        }
    }

    func handleCancelAddPlayer() {
        newPlayerName = ""
        selectedTeam = nil
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        Page.teamSetup.view()
    }
    .environment(GameManager())
}
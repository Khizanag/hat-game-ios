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
    private let appConfiguration = AppConfiguration.shared

    @State private var isAddTeamSheetPresented: Bool = false
    @State private var newTeamName: String = ""
    @State private var showingAddPlayer: Bool = false
    @State private var selectedTeam: Team?
    @State private var editingTeam: Team?
    @State private var newPlayerName: String = ""
    @State private var deletingTeam: Team?

    private var canContinue: Bool {
        (gameManager.configuration.minTeams...gameManager.configuration.maxTeams)
            .contains(gameManager.configuration.teams.count)
    }

    // MARK: - Body
    var body: some View {
        content
            .setDefaultStyle(title: String(localized: "Setup Teams"))
            .sheet(isPresented: $isAddTeamSheetPresented) {
                NavigationView {
                    AddTeamView(
                        onTeamCreate: { team in
                            gameManager.addTeam(team)
                        }
                    )
                }
            }
            .sheet(isPresented: editTeamBinding) {
                editTeamSheet
            }
            .alert(String(localized: "teamSetup.deleteTeam.title"), isPresented: isDeleteTeamAlertPresented) {
                deleteTeamAlertActions
            } message: {
                deleteTeamAlertMessage
            }
    }
}

// MARK: - Private
private extension TeamSetupView {
    var content: some View {
        ScrollView {
            VStack(spacing: DesignBook.Spacing.lg) {
                headerCard
                teamsList
            }
            .paddingHorizontalDefault()
        }
        .safeAreaInset(edge: .bottom) {
            continueSection
                .paddingHorizontalDefault()
        }
    }

    var headerCard: some View {
        HeaderCard(
            title: String(localized: "Setup Teams"),
            description: String(localized: "Create teams and add players to each team")
        )
    }

    var teamsList: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            ForEach(gameManager.configuration.teams) { team in
                TeamCard(
                    team: team,
                    playersPerTeam: gameManager.configuration.maxTeamMembers,
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
                SecondaryButton(title: String(localized: "Add Team")) {
                    newTeamName = ""
                    isAddTeamSheetPresented = true
                }
            }
        }
    }

    var continueSection: some View {
        VStack(spacing: DesignBook.Spacing.sm) {
            PrimaryButton(title: String(localized: "Continue"), icon: "arrow.right.circle.fill") {
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
        Text(String(format: String(localized: "teamSetup.minTeamsRequired"), gameManager.configuration.minTeams))
            .font(DesignBook.Font.caption)
            .foregroundColor(DesignBook.Color.Text.secondary)
            .multilineTextAlignment(.center)
            .paddingHorizontalDefault()
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
                gameManager.removeTeam(deletingTeam)
                self.deletingTeam = nil
            }
        }
    }

    @ViewBuilder
    var deleteTeamAlertMessage: some View {
        if let deletingTeam {
            Text(String(format: String(localized: "Are you sure you want to delete \"%@\"? This action cannot be undone."), deletingTeam.name))
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

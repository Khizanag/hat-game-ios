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
    @State private var editingTeam: Team?
    @State private var deletingTeam: Team?
    @State private var editMode: EditMode = .inactive

    private var isEditMode: Bool { editMode == .active }

    private var canContinue: Bool {
        (gameManager.configuration.minTeams...gameManager.configuration.maxTeams)
            .contains(gameManager.configuration.teams.count)
    }

    // MARK: - Body
    var body: some View {
        content
            .environment(\.editMode, $editMode)
            .setDefaultStyle(title: String(localized: "teamSetup.title"))
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
        VStack(spacing: 0) {
            List {
                Section {
                    headerCard
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }

                Section {
                    if gameManager.configuration.teams.count > 1 {
                        HStack {
                            Spacer()
                            editModeButton
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }

                    ForEach(gameManager.configuration.teams) { team in
                        TeamCard(
                            team: team,
                            playersPerTeam: gameManager.configuration.playersPerTeam,
                            onRemoveTeam: {
                                deletingTeam = team
                            },
                            onEditTeam: {
                                editingTeam = team
                            },
                            isEditMode: isEditMode
                        )
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                deletingTeam = team
                            } label: {
                                Label(String(localized: "teamCard.delete"), systemImage: "trash")
                            }

                            Button {
                                editingTeam = team
                            } label: {
                                Label(String(localized: "teamCard.edit"), systemImage: "pencil")
                            }
                            .tint(DesignBook.Color.Text.accent)
                        }
                    }
                    .onMove { source, destination in
                        withAnimation {
                            gameManager.moveTeam(from: source, to: destination)
                        }
                    }

                    if !isEditMode, gameManager.configuration.teams.count < 6 {
                        SecondaryButton(title: String(localized: "teamSetup.addTeam"), icon: "plus.circle.fill") {
                            isAddTeamSheetPresented = true
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .paddingHorizontalDefault()

            continueSection
                .paddingHorizontalDefault()
                .withFooterGradient()
        }
    }

    var headerCard: some View {
        HeaderCard(
            title: String(localized: "teamSetup.title"),
            description: String(localized: "teamSetup.description")
        )
    }

    var continueSection: some View {
        VStack(spacing: DesignBook.Spacing.sm) {
            PrimaryButton(title: String(localized: "common.buttons.continue"), icon: "arrow.right.circle.fill") {
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
        Button(String(localized: "common.buttons.cancel"), role: .cancel) {
            deletingTeam = nil
        }
        Button(String(localized: "teamSetup.deleteTeam.title"), role: .destructive) {
            if let deletingTeam {
                gameManager.removeTeam(deletingTeam)
                self.deletingTeam = nil
            }
        }
    }

    @ViewBuilder
    var deleteTeamAlertMessage: some View {
        if let deletingTeam {
            Text(String(format: String(localized: "teamSetup.deleteTeam.confirmation"), deletingTeam.name))
        }
    }

    var editModeButton: some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                editMode = editMode == .active ? .inactive : .active
            }
        } label: {
            HStack(spacing: DesignBook.Spacing.xs) {
                Image(systemName: isEditMode ? "checkmark.circle.fill" : "slider.horizontal.3")
                    .font(DesignBook.Font.body)
                Text(isEditMode ? String(localized: "common.buttons.done") : String(localized: "common.buttons.edit"))
                    .font(DesignBook.Font.bodyBold)
            }
            .foregroundColor(isEditMode ? DesignBook.Color.Status.success : DesignBook.Color.Text.accent)
            .padding(.horizontal, DesignBook.Spacing.md)
            .padding(.vertical, DesignBook.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DesignBook.Size.smallCardCornerRadius)
                    .fill(isEditMode ? DesignBook.Color.Status.success.opacity(DesignBook.Opacity.veryLight) : DesignBook.Color.Background.secondary)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        Page.teamSetup.view()
    }
    .environment(GameManager())
}

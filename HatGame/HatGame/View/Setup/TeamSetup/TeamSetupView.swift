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

    private var canContinue: Bool {
        (gameManager.configuration.minTeams...gameManager.configuration.maxTeams)
            .contains(gameManager.configuration.teams.count)
    }

    // MARK: - Body
    var body: some View {
        content
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
        ScrollView {
            VStack(spacing: DesignBook.Spacing.lg) {
                headerCard
                playerCountCard
                teamsList
            }
            .paddingHorizontalDefault()
        }
        .safeAreaInset(edge: .bottom) {
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

    var playerCountCard: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                HStack(spacing: DesignBook.Spacing.sm) {
                    Image(systemName: "person.2.fill")
                        .font(DesignBook.IconFont.medium)
                        .foregroundColor(DesignBook.Color.Text.accent)

                    Text("teamSetup.playersPerTeam.title")
                        .font(DesignBook.Font.headline)
                        .foregroundColor(DesignBook.Color.Text.primary)

                    Spacer()
                }

                Text("teamSetup.playersPerTeam.description")
                    .font(DesignBook.Font.caption)
                    .foregroundColor(DesignBook.Color.Text.secondary)

                HStack(spacing: DesignBook.Spacing.sm) {
                    ForEach(gameManager.configuration.minTeamMembers...gameManager.configuration.maxTeamMembers, id: \.self) { count in
                        playerCountOption(count)
                    }
                }
            }
            .padding(DesignBook.Spacing.md)
        }
    }

    func playerCountOption(_ count: Int) -> some View {
        Button {
            gameManager.configuration.playersPerTeam = count
        } label: {
            Text("\(count)")
                .font(DesignBook.Font.headline)
                .foregroundColor(gameManager.configuration.playersPerTeam == count ? .white : DesignBook.Color.Text.primary)
                .frame(maxWidth: .infinity)
                .padding(DesignBook.Spacing.md)
                .background(gameManager.configuration.playersPerTeam == count ? DesignBook.Color.Text.accent : DesignBook.Color.Background.secondary)
                .cornerRadius(DesignBook.Size.smallCardCornerRadius)
        }
        .buttonStyle(.plain)
    }

    var teamsList: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            ForEach(gameManager.configuration.teams) { team in
                TeamCard(
                    team: team,
                    playersPerTeam: gameManager.configuration.playersPerTeam,
                    onRemoveTeam: {
                        deletingTeam = team
                    },
                    onEditTeam: {
                        editingTeam = team
                    }
                )
            }

            if gameManager.configuration.teams.count < 6 {
                SecondaryButton(title: String(localized: "teamSetup.addTeam"), icon: "plus.circle.fill") {
                    isAddTeamSheetPresented = true
                }
            }
        }
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
}

// MARK: - Preview
#Preview {
    NavigationView {
        Page.teamSetup.view()
    }
    .environment(GameManager())
}

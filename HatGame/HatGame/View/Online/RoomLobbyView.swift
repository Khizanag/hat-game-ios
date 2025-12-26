//
//  RoomLobbyView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 22.12.24.
//

import SwiftUI
import DesignBook
import Navigation
import Networking

struct RoomLobbyView: View {
    @Environment(Navigator.self) private var navigator
    @Environment(RoomManager.self) private var roomManager

    @State private var showingTeamCreation: Bool = false
    @State private var error: Error?

    private var room: GameRoom? {
        roomManager.room
    }

    private var isHost: Bool {
        roomManager.isHost
    }

    private var canStartGame: Bool {
        guard let room else { return false }
        return room.teams.count >= 2 &&
               room.teams.allSatisfy { team in
                   room.players.filter { $0.teamId == team.id }.count >= 2
               }
    }

    var body: some View {
        content
            .navigationTitle(String(localized: "lobby.title"))
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        leaveRoom()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(DesignBook.Color.Text.secondary)
                    }
                }
            }
            .setDefaultBackground()
            .sheet(isPresented: $showingTeamCreation) {
                OnlineTeamCreationView()
            }
            .alert("common.error", isPresented: .init(
                get: { error != nil },
                set: { if !$0 { error = nil } }
            )) {
                Button("common.ok") {
                    error = nil
                }
            } message: {
                Text(error?.localizedDescription ?? "")
            }
    }
}

// MARK: - Private
private extension RoomLobbyView {
    var content: some View {
        ScrollView {
            VStack(spacing: DesignBook.Spacing.lg) {
                roomCodeCard
                playersCard
                teamsSection
            }
            .paddingHorizontalDefault()
            .padding(.top, DesignBook.Spacing.lg)
            .padding(.bottom, DesignBook.Spacing.xxl)
        }
        .safeAreaInset(edge: .bottom) {
            actionButtons
                .withFooterGradient()
        }
    }

    var roomCodeCard: some View {
        GameCard {
            VStack(spacing: DesignBook.Spacing.md) {
                Text("lobby.shareCode")
                    .font(DesignBook.Font.caption)
                    .foregroundColor(DesignBook.Color.Text.secondary)

                Text(room?.id ?? "------")
                    .font(.system(size: 40, weight: .bold, design: .monospaced))
                    .foregroundColor(DesignBook.Color.Text.primary)
                    .kerning(8)

                Button {
                    UIPasteboard.general.string = room?.id
                } label: {
                    HStack(spacing: DesignBook.Spacing.xs) {
                        Image(systemName: "doc.on.doc")
                        Text("lobby.copyCode")
                    }
                    .font(DesignBook.Font.caption)
                    .foregroundColor(DesignBook.Color.Text.accent)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    var playersCard: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                HStack(spacing: DesignBook.Spacing.sm) {
                    Image(systemName: "person.3.fill")
                        .font(DesignBook.IconFont.medium)
                        .foregroundColor(DesignBook.Color.Text.accent)

                    Text("lobby.players")
                        .font(DesignBook.Font.captionBold)
                        .foregroundColor(DesignBook.Color.Text.secondary)

                    Spacer()

                    Text("\(room?.players.count ?? 0)")
                        .font(DesignBook.Font.captionBold)
                        .foregroundColor(DesignBook.Color.Text.tertiary)
                }

                if let players = room?.players {
                    ForEach(players) { player in
                        playerRow(player)
                    }
                }
            }
        }
    }

    func playerRow(_ player: OnlinePlayer) -> some View {
        HStack(spacing: DesignBook.Spacing.md) {
            Circle()
                .fill(teamColor(for: player.teamId))
                .frame(width: 12, height: 12)

            Text(player.name)
                .font(DesignBook.Font.body)
                .foregroundColor(DesignBook.Color.Text.primary)

            if player.id == room?.hostId {
                Text("lobby.host")
                    .font(DesignBook.Font.caption)
                    .foregroundColor(DesignBook.Color.Text.accent)
                    .padding(.horizontal, DesignBook.Spacing.xs)
                    .padding(.vertical, 2)
                    .background(DesignBook.Color.Text.accent.opacity(0.2))
                    .cornerRadius(4)
            }

            Spacer()

            if player.teamId != nil {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(DesignBook.Color.Status.success)
            } else {
                Text("lobby.noTeam")
                    .font(DesignBook.Font.caption)
                    .foregroundColor(DesignBook.Color.Text.tertiary)
            }
        }
        .padding(.vertical, DesignBook.Spacing.xs)
    }

    func teamColor(for teamId: String?) -> Color {
        guard let teamId,
              let team = room?.teams.first(where: { $0.id == teamId }) else {
            return DesignBook.Color.Text.tertiary
        }
        return Color(hex: team.colorHex) ?? DesignBook.Color.Text.accent
    }

    var teamsSection: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            HStack {
                Text("lobby.teams")
                    .font(DesignBook.Font.captionBold)
                    .foregroundColor(DesignBook.Color.Text.secondary)

                Spacer()

                if isHost {
                    Button {
                        showingTeamCreation = true
                    } label: {
                        HStack(spacing: DesignBook.Spacing.xs) {
                            Image(systemName: "plus.circle.fill")
                            Text("lobby.addTeam")
                        }
                        .font(DesignBook.Font.caption)
                        .foregroundColor(DesignBook.Color.Text.accent)
                    }
                }
            }

            if let teams = room?.teams, !teams.isEmpty {
                ForEach(teams) { team in
                    teamCard(team)
                }
            } else {
                GameCard {
                    VStack(spacing: DesignBook.Spacing.sm) {
                        Image(systemName: "person.2.slash")
                            .font(.system(size: 40))
                            .foregroundColor(DesignBook.Color.Text.tertiary)

                        Text("lobby.noTeams")
                            .font(DesignBook.Font.body)
                            .foregroundColor(DesignBook.Color.Text.tertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignBook.Spacing.lg)
                }
            }
        }
    }

    func teamCard(_ team: OnlineTeam) -> some View {
        let teamPlayers = room?.players.filter { $0.teamId == team.id } ?? []
        let isCurrentPlayerInTeam = roomManager.currentPlayer?.teamId == team.id

        return GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                HStack {
                    Circle()
                        .fill(Color(hex: team.colorHex) ?? DesignBook.Color.Text.accent)
                        .frame(width: 16, height: 16)

                    Text(team.name)
                        .font(DesignBook.Font.headline)
                        .foregroundColor(DesignBook.Color.Text.primary)

                    Spacer()

                    Text("\(teamPlayers.count) " + String(localized: "lobby.playersCount"))
                        .font(DesignBook.Font.caption)
                        .foregroundColor(DesignBook.Color.Text.tertiary)
                }

                if !teamPlayers.isEmpty {
                    ForEach(teamPlayers) { player in
                        Text(player.name)
                            .font(DesignBook.Font.body)
                            .foregroundColor(DesignBook.Color.Text.secondary)
                    }
                }

                HStack {
                    if isCurrentPlayerInTeam {
                        Button {
                            leaveTeam()
                        } label: {
                            Text("lobby.leaveTeam")
                                .font(DesignBook.Font.caption)
                                .foregroundColor(DesignBook.Color.Status.error)
                        }
                    } else {
                        Button {
                            joinTeam(team.id)
                        } label: {
                            Text("lobby.joinTeam")
                                .font(DesignBook.Font.caption)
                                .foregroundColor(DesignBook.Color.Text.accent)
                        }
                    }

                    Spacer()

                    if isHost {
                        Button {
                            removeTeam(team.id)
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(DesignBook.Color.Status.error)
                        }
                    }
                }
            }
        }
    }

    var actionButtons: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            if isHost {
                PrimaryButton(title: String(localized: "lobby.startGame"), icon: "play.fill") {
                    startGame()
                }
                .disabled(!canStartGame)
                .opacity(canStartGame ? DesignBook.Opacity.enabled : DesignBook.Opacity.disabled)

                if !canStartGame {
                    Text("lobby.needMorePlayers")
                        .font(DesignBook.Font.caption)
                        .foregroundColor(DesignBook.Color.Text.tertiary)
                        .multilineTextAlignment(.center)
                }
            } else {
                VStack(spacing: DesignBook.Spacing.sm) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: DesignBook.Color.Text.accent))

                    Text("lobby.waitingForHost")
                        .font(DesignBook.Font.body)
                        .foregroundColor(DesignBook.Color.Text.secondary)
                }
            }
        }
        .paddingHorizontalDefault()
    }

    // MARK: - Actions

    func joinTeam(_ teamId: String) {
        Task {
            do {
                try await roomManager.joinTeam(teamId: teamId)
            } catch {
                self.error = error
            }
        }
    }

    func leaveTeam() {
        Task {
            do {
                try await roomManager.leaveTeam()
            } catch {
                self.error = error
            }
        }
    }

    func removeTeam(_ teamId: String) {
        Task {
            do {
                try await roomManager.removeTeam(teamId: teamId)
            } catch {
                self.error = error
            }
        }
    }

    func startGame() {
        Task {
            do {
                try await roomManager.startGame()
            } catch {
                self.error = error
            }
        }
    }

    func leaveRoom() {
        Task {
            do {
                try await roomManager.leaveRoom()
                navigator.popToRoot()
            } catch {
                self.error = error
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        RoomLobbyView()
    }
    .environment(Navigator())
    .environment(RoomManager())
}

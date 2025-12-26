//
//  OnlineGameFlowView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 22.12.24.
//

import SwiftUI
import Navigation
import Networking
import DesignBook

struct OnlineGameFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(RoomManager.self) private var roomManager
    @State private var gameNavigator = Navigator()
    @State private var gameSyncManager = GameSyncManager()
    @State private var hasInitializedGame = false

    private var roomStatus: RoomStatus? {
        roomManager.room?.status
    }

    private var gamePhase: GamePhase? {
        roomManager.room?.gameState?.phase
    }

    private var allPlayersSubmittedWords: Bool {
        guard let players = roomManager.room?.players else { return false }
        return players.allSatisfy { $0.hasSubmittedWords }
    }

    var body: some View {
        NavigationStack(path: Bindable(gameNavigator).navigationPath) {
            content
                .navigationDestination(for: AnyPage.self) { page in
                    page.view()
                        .environment(roomManager)
                        .environment(gameNavigator)
                        .environment(gameSyncManager)
                }
        }
        .environment(roomManager)
        .environment(gameNavigator)
        .environment(gameSyncManager)
        .onReceive(gameNavigator.pleaseDismissViewPublisher) {
            dismiss()
        }
        .onChange(of: allPlayersSubmittedWords) { _, allSubmitted in
            if allSubmitted && roomManager.isHost && !hasInitializedGame {
                initializeGameIfNeeded()
            }
        }
    }
}

// MARK: - Private
private extension OnlineGameFlowView {
    @ViewBuilder
    var content: some View {
        switch roomStatus {
        case .waiting, .setup:
            RoomLobbyView()
        case .playing:
            playingContent
        case .finished:
            OnlineResultsView()
        case nil:
            ProgressView()
        }
    }

    @ViewBuilder
    var playingContent: some View {
        if !allPlayersSubmittedWords {
            // Word submission phase
            if roomManager.currentPlayer?.hasSubmittedWords == true {
                OnlineWaitingView(message: String(localized: "online.waitingForOthers"))
            } else {
                OnlineWordInputView()
            }
        } else {
            // Game phase
            gamePhaseContent
        }
    }

    @ViewBuilder
    var gamePhaseContent: some View {
        switch gamePhase {
        case .teamPrep:
            OnlineNextTeamView()
        case .playing:
            OnlinePlayView()
        case .turnResults:
            OnlineTurnResultsView()
        case .roundResults:
            OnlineRoundResultsView()
        case .finished:
            OnlineResultsView()
        case nil:
            OnlineWaitingView(message: String(localized: "online.preparingGame"))
        }
    }

    func initializeGameIfNeeded() {
        guard !hasInitializedGame,
              let room = roomManager.room,
              room.gameState == nil else { return }

        hasInitializedGame = true

        Task {
            do {
                let words = try await roomManager.getWords()
                let _ = try await gameSyncManager.initializeGame(
                    for: room.id,
                    teams: room.teams,
                    words: words,
                    roundDuration: room.settings.roundDuration
                )
            } catch {
                print("Failed to initialize game: \(error)")
                hasInitializedGame = false
            }
        }
    }
}

// MARK: - Preview
#Preview {
    OnlineGameFlowView()
        .environment(Navigator())
        .environment(RoomManager())
}

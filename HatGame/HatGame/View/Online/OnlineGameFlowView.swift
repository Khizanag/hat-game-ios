//
//  OnlineGameFlowView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 22.12.24.
//

import DesignBook
import Navigation
import Networking
import SwiftUI

/// Single-screen controller pushed onto the OnlineFlow navigation stack once
/// a player has joined or created a room. Routes between the lobby, the
/// word-submission screens, and the game-phase views based on room status
/// and the live `OnlineGameState.phase`. Re-uses the GameSyncManager
/// already in the environment from `OnlineFlowView`.
struct OnlineGameFlowView: View {
    @Environment(RoomManager.self) private var roomManager
    @Environment(GameSyncManager.self) private var gameSyncManager

    @State private var hasInitializedGame: Bool = false

    private var room: GameRoom? { roomManager.room }
    private var roomStatus: RoomStatus? { room?.status }
    private var gamePhase: GamePhase? { room?.gameState?.phase }

    private var allPlayersSubmittedWords: Bool {
        guard let players = room?.players, !players.isEmpty else { return false }
        return players.allSatisfy(\.hasSubmittedWords)
    }

    var body: some View {
        content
            .onChange(of: allPlayersSubmittedWords) { _, allSubmitted in
                guard allSubmitted, roomManager.isHost else { return }
                initializeGameIfNeeded()
            }
    }
}

// MARK: - Composition
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
            if roomManager.currentPlayer?.hasSubmittedWords == true {
                OnlineWaitingView(message: String(localized: "online.waitingForOthers"))
            } else {
                OnlineWordInputView()
            }
        } else {
            gamePhaseContent
        }
    }

    @ViewBuilder
    var gamePhaseContent: some View {
        switch gamePhase {
        case .teamPrep: OnlineNextTeamView()
        case .playing: OnlinePlayView()
        case .turnResults: OnlineTurnResultsView()
        case .roundResults: OnlineRoundResultsView()
        case .finished: OnlineResultsView()
        case nil: OnlineWaitingView(message: String(localized: "online.preparingGame"))
        }
    }

    func initializeGameIfNeeded() {
        guard !hasInitializedGame,
              let room,
              room.gameState == nil else { return }
        hasInitializedGame = true

        Task {
            do {
                let words = try await roomManager.getWords()
                _ = try await gameSyncManager.initializeGame(
                    for: room.id,
                    teams: room.teams,
                    players: room.players,
                    words: words,
                    roundDuration: room.settings.roundDuration
                )
            } catch {
                hasInitializedGame = false
            }
        }
    }
}

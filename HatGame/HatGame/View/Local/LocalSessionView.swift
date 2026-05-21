//
//  LocalSessionView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 21.05.26.
//

import DesignBook
import Navigation
import Networking
import SwiftUI

/// Phase-switching container for an active nearby-play session. Same shape
/// as `OnlineGameFlowView` (lobby → words → game phases → results) but the
/// underlying `RoomManager` is a `LocalRoomManager` backed by Multipeer.
struct LocalSessionView: View {
    @Environment(RoomManager.self) private var roomManager
    @Environment(GameSyncManager.self) private var gameSyncManager
    @Environment(LocalRoomManager.self) private var localRoomManager

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

    @ViewBuilder
    private var content: some View {
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
    private var playingContent: some View {
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
    private var gamePhaseContent: some View {
        switch gamePhase {
        case .teamPrep: OnlineNextTeamView()
        case .playing: OnlinePlayView()
        case .turnResults: OnlineTurnResultsView()
        case .roundResults: OnlineRoundResultsView()
        case .finished: OnlineResultsView()
        case nil: OnlineWaitingView(message: String(localized: "online.preparingGame"))
        }
    }

    private func initializeGameIfNeeded() {
        guard !hasInitializedGame,
              let room,
              room.gameState == nil else { return }
        hasInitializedGame = true

        Task {
            do {
                // For local: words are already in localRoomManager.words
                // (the host submitted on behalf of everyone via Multipeer).
                let words = localRoomManager.words
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

//
//  OnlineWaitingView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 22.12.24.
//

import SwiftUI
import DesignBook
import Networking

struct OnlineWaitingView: View {
    @Environment(RoomManager.self) private var roomManager

    let message: String

    private var playersSubmitted: Int {
        roomManager.room?.players.filter { $0.hasSubmittedWords }.count ?? 0
    }

    private var totalPlayers: Int {
        roomManager.room?.players.count ?? 0
    }

    var body: some View {
        VStack(spacing: DesignBook.Spacing.xl) {
            Spacer()

            VStack(spacing: DesignBook.Spacing.lg) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: DesignBook.Color.Text.accent))
                    .scaleEffect(1.5)

                Text(message)
                    .font(DesignBook.Font.title3)
                    .foregroundColor(DesignBook.Color.Text.primary)
                    .multilineTextAlignment(.center)

                Text("\(playersSubmitted)/\(totalPlayers) " + String(localized: "online.playersReady"))
                    .font(DesignBook.Font.body)
                    .foregroundColor(DesignBook.Color.Text.secondary)
            }

            Spacer()
        }
        .paddingHorizontalDefault()
        .setDefaultBackground()
    }
}

// MARK: - Preview
#Preview {
    OnlineWaitingView(message: "Waiting for other players...")
        .environment(RoomManager())
}

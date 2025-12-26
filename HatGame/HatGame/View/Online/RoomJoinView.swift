//
//  RoomJoinView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 22.12.24.
//

import SwiftUI
import DesignBook
import Navigation
import Networking

struct RoomJoinView: View {
    @Environment(Navigator.self) private var navigator
    @Environment(RoomManager.self) private var roomManager

    @State private var playerName: String = ""
    @State private var roomCode: String = ""
    @State private var isJoining: Bool = false
    @State private var error: Error?
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case roomCode
        case playerName
    }

    private var canJoin: Bool {
        !playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        roomCode.count == 6 &&
        !isJoining
    }

    var body: some View {
        content
            .navigationTitle(String(localized: "joinRoom.title"))
            .setDefaultBackground()
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
private extension RoomJoinView {
    var content: some View {
        ScrollView {
            VStack(spacing: DesignBook.Spacing.lg) {
                roomCodeCard
                playerNameCard
            }
            .paddingHorizontalDefault()
            .padding(.top, DesignBook.Spacing.lg)
            .padding(.bottom, DesignBook.Spacing.xxl)
        }
        .safeAreaInset(edge: .bottom) {
            actionButton
                .withFooterGradient()
        }
        .onAppear {
            focusedField = .roomCode
        }
    }

    var roomCodeCard: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                HStack(spacing: DesignBook.Spacing.sm) {
                    Image(systemName: "number")
                        .font(DesignBook.IconFont.medium)
                        .foregroundColor(DesignBook.Color.Text.accent)

                    Text("joinRoom.roomCode")
                        .font(DesignBook.Font.captionBold)
                        .foregroundColor(DesignBook.Color.Text.secondary)
                }

                TextField("joinRoom.enterCode", text: $roomCode)
                    .textFieldStyle(.plain)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(DesignBook.Color.Text.primary)
                    .multilineTextAlignment(.center)
                    .textCase(.uppercase)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.characters)
                    .padding(DesignBook.Spacing.md)
                    .background(DesignBook.Color.Background.secondary)
                    .cornerRadius(DesignBook.Size.smallCardCornerRadius)
                    .focused($focusedField, equals: .roomCode)
                    .onChange(of: roomCode) { _, newValue in
                        roomCode = String(newValue.uppercased().prefix(6))
                        if roomCode.count == 6 {
                            focusedField = .playerName
                        }
                    }

                Text("joinRoom.codeHint")
                    .font(DesignBook.Font.caption)
                    .foregroundColor(DesignBook.Color.Text.tertiary)
            }
        }
    }

    var playerNameCard: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                HStack(spacing: DesignBook.Spacing.sm) {
                    Image(systemName: "person.fill")
                        .font(DesignBook.IconFont.medium)
                        .foregroundColor(DesignBook.Color.Text.accent)

                    Text("joinRoom.yourName")
                        .font(DesignBook.Font.captionBold)
                        .foregroundColor(DesignBook.Color.Text.secondary)
                }

                TextField("joinRoom.enterName", text: $playerName)
                    .textFieldStyle(.plain)
                    .font(DesignBook.Font.headline)
                    .foregroundColor(DesignBook.Color.Text.primary)
                    .padding(DesignBook.Spacing.md)
                    .background(DesignBook.Color.Background.secondary)
                    .cornerRadius(DesignBook.Size.smallCardCornerRadius)
                    .focused($focusedField, equals: .playerName)
            }
        }
    }

    var actionButton: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            PrimaryButton(title: String(localized: "joinRoom.join"), icon: "arrow.right.circle.fill") {
                joinRoom()
            }
            .disabled(!canJoin)
            .opacity(canJoin ? DesignBook.Opacity.enabled : DesignBook.Opacity.disabled)
        }
        .paddingHorizontalDefault()
    }

    func joinRoom() {
        guard canJoin else { return }

        isJoining = true
        let trimmedName = playerName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCode = roomCode.uppercased()

        Task {
            do {
                try await roomManager.joinRoom(code: trimmedCode, playerName: trimmedName)
                navigator.push(.roomLobby(roomCode: trimmedCode))
            } catch {
                self.error = error
            }
            isJoining = false
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        RoomJoinView()
    }
    .environment(Navigator())
}

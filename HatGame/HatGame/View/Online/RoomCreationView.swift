//
//  RoomCreationView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 22.12.24.
//

import SwiftUI
import DesignBook
import Navigation
import Networking

struct RoomCreationView: View {
    @Environment(Navigator.self) private var navigator
    @Environment(RoomManager.self) private var roomManager

    @State private var playerName: String = ""
    @State private var wordsPerPlayer: Int = 5
    @State private var roundDuration: Int = 60
    @State private var isCreating: Bool = false
    @State private var error: Error?
    @FocusState private var isNameFocused: Bool

    private var canCreate: Bool {
        !playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isCreating
    }

    var body: some View {
        content
            .navigationTitle(String(localized: "createRoom.title"))
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
private extension RoomCreationView {
    var content: some View {
        ScrollView {
            VStack(spacing: DesignBook.Spacing.lg) {
                playerNameCard
                settingsCard
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
            isNameFocused = true
        }
    }

    var playerNameCard: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                HStack(spacing: DesignBook.Spacing.sm) {
                    Image(systemName: "person.fill")
                        .font(DesignBook.IconFont.medium)
                        .foregroundColor(DesignBook.Color.Text.accent)

                    Text("createRoom.yourName")
                        .font(DesignBook.Font.captionBold)
                        .foregroundColor(DesignBook.Color.Text.secondary)
                }

                TextField("createRoom.enterName", text: $playerName)
                    .textFieldStyle(.plain)
                    .font(DesignBook.Font.headline)
                    .foregroundColor(DesignBook.Color.Text.primary)
                    .padding(DesignBook.Spacing.md)
                    .background(DesignBook.Color.Background.secondary)
                    .cornerRadius(DesignBook.Size.smallCardCornerRadius)
                    .focused($isNameFocused)
            }
        }
    }

    var settingsCard: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.lg) {
                HStack(spacing: DesignBook.Spacing.sm) {
                    Image(systemName: "gearshape.fill")
                        .font(DesignBook.IconFont.medium)
                        .foregroundColor(DesignBook.Color.Text.accent)

                    Text("createRoom.gameSettings")
                        .font(DesignBook.Font.captionBold)
                        .foregroundColor(DesignBook.Color.Text.secondary)
                }

                VStack(spacing: DesignBook.Spacing.md) {
                    settingRow(
                        icon: "text.bubble.fill",
                        title: String(localized: "createRoom.wordsPerPlayer"),
                        value: $wordsPerPlayer,
                        range: 3...10
                    )

                    settingRow(
                        icon: "timer",
                        title: String(localized: "createRoom.roundDuration"),
                        value: $roundDuration,
                        range: 30...120,
                        step: 10,
                        suffix: String(localized: "createRoom.seconds")
                    )
                }
            }
        }
    }

    func settingRow(
        icon: String,
        title: String,
        value: Binding<Int>,
        range: ClosedRange<Int>,
        step: Int = 1,
        suffix: String? = nil
    ) -> some View {
        HStack {
            Image(systemName: icon)
                .font(DesignBook.IconFont.small)
                .foregroundColor(DesignBook.Color.Text.tertiary)
                .frame(width: 24)

            Text(title)
                .font(DesignBook.Font.body)
                .foregroundColor(DesignBook.Color.Text.primary)

            Spacer()

            HStack(spacing: DesignBook.Spacing.sm) {
                Button {
                    if value.wrappedValue - step >= range.lowerBound {
                        value.wrappedValue -= step
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(DesignBook.Font.title3)
                        .foregroundColor(value.wrappedValue <= range.lowerBound ? DesignBook.Color.Text.tertiary : DesignBook.Color.Text.accent)
                }
                .disabled(value.wrappedValue <= range.lowerBound)

                Text(suffix != nil ? "\(value.wrappedValue) \(suffix!)" : "\(value.wrappedValue)")
                    .font(DesignBook.Font.headline)
                    .foregroundColor(DesignBook.Color.Text.primary)
                    .frame(minWidth: 50)

                Button {
                    if value.wrappedValue + step <= range.upperBound {
                        value.wrappedValue += step
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(DesignBook.Font.title3)
                        .foregroundColor(value.wrappedValue >= range.upperBound ? DesignBook.Color.Text.tertiary : DesignBook.Color.Text.accent)
                }
                .disabled(value.wrappedValue >= range.upperBound)
            }
        }
        .padding(.vertical, DesignBook.Spacing.xs)
    }

    var actionButton: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            if isCreating {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.2)
                    .padding(.vertical, DesignBook.Spacing.md)
            } else {
                PrimaryButton(title: String(localized: "createRoom.create"), icon: "plus.circle.fill") {
                    createRoom()
                }
                .disabled(!canCreate)
                .opacity(canCreate ? DesignBook.Opacity.enabled : DesignBook.Opacity.disabled)
            }
        }
        .paddingHorizontalDefault()
    }

    func createRoom() {
        guard canCreate else { return }

        isCreating = true
        isNameFocused = false
        let trimmedName = playerName.trimmingCharacters(in: .whitespacesAndNewlines)

        Task {
            do {
                let settings = GameSettings(
                    wordsPerPlayer: wordsPerPlayer,
                    roundDuration: roundDuration
                )
                let roomCode = try await roomManager.createRoom(hostName: trimmedName, settings: settings)
                navigator.push(.roomLobby(roomCode: roomCode))
            } catch {
                print("Failed to create room: \(error)")
                self.error = error
            }
            isCreating = false
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        RoomCreationView()
    }
    .environment(Navigator())
}

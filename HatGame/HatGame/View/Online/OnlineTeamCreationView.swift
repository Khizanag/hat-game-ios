//
//  OnlineTeamCreationView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 22.12.24.
//

import SwiftUI
import DesignBook
import Navigation
import Networking

struct OnlineTeamCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(RoomManager.self) private var roomManager

    @State private var teamName: String = ""
    @State private var teamColor: Color = TeamDefaultColorGenerator.defaultColors[0]
    @State private var isCreating: Bool = false
    @State private var error: Error?
    @FocusState private var isNameFocused: Bool

    private var canCreate: Bool {
        !teamName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isCreating
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(String(localized: "createTeam.title"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(String(localized: "common.buttons.cancel")) {
                            dismiss()
                        }
                    }
                }
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
}

// MARK: - Private
private extension OnlineTeamCreationView {
    var content: some View {
        ScrollView {
            VStack(spacing: DesignBook.Spacing.lg) {
                teamNameCard
                colorCard
            }
            .paddingHorizontalDefault()
            .padding(.top, DesignBook.Spacing.lg)
        }
        .safeAreaInset(edge: .bottom) {
            actionButton
                .withFooterGradient()
        }
        .onAppear {
            isNameFocused = true
            selectAvailableColor()
        }
    }

    var teamNameCard: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                HStack(spacing: DesignBook.Spacing.sm) {
                    Image(systemName: "person.3.fill")
                        .font(DesignBook.IconFont.medium)
                        .foregroundColor(DesignBook.Color.Text.accent)

                    Text("createTeam.teamName")
                        .font(DesignBook.Font.captionBold)
                        .foregroundColor(DesignBook.Color.Text.secondary)
                }

                TextField("createTeam.enterName", text: $teamName)
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

    var colorCard: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                HStack(spacing: DesignBook.Spacing.sm) {
                    Image(systemName: "paintpalette.fill")
                        .font(DesignBook.IconFont.medium)
                        .foregroundColor(DesignBook.Color.Text.accent)

                    Text("createTeam.teamColor")
                        .font(DesignBook.Font.captionBold)
                        .foregroundColor(DesignBook.Color.Text.secondary)
                }

                colorPicker
            }
        }
    }

    var colorPicker: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: DesignBook.Size.colorSwatchSize), spacing: DesignBook.Spacing.md)],
            spacing: DesignBook.Spacing.md
        ) {
            ForEach(TeamDefaultColorGenerator.defaultColors.indices, id: \.self) { index in
                colorOption(color: TeamDefaultColorGenerator.defaultColors[index])
            }

            ColorPicker(
                "",
                selection: $teamColor,
                supportsOpacity: false
            )
            .labelsHidden()
            .frame(width: DesignBook.Size.colorSwatchSize, height: DesignBook.Size.colorSwatchSize)
            .padding(DesignBook.Spacing.sm)
            .background(DesignBook.Color.Background.secondary)
            .cornerRadius(DesignBook.Size.smallCardCornerRadius)
        }
    }

    func colorOption(color: Color) -> some View {
        let isSelected = teamColor.isApproximatelyEqual(to: color)
        let isUsed = isColorUsedByOtherTeam(color)

        return Button {
            if !isUsed {
                teamColor = color
            }
        } label: {
            Circle()
                .fill(color)
                .frame(width: DesignBook.Size.colorSwatchSize, height: DesignBook.Size.colorSwatchSize)
                .overlay {
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(DesignBook.Font.subheadlineBold)
                            .foregroundColor(.white)
                    } else if isUsed {
                        Image(systemName: "xmark")
                            .font(DesignBook.Font.footnoteBold)
                            .foregroundColor(.white)
                            .opacity(DesignBook.Opacity.disabled)
                    }
                }
                .opacity(isUsed ? DesignBook.Opacity.disabled : DesignBook.Opacity.enabled)
        }
        .buttonStyle(.plain)
        .disabled(isUsed)
    }

    func isColorUsedByOtherTeam(_ color: Color) -> Bool {
        guard let teams = roomManager.room?.teams else { return false }
        return teams.contains { team in
            guard let teamColor = Color(hex: team.colorHex) else { return false }
            return color.isApproximatelyEqual(to: teamColor)
        }
    }

    func selectAvailableColor() {
        for color in TeamDefaultColorGenerator.defaultColors {
            if !isColorUsedByOtherTeam(color) {
                teamColor = color
                return
            }
        }
    }

    var actionButton: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            PrimaryButton(title: String(localized: "createTeam.create"), icon: "plus.circle.fill") {
                createTeam()
            }
            .disabled(!canCreate)
            .opacity(canCreate ? DesignBook.Opacity.enabled : DesignBook.Opacity.disabled)
        }
        .paddingHorizontalDefault()
    }

    func createTeam() {
        guard canCreate else { return }

        isCreating = true
        let trimmedName = teamName.trimmingCharacters(in: .whitespacesAndNewlines)
        let colorHex = teamColor.hexString

        Task {
            do {
                try await roomManager.createTeam(name: trimmedName, colorHex: colorHex)
                dismiss()
            } catch {
                self.error = error
            }
            isCreating = false
        }
    }
}

// MARK: - Preview
#Preview {
    OnlineTeamCreationView()
        .environment(RoomManager())
}

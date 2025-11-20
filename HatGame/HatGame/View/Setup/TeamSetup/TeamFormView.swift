//
//  TeamFormView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 16.11.25.
//

import SwiftUI
import UIKit

struct TeamFormView: View {
    @Environment(Navigator.self) private var navigator
    @Environment(GameManager.self) private var gameManager

    let team: Team?
    let onPrimaryAction: (Team) -> Void

    private let appConfiguration = AppConfiguration.shared
    @State private var teamName: String = ""
    @State private var playerNames: [String] = []
    @State private var teamColor: Color = TeamDefaultColorGenerator.defaultColors[0]
    @State private var isColorSectionExpanded: Bool = false
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case teamName
        case player(Int)
    }

    init(
        team: Team? = nil,
        onPrimaryAction: @escaping (Team) -> Void
    ) {
        self.team = team
        self.onPrimaryAction = onPrimaryAction
    }

    private var canSave: Bool {
        !teamName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        playerNames.allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    private var title: String {
        team == nil ? "New Team" : "Edit group"
    }

    private var primaryButtonTitle: String {
        team == nil ? "Create Team" : "Save changes"
    }

    private var primaryButtonIcon: String? {
        team == nil ? "plus.circle.fill" : "checkmark.circle.fill"
    }

    private var currentTeamId: UUID? {
        team?.id
    }

    var body: some View {
        ScrollView {
            VStack(spacing: DesignBook.Spacing.lg) {
                teamNameCard
                colorCard
                playersCard
            }
            .paddingHorizontalDefault()
            .padding(.top, DesignBook.Spacing.lg)
            .padding(.bottom, DesignBook.Spacing.xxl)
        }
        .safeAreaInset(edge: .bottom) {
            actionButtons
        }
        .setDefaultStyle(title: title)
        .onAppear {
            loadInitialData()
            if teamName.isEmpty {
                focusedField = .teamName
            }
        }
    }
}

private extension TeamFormView {
    var teamNameCard: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                HStack(spacing: DesignBook.Spacing.sm) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: DesignBook.Size.iconSize))
                        .foregroundColor(DesignBook.Color.Text.accent)

                    Text("Team Name")
                        .font(DesignBook.Font.captionBold)
                        .foregroundColor(DesignBook.Color.Text.secondary)
                }

                TextField("Enter team name", text: $teamName)
                    .textFieldStyle(.plain)
                    .font(DesignBook.Font.headline)
                    .foregroundColor(DesignBook.Color.Text.primary)
                    .padding(DesignBook.Spacing.md)
                    .background(DesignBook.Color.Background.secondary)
                    .cornerRadius(DesignBook.Size.smallCardCornerRadius)
                    .focused($focusedField, equals: .teamName)
                    .onSubmit {
                        if !playerNames.isEmpty {
                            focusedField = .player(0)
                        }
                    }
            }
        }
    }

    var colorCard: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                Button {
                    withAnimation(.easeInOut) {
                        isColorSectionExpanded.toggle()
                    }
                } label: {
                    HStack(spacing: DesignBook.Spacing.sm) {
                        Image(systemName: "paintpalette.fill")
                            .font(.system(size: DesignBook.Size.iconSize))
                            .foregroundColor(DesignBook.Color.Text.accent)

                        Text("Team Color")
                            .font(DesignBook.Font.captionBold)
                            .foregroundColor(DesignBook.Color.Text.secondary)

                        Spacer()

                        if !isColorSectionExpanded {
                            Circle()
                                .fill(teamColor)
                                .frame(width: 24, height: 24)
                        }

                        Image(systemName: isColorSectionExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(DesignBook.Color.Text.secondary)
                    }
                }

                if isColorSectionExpanded {
                    colorPicker
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }

    var colorPicker: some View {
        HStack {
            if appConfiguration.isRightHanded {
                Spacer()
            }

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 44), spacing: DesignBook.Spacing.md)],
                spacing: DesignBook.Spacing.md
            ) {
                ForEach(suggestedColorOptions.indices, id: \.self) { index in
                    colorOption(color: suggestedColorOptions[index], index: index)
                }

                ColorPicker(
                    "Custom Color",
                    selection: Binding(
                        get: { teamColor },
                        set: { newColor in
                            withAnimation(.easeInOut) {
                                teamColor = newColor
                                isColorSectionExpanded = false
                            }
                        }
                    ),
                    supportsOpacity: true
                )
                .labelsHidden()
                .frame(width: 44, height: 44)
                .padding(DesignBook.Spacing.sm)
                .background(DesignBook.Color.Background.secondary)
                .cornerRadius(DesignBook.Size.smallCardCornerRadius)
                .contentShape(Rectangle())
            }
        }
    }

    var suggestedColorOptions: [Color] {
        TeamDefaultColorGenerator.defaultColors
    }

    func colorOption(color: Color, index: Int) -> some View {
        let isDisabled = isColorOccupiedByOtherTeam(color)

        return Button {
            if !isDisabled {
                withAnimation(.easeInOut) {
                    teamColor = color
                    isColorSectionExpanded = false
                }
            }
        } label: {
            Circle()
                .fill(color)
                .frame(width: 44, height: 44)
                .overlay {
                    if isSuggestedColorSelected(index) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    } else if isDisabled {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .opacity(DesignBook.Opacity.disabled)
                    }
                }
                .opacity(isDisabled ? DesignBook.Opacity.disabled : DesignBook.Opacity.enabled)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }

    func isSuggestedColorSelected(_ index: Int) -> Bool {
        guard index < suggestedColorOptions.count else { return false }
        let suggestedColor = suggestedColorOptions[index]
        return isColorSelected(suggestedColor)
    }

    func isColorSelected(_ color: Color) -> Bool {
        // Compare colors by converting to UIColor and comparing components
        let uiColor1 = UIColor(teamColor)
        let uiColor2 = UIColor(color)

        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0

        guard uiColor1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1),
              uiColor2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2) else {
            return false
        }

        return abs(r1 - r2) < 0.01 && abs(g1 - g2) < 0.01 && abs(b1 - b2) < 0.01
    }

    func isColorOccupiedByOtherTeam(_ color: Color) -> Bool {
        gameManager.configuration.teams.contains { team in
            // Skip the current team if editing
            if let currentTeamId = currentTeamId, team.id == currentTeamId {
                return false
            }
            return areColorsEqual(color, team.color)
        }
    }

    func areColorsEqual(_ color1: Color, _ color2: Color) -> Bool {
        let uiColor1 = UIColor(color1)
        let uiColor2 = UIColor(color2)

        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0

        guard uiColor1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1),
              uiColor2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2) else {
            return false
        }

        return abs(r1 - r2) < 0.01 && abs(g1 - g2) < 0.01 && abs(b1 - b2) < 0.01
    }

    var playersCard: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                HStack(spacing: DesignBook.Spacing.sm) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: DesignBook.Size.iconSize))
                        .foregroundColor(DesignBook.Color.Text.accent)

                    Text("Players")
                        .font(DesignBook.Font.captionBold)
                        .foregroundColor(DesignBook.Color.Text.secondary)

                    Spacer()

                    Text("\(playerNames.count)")
                        .font(DesignBook.Font.captionBold)
                        .foregroundColor(DesignBook.Color.Text.tertiary)
                }

                VStack(spacing: DesignBook.Spacing.md) {
                    ForEach(playerNames.indices, id: \.self) { index in
                        playerField(index: index)
                    }
                }
            }
        }
    }

    func playerField(index: Int) -> some View {
        HStack(spacing: DesignBook.Spacing.md) {
            Text("\(index + 1)")
                .font(DesignBook.Font.captionBold)
                .foregroundColor(DesignBook.Color.Text.accent)
                .frame(width: 24, height: 24)
                .background(DesignBook.Color.Text.accent.opacity(DesignBook.Opacity.highlight))
                .clipShape(Circle())

            TextField("Player name", text: Binding(
                get: { playerNames[index] },
                set: { playerNames[index] = $0 }
            ))
            .textFieldStyle(.plain)
            .font(DesignBook.Font.body)
            .foregroundColor(DesignBook.Color.Text.primary)
            .padding(DesignBook.Spacing.md)
            .background(DesignBook.Color.Background.secondary)
            .cornerRadius(DesignBook.Size.smallCardCornerRadius)
            .focused($focusedField, equals: .player(index))
            .onSubmit {
                let nextIndex = index + 1
                if nextIndex < playerNames.count {
                    focusedField = .player(nextIndex)
                } else {
                    focusedField = nil
                }
            }
        }
    }

    var actionButtons: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            Group {
                if let icon = primaryButtonIcon {
                    PrimaryButton(title: primaryButtonTitle, icon: icon) {
                        handlePrimaryAction()
                    }
                } else {
                    PrimaryButton(title: primaryButtonTitle) {
                        handlePrimaryAction()
                    }
                }
            }
            .disabled(!canSave)
            .opacity(canSave ? DesignBook.Opacity.enabled : DesignBook.Opacity.disabled)

            DestructiveButton(title: "Cancel") {
                navigator.dismiss()
            }
        }
        .paddingHorizontalDefault()
        .padding(.top, DesignBook.Spacing.md)
        .padding(.bottom, DesignBook.Spacing.lg)
    }

    func loadInitialData() {
        if let team = team {
            teamName = team.name
            var names = team.players.map { $0.name }
            // Pad to maxTeamMembers if needed
            while names.count < gameManager.configuration.maxTeamMembers {
                names.append("")
            }
            playerNames = names
            teamColor = team.color
        } else {
            teamName = ""
            playerNames = Array(repeating: "", count: gameManager.configuration.maxTeamMembers)
            updateDefaultColor()
        }
    }

    func updateDefaultColor() {
        let generator = TeamDefaultColorGenerator()
        teamColor = generator.generateDefaultColor(for: gameManager.configuration)
    }

    func handlePrimaryAction() {
        let trimmedName = teamName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        let teamId = team?.id ?? UUID()
        let updatedTeam = Team(
            id: teamId,
            name: trimmedName,
            players: playerNames
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .map { Player(name: $0, teamId: teamId) },
            color: teamColor
        )

        onPrimaryAction(updatedTeam)
        navigator.dismiss()
    }
}

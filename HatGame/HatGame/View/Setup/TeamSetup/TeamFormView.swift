//
//  TeamFormView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 16.11.25.
//

import SwiftUI

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
    @State private var isKeyboardVisible: Bool = false
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
        let trimmedName = teamName.trimmingCharacters(in: .whitespacesAndNewlines)
        let nonEmptyPlayers = playerNames.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

        return !trimmedName.isEmpty &&
               nonEmptyPlayers.count >= gameManager.configuration.minTeamMembers
    }

    private var validationMessage: String? {
        let nonEmptyPlayers = playerNames.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

        if !teamName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
           nonEmptyPlayers.count < gameManager.configuration.minTeamMembers {
            return String(
                format: String(localized: "teamForm.validation.minPlayers"),
                gameManager.configuration.minTeamMembers
            )
        }
        return nil
    }

    private var title: String {
        team == nil ? String(localized: "teamForm.title.new") : String(localized: "teamForm.title.edit")
    }

    private var primaryButtonTitle: String {
        team == nil ? String(localized: "teamForm.primary.create") : String(localized: "teamForm.primary.save")
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
                .withFooterGradient()
        }
        .setDefaultStyle(title: title)
        .onAppear {
            loadInitialData()
            if teamName.isEmpty {
                focusedField = .teamName
            }
            setupKeyboardObservers()
        }
        .onDisappear {
            removeKeyboardObservers()
        }
    }
}

// MARK: - Private
private extension TeamFormView {
    var teamNameCard: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                HStack(spacing: DesignBook.Spacing.sm) {
                    Image(systemName: "person.3.fill")
                        .font(DesignBook.IconFont.medium)
                        .foregroundColor(DesignBook.Color.Text.accent)

                    Text("teamForm.teamName")
                        .font(DesignBook.Font.captionBold)
                        .foregroundColor(DesignBook.Color.Text.secondary)
                }

                TextField("teamForm.enterTeamName", text: $teamName)
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
                            .font(DesignBook.IconFont.medium)
                            .foregroundColor(DesignBook.Color.Text.accent)

                        Text("teamForm.teamColor")
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
                columns: [GridItem(.adaptive(minimum: DesignBook.Size.colorSwatchSize), spacing: DesignBook.Spacing.md)],
                spacing: DesignBook.Spacing.md
            ) {
                ForEach(suggestedColorOptions.indices, id: \.self) { index in
                    colorOption(color: suggestedColorOptions[index], index: index)
                }

                ColorPicker(
                    "teamForm.customColor",
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
                .frame(width: DesignBook.Size.colorSwatchSize, height: DesignBook.Size.colorSwatchSize)
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
                .frame(width: DesignBook.Size.colorSwatchSize, height: DesignBook.Size.colorSwatchSize)
                .overlay {
                    if isSuggestedColorSelected(index) {
                        Image(systemName: "checkmark")
                            .font(DesignBook.Font.subheadlineBold)
                            .foregroundColor(.white)
                    } else if isDisabled {
                        Image(systemName: "xmark")
                            .font(DesignBook.Font.footnoteBold)
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
        teamColor.isApproximatelyEqual(to: color)
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
        color1.isApproximatelyEqual(to: color2)
    }

    var playersCard: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
                HStack(spacing: DesignBook.Spacing.sm) {
                    Image(systemName: "person.2.fill")
                        .font(DesignBook.IconFont.medium)
                        .foregroundColor(DesignBook.Color.Text.accent)

                    Text("teamForm.players")
                        .font(DesignBook.Font.captionBold)
                        .foregroundColor(DesignBook.Color.Text.secondary)

                    Spacer()

                    Text("\(playerNames.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count)/\(gameManager.configuration.maxTeamMembers)")
                        .font(DesignBook.Font.captionBold)
                        .foregroundColor(DesignBook.Color.Text.tertiary)
                }

                if let validationMessage {
                    Text(validationMessage)
                        .font(DesignBook.Font.caption)
                        .foregroundColor(DesignBook.Color.Status.error)
                }

                VStack(spacing: DesignBook.Spacing.md) {
                    ForEach(playerNames.indices, id: \.self) { index in
                        playerField(index: index)
                    }
                }

                if playerNames.count < gameManager.configuration.maxTeamMembers {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            playerNames.append("")
                            focusedField = .player(playerNames.count - 1)
                        }
                    } label: {
                        HStack(spacing: DesignBook.Spacing.sm) {
                            Image(systemName: "plus.circle.fill")
                                .font(DesignBook.IconFont.medium)
                                .foregroundColor(DesignBook.Color.Text.accent)

                            Text("teamForm.addPlayer")
                                .font(DesignBook.Font.body)
                                .foregroundColor(DesignBook.Color.Text.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(DesignBook.Spacing.md)
                        .background(DesignBook.Color.Background.secondary)
                        .cornerRadius(DesignBook.Size.smallCardCornerRadius)
                    }
                    .buttonStyle(.plain)
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

            TextField("teamForm.playerName", text: Binding(
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

            if playerNames.count > gameManager.configuration.minTeamMembers {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        playerNames.remove(at: index)
                        if focusedField == .player(index) {
                            focusedField = nil
                        }
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(DesignBook.IconFont.medium)
                        .foregroundColor(DesignBook.Color.Status.error.opacity(0.7))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Action Buttons

    var actionButtons: some View {
        Group {
            if isKeyboardVisible {
                // Horizontal layout when keyboard is visible
                HStack(spacing: DesignBook.Spacing.md) {
                    Button(action: navigator.dismiss) {
                        Text("common.buttons.cancel")
                            .font(DesignBook.Font.headline)
                            .padding(8)
                            .cornerRadius(DesignBook.Size.smallCardCornerRadius)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(DesignBook.Color.Status.error)

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
                }
                .paddingHorizontalDefault()
                .padding(.top, DesignBook.Spacing.md)
                .padding(.bottom, DesignBook.Spacing.sm)
            } else {
                // Vertical layout when keyboard is hidden
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

                    DestructiveButton(title: String(localized: "common.buttons.cancel")) {
                        navigator.dismiss()
                    }
                }
                .paddingHorizontalDefault()
                .padding(.top, DesignBook.Spacing.md)
                .padding(.bottom, DesignBook.Spacing.sm)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isKeyboardVisible)
    }

    // MARK: - Keyboard Handling

    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { _ in
            isKeyboardVisible = true
        }

        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            isKeyboardVisible = false
        }
    }

    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // MARK: - Data Handling

    func loadInitialData() {
        if let team = team {
            teamName = team.name
            // Start with existing players, ensuring at least minTeamMembers fields
            var names = team.players.map { $0.name }
            while names.count < gameManager.configuration.minTeamMembers {
                names.append("")
            }
            playerNames = names
            teamColor = team.color
        } else {
            teamName = ""
            // Start with minimum required fields for new teams
            playerNames = Array(repeating: "", count: gameManager.configuration.minTeamMembers)
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

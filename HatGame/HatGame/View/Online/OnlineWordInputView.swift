//
//  OnlineWordInputView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 22.12.24.
//

import SwiftUI
import DesignBook
import Navigation
import Networking

struct OnlineWordInputView: View {
    @Environment(RoomManager.self) private var roomManager
    @Environment(Navigator.self) private var navigator

    @State private var playerWords: [String] = []
    @State private var currentWord: String = ""
    @State private var isSubmitting: Bool = false
    @State private var error: Error?
    @FocusState private var isWordFieldFocused: Bool

    private var wordsPerPlayer: Int {
        roomManager.room?.settings.wordsPerPlayer ?? 5
    }

    private var canSubmit: Bool {
        playerWords.count >= wordsPerPlayer && !isSubmitting
    }

    var body: some View {
        content
            .setDefaultStyle(title: String(localized: "onlineWordInput.title"))
            .onAppear {
                isWordFieldFocused = true
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
private extension OnlineWordInputView {
    var content: some View {
        ScrollView {
            VStack(spacing: DesignBook.Spacing.lg) {
                headerCard
                wordInputCard
            }
            .paddingHorizontalDefault()
            .padding(.bottom, DesignBook.Spacing.xxl)
        }
        .safeAreaInset(edge: .bottom) {
            actionButton
                .withFooterGradient()
        }
    }

    var headerCard: some View {
        GameCard {
            VStack(spacing: DesignBook.Spacing.md) {
                Image(systemName: "text.bubble.fill")
                    .font(.system(size: 40))
                    .foregroundColor(DesignBook.Color.Text.accent)

                Text("onlineWordInput.instruction")
                    .font(DesignBook.Font.body)
                    .foregroundColor(DesignBook.Color.Text.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }

    var wordInputCard: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.lg) {
                progressHeader

                if !playerWords.isEmpty {
                    wordsList
                }

                if playerWords.count < wordsPerPlayer {
                    wordTextField
                }
            }
        }
    }

    var progressHeader: some View {
        VStack(alignment: .leading, spacing: DesignBook.Spacing.xs) {
            HStack {
                Text("onlineWordInput.wordsAdded")
                    .font(DesignBook.Font.headline)
                    .foregroundColor(DesignBook.Color.Text.primary)

                Spacer()

                Text("\(playerWords.count)/\(wordsPerPlayer)")
                    .font(DesignBook.Font.title3)
                    .foregroundColor(DesignBook.Color.Text.accent)
            }

            ProgressView(value: Double(playerWords.count), total: Double(wordsPerPlayer))
                .tint(DesignBook.Color.Text.accent)
                .progressViewStyle(.linear)
        }
    }

    var wordTextField: some View {
        HStack(spacing: DesignBook.Spacing.sm) {
            TextField("onlineWordInput.enterWord", text: $currentWord)
                .textFieldStyle(.plain)
                .font(DesignBook.Font.body)
                .foregroundColor(DesignBook.Color.Text.primary)
                .padding(DesignBook.Spacing.md)
                .background(DesignBook.Color.Background.secondary)
                .cornerRadius(DesignBook.Size.smallCardCornerRadius)
                .focused($isWordFieldFocused)
                .onSubmit {
                    addWord()
                }

            Button {
                addWord()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(DesignBook.Font.title2)
                    .foregroundColor(currentWord.isEmpty ? DesignBook.Color.Text.tertiary : DesignBook.Color.Text.accent)
            }
            .disabled(currentWord.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    var wordsList: some View {
        VStack(alignment: .leading, spacing: DesignBook.Spacing.sm) {
            ForEach(playerWords.indices, id: \.self) { index in
                wordRow(at: index)
            }
        }
    }

    func wordRow(at index: Int) -> some View {
        HStack(spacing: DesignBook.Spacing.sm) {
            Text("\(index + 1)")
                .font(DesignBook.Font.caption)
                .foregroundColor(DesignBook.Color.Text.tertiary)
                .frame(width: 24, height: 24)
                .background(DesignBook.Color.Background.secondary)
                .clipShape(Circle())

            Text(playerWords[index])
                .font(DesignBook.Font.body)
                .foregroundColor(DesignBook.Color.Text.primary)

            Spacer()

            Button {
                removeWord(at: index)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(DesignBook.IconFont.small)
                    .foregroundColor(DesignBook.Color.Status.error.opacity(0.7))
            }
            .buttonStyle(.plain)
        }
        .padding(DesignBook.Spacing.md)
        .background(DesignBook.Color.Background.secondary)
        .cornerRadius(DesignBook.Size.smallCardCornerRadius)
    }

    var actionButton: some View {
        VStack(spacing: DesignBook.Spacing.md) {
            PrimaryButton(title: String(localized: "onlineWordInput.submit"), icon: "checkmark.circle.fill") {
                submitWords()
            }
            .disabled(!canSubmit)
            .opacity(canSubmit ? DesignBook.Opacity.enabled : DesignBook.Opacity.disabled)
        }
        .paddingHorizontalDefault()
    }

    func addWord() {
        let trimmedWord = currentWord.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedWord.isEmpty else { return }
        guard playerWords.count < wordsPerPlayer else { return }
        guard !playerWords.contains(trimmedWord) else { return }

        withAnimation {
            playerWords.append(trimmedWord)
        }
        currentWord = ""
        isWordFieldFocused = true
    }

    func removeWord(at index: Int) {
        withAnimation {
            playerWords.remove(at: index)
        }
    }

    func submitWords() {
        guard canSubmit else { return }

        isSubmitting = true

        Task {
            do {
                try await roomManager.submitWords(playerWords)
            } catch {
                self.error = error
            }
            isSubmitting = false
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        OnlineWordInputView()
    }
    .environment(Navigator())
    .environment(RoomManager())
}

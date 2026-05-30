//
//  WordGenerationView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 31.05.26.
//

import DesignBook
import Navigation
import SwiftUI

/// Shown for the automatic word source: animates "drawing" words from the hat,
/// fills the game with random words from the bundled database, then continues.
struct WordGenerationView: View {
    @Environment(GameManager.self) private var gameManager
    @Environment(Navigator.self) private var navigator
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var phase: Phase = .generating
    @State private var displayWord: String = ""
    @State private var progress: Double = 0
    @State private var generatedCount: Int = 0
    @State private var hasStarted = false
    @State private var isHatFloating = false
    @State private var cycleTimer: Timer?
    @AccessibilityFocusState private var readyControlFocused: Bool

    private enum Phase { case generating, ready }

    /// Total words to draw. Reached only after team setup, so there are always
    /// at least two teams of players; `max(1,)` is a defensive floor.
    private var targetCount: Int {
        let players = gameManager.configuration.teams.flatMap(\.players).count
        return max(1, gameManager.configuration.wordsPerPlayer * players)
    }

    var body: some View {
        content
            .navigationTitle(String(localized: "wordGeneration.navTitle"))
            .navigationBarTitleDisplayMode(.inline)
            .setDefaultBackground()
            .navigationBarBackButtonHidden(phase == .generating)
            .toolbar(phase == .generating ? .hidden : .automatic, for: .navigationBar)
            .onAppear(perform: startIfNeeded)
            .onDisappear(perform: stopCycling)
    }
}

// MARK: - Layout
private extension WordGenerationView {
    var content: some View {
        VStack(spacing: DesignBook.Spacing.xl) {
            Spacer(minLength: 0)
            hatHero
            statusSection
            wordCard
            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .tint(DesignBook.Color.Text.accent)
                .padding(.horizontal, DesignBook.Spacing.xl)
                .opacity(phase == .generating ? 1 : 0)
                .accessibilityLabel(Text(String(localized: "wordGeneration.title")))
            Spacer(minLength: 0)
            if phase == .ready, generatedCount > 0 {
                continueButton
                    .transition(reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity))
            }
        }
        .paddingHorizontalDefault()
        .padding(.bottom, DesignBook.Spacing.xl)
    }

    var hatHero: some View {
        ZStack {
            Circle()
                .fill(DesignBook.Gradient.primary)
                .frame(width: 168, height: 168)
                .blur(radius: 36)
                .opacity(DesignBook.Opacity.semiTransparent)

            Circle()
                .fill(DesignBook.Color.Background.card)
                .frame(width: 136, height: 136)
                .shadow(.large)

            Text(verbatim: "🎩")
                .font(DesignBook.IconFont.emoji)
                .offset(y: reduceMotion ? 0 : (isHatFloating ? -8 : 8))
        }
        .overlay(alignment: .bottomTrailing) {
            if phase == .ready {
                Image(systemName: "checkmark.circle.fill")
                    .font(DesignBook.IconFont.extraLarge)
                    .foregroundStyle(DesignBook.Color.Status.success)
                    .background(Circle().fill(DesignBook.Color.Background.primary))
                    .transition(.scale.combined(with: .opacity))
                    .offset(x: 6, y: 6)
            }
        }
        .accessibilityHidden(true)
    }

    var statusSection: some View {
        VStack(spacing: DesignBook.Spacing.xs) {
            Text(phase == .generating
                ? String(localized: "wordGeneration.title")
                : String(localized: "wordGeneration.ready"))
                .font(DesignBook.Font.title2)
                .foregroundStyle(DesignBook.Color.Text.primary)
                .contentTransition(.opacity)

            Text(phase == .generating
                ? String(localized: "wordGeneration.subtitle")
                : String(format: String(localized: "wordGeneration.count"), generatedCount))
                .font(DesignBook.Font.body)
                .foregroundStyle(DesignBook.Color.Text.secondary)
                .multilineTextAlignment(.center)
                .contentTransition(.opacity)
        }
        .accessibilityElement(children: .combine)
    }

    var wordCard: some View {
        Text(displayWord)
            .font(DesignBook.Font.title2)
            .foregroundStyle(DesignBook.Color.Text.accent)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignBook.Spacing.lg)
            .padding(.horizontal, DesignBook.Spacing.md)
            .background(DesignBook.Color.Background.card)
            .cornerRadius(DesignBook.Size.cardCornerRadius)
            .opacity(phase == .generating ? 1 : 0)
            .contentTransition(.opacity)
            .accessibilityHidden(true)
    }

    var continueButton: some View {
        PrimaryButton(title: String(localized: "common.buttons.continue"), icon: "arrow.right.circle.fill") {
            DesignBook.Haptics.tap()
            navigator.push(.randomization)
        }
        .accessibilityFocused($readyControlFocused)
        .accessibilityHint(Text(String(format: String(localized: "wordGeneration.count"), generatedCount)))
    }
}

// MARK: - Generation
private extension WordGenerationView {
    func startIfNeeded() {
        guard !hasStarted else { return }
        hasStarted = true

        if !reduceMotion {
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                isHatFloating = true
            }
        }

        let words = WordDatabase.words
        guard !reduceMotion, !words.isEmpty else {
            finish()
            return
        }

        var ticks = 0
        let maxTicks = 26 // ~26 * 0.08s ≈ 2.1s of "drawing"
        cycleTimer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { _ in
            ticks += 1
            displayWord = words.randomElement() ?? ""
            withAnimation(.linear(duration: 0.08)) {
                progress = min(1, Double(ticks) / Double(maxTicks))
            }
            if ticks.isMultiple(of: 5) {
                Task { @MainActor in DesignBook.Haptics.selection() }
            }
            if ticks >= maxTicks {
                stopCycling()
                finish()
            }
        }
    }

    func finish() {
        gameManager.fillRandomWords(count: targetCount)
        generatedCount = gameManager.configuration.words.count
        Task { @MainActor in DesignBook.Haptics.success() }
        withAnimation(reduceMotion ? nil : DesignBook.Motion.smooth) {
            progress = 1
            phase = .ready
        }
        // Move VoiceOver to the now-actionable Continue button once it is on screen.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            readyControlFocused = true
        }
    }

    func stopCycling() {
        cycleTimer?.invalidate()
        cycleTimer = nil
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        WordGenerationView()
    }
    .environment(Navigator())
    .environment(GameManager())
}

//
//  SegmentedSelectionView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct SegmentedSelectionView<ID: Hashable>: View {
    let items: [SegmentedSelectionItem<ID>]
    @Binding var selection: ID

    var body: some View {
        content
    }
}

// MARK: - Private
private extension SegmentedSelectionView {
    var content: some View {
        HStack(spacing: DesignBook.Spacing.sm) {
            ForEach(items, id: \.id) { item in
                selectionButton(for: item)
            }
        }
    }

    func selectionButton(for item: SegmentedSelectionItem<ID>) -> some View {
        let isSelected = selection == item.id

        return Button {
            handleSelection(item.id)
        } label: {
            buttonContent(for: item, isSelected: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }

    func buttonContent(for item: SegmentedSelectionItem<ID>, isSelected: Bool) -> some View {
        VStack(spacing: DesignBook.Spacing.sm) {
            iconContainer(for: item, isSelected: isSelected)
            textContent(for: item, isSelected: isSelected)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignBook.Spacing.md)
        .padding(.horizontal, DesignBook.Spacing.sm)
        .background(backgroundShape(isSelected: isSelected))
        .overlay(borderOverlay(isSelected: isSelected))
        .scaleEffect(isSelected ? 1.03 : 1.0)
        .shadow(isSelected ? .accent : .none)
    }

    func textContent(for item: SegmentedSelectionItem<ID>, isSelected: Bool) -> some View {
        VStack(spacing: DesignBook.Spacing.xs) {
            titleText(for: item, isSelected: isSelected)
            subtitleText(for: item, isSelected: isSelected)
        }
    }

    func titleText(for item: SegmentedSelectionItem<ID>, isSelected: Bool) -> some View {
        Text(LocalizedStringKey(item.title))
            .font(DesignBook.Font.captionBold)
            .foregroundColor(
                isSelected
                    ? DesignBook.Color.Text.primary
                    : DesignBook.Color.Text.secondary
            )
    }

    func subtitleText(for item: SegmentedSelectionItem<ID>, isSelected: Bool) -> some View {
        Group {
            if let subtitle = item.subtitle {
                Text(LocalizedStringKey(subtitle))
                    .font(DesignBook.Font.caption)
                    .foregroundColor(
                        isSelected
                            ? DesignBook.Color.Text.secondary
                            : DesignBook.Color.Text.tertiary
                    )
            } else {
                Text(" ")
                    .font(DesignBook.Font.caption)
            }
        }
        .frame(height: 16)
    }

    func iconContainer(for item: SegmentedSelectionItem<ID>, isSelected: Bool) -> some View {
        ZStack {
            iconBackground(isSelected: isSelected)
            iconImage(for: item, isSelected: isSelected)
        }
    }

    func iconBackground(isSelected: Bool) -> some View {
        Circle()
            .fill(
                isSelected
                    ? DesignBook.Color.Text.accent.opacity(DesignBook.Opacity.highlight)
                    : DesignBook.Color.Background.secondary
            )
            .frame(width: 48, height: 48)
    }

    func iconImage(for item: SegmentedSelectionItem<ID>, isSelected: Bool) -> some View {
        item.icon
            .font(.system(size: 22, weight: .semibold))
            .foregroundColor(
                isSelected
                    ? DesignBook.Color.Text.accent
                    : DesignBook.Color.Text.secondary
            )
            .symbolEffect(.bounce, value: isSelected)
    }

    func backgroundShape(isSelected: Bool) -> some View {
        RoundedRectangle(cornerRadius: DesignBook.Size.smallCardCornerRadius)
            .fill(
                isSelected
                    ? DesignBook.Color.Background.card
                    : DesignBook.Color.Background.secondary
            )
    }

    func borderOverlay(isSelected: Bool) -> some View {
        RoundedRectangle(cornerRadius: DesignBook.Size.smallCardCornerRadius)
            .stroke(
                isSelected
                    ? DesignBook.Color.Text.accent.opacity(0.6)
                    : Color.clear,
                lineWidth: 2
            )
    }

    func handleSelection(_ id: ID) {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
            selection = id
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: DesignBook.Spacing.xl) {
        SegmentedSelectionView(
            items: [
                SegmentedSelectionItem(
                    id: "light",
                    title: "Light",
                    subtitle: nil,
                    icon: Image(systemName: "sun.max.fill")
                ),
                SegmentedSelectionItem(
                    id: "dark",
                    title: "Dark",
                    subtitle: nil,
                    icon: Image(systemName: "moon.fill")
                ),
                SegmentedSelectionItem(
                    id: "system",
                    title: "System",
                    subtitle: "Auto",
                    icon: Image(systemName: "circle.lefthalf.filled")
                )
            ],
            selection: .constant("light")
        )
        .padding()
    }
    .background(DesignBook.Color.Background.primary)
}

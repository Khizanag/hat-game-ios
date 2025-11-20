//
//  SegmentedSelectionView.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct SegmentedSelectionItem<ID: Hashable> {
    let id: ID
    let title: String
    let subtitle: String?
    let icon: Image
}

struct SegmentedSelectionView<ID: Hashable>: View {
    let items: [SegmentedSelectionItem<ID>]
    @Binding var selection: ID
    
    var body: some View {
        HStack(spacing: DesignBook.Spacing.sm) {
            ForEach(items, id: \.id) { item in
                selectionButton(for: item)
            }
        }
    }
}

private extension SegmentedSelectionView {
    func selectionButton(for item: SegmentedSelectionItem<ID>) -> some View {
        let isSelected = selection == item.id
        
        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                selection = item.id
            }
        } label: {
            VStack(spacing: DesignBook.Spacing.sm) {
                iconContainer(for: item, isSelected: isSelected)
                
                VStack(spacing: DesignBook.Spacing.xs) {
                    Text(item.title)
                        .font(DesignBook.Font.captionBold)
                        .foregroundColor(
                            isSelected
                                ? DesignBook.Color.Text.primary
                                : DesignBook.Color.Text.secondary
                        )
                    
                    Group {
                        if let subtitle = item.subtitle {
                            Text(subtitle)
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
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignBook.Spacing.md)
            .padding(.horizontal, DesignBook.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DesignBook.Size.smallCardCornerRadius)
                    .fill(
                        isSelected
                            ? DesignBook.Color.Background.card
                            : DesignBook.Color.Background.secondary
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignBook.Size.smallCardCornerRadius)
                    .stroke(
                        isSelected
                            ? DesignBook.Color.Text.accent.opacity(0.6)
                            : Color.clear,
                        lineWidth: 2
                    )
            )
            .scaleEffect(isSelected ? 1.03 : 1.0)
            .shadow(
                color: isSelected
                    ? DesignBook.Color.Text.accent.opacity(0.2)
                    : Color.clear,
                radius: 8,
                x: 0,
                y: 4
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    func iconContainer(for item: SegmentedSelectionItem<ID>, isSelected: Bool) -> some View {
        ZStack {
            Circle()
                .fill(
                    isSelected
                        ? DesignBook.Color.Text.accent.opacity(DesignBook.Opacity.highlight)
                        : DesignBook.Color.Background.secondary
                )
                .frame(width: 48, height: 48)
            
            item.icon
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(
                    isSelected
                        ? DesignBook.Color.Text.accent
                        : DesignBook.Color.Text.secondary
                )
                .symbolEffect(.bounce, value: isSelected)
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


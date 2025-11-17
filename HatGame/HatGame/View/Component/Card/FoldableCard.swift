//
//  FoldableCard.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct FoldableCard<Content: View>: View {
    @Binding var isExpanded: Bool
    let title: String
    var description: String?
    var titleFont: Font = DesignBook.Font.title3
    var descriptionFont: Font = DesignBook.Font.body
    var spacing: CGFloat = DesignBook.Spacing.md
    var animation: Animation = .easeInOut
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        GameCard {
            VStack(alignment: .leading, spacing: spacing) {
                headerButton
                
                if isExpanded {
                    content()
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }
}

private extension FoldableCard {
    var headerButton: some View {
        Button {
            withAnimation(animation) {
                isExpanded.toggle()
            }
        } label: {
            HStack(alignment: description != nil ? .top : .center) {
                headerText
                
                Spacer()
                
                chevronIcon
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    var headerText: some View {
        if let description = description {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.xs) {
                Text(title)
                    .font(titleFont)
                    .foregroundColor(DesignBook.Color.Text.primary)
                
                Text(description)
                    .font(descriptionFont)
                    .foregroundColor(DesignBook.Color.Text.secondary)
            }
        } else {
            Text(title)
                .font(titleFont)
                .foregroundColor(DesignBook.Color.Text.primary)
        }
    }
    
    @ViewBuilder
    var chevronIcon: some View {
        if let description = description {
            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                .font(DesignBook.Font.headline)
                .foregroundColor(DesignBook.Color.Text.accent)
        } else {
            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                .foregroundColor(DesignBook.Color.Text.secondary)
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: DesignBook.Spacing.lg) {
        FoldableCard(
            isExpanded: .constant(true),
            title: "How to Play"
        ) {
            Text("Content here")
        }
        
        FoldableCard(
            isExpanded: .constant(false),
            title: "Round 1",
            description: "No restrictions"
        ) {
            Text("Round content here")
        }
    }
    .padding()
    .background(DesignBook.Color.Background.primary)
}

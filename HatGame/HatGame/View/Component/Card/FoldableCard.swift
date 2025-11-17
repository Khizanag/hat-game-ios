//
//  FoldableCard.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct FoldableCard<Content: View>: View {
    // MARK: - Properties
    @Binding var isExpanded: Bool
    let title: String
    let description: String?
    let icon: String?
    let titleFont: Font
    let descriptionFont: Font
    @ViewBuilder let content: () -> Content
    
    // MARK: - Init
    init(
        isExpanded: Binding<Bool>,
        title: String,
        description: String? = nil,
        icon: String? = nil,
        titleFont: Font = DesignBook.Font.title3,
        descriptionFont: Font = DesignBook.Font.body,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._isExpanded = isExpanded
        self.title = title
        self.description = description
        self.icon = icon
        self.titleFont = titleFont
        self.descriptionFont = descriptionFont
        self.content = content
    }
    
    var body: some View {
        GameCard {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.md) {
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
            withAnimation(.easeInOut) {
                isExpanded.toggle()
            }
        } label: {
            VStack(alignment: .leading, spacing: DesignBook.Spacing.xs) {
                HStack {
                    HStack(spacing: DesignBook.Spacing.sm) {
                        if let icon {
                            Image(systemName: icon)
                                .font(titleFont)
                                .foregroundColor(DesignBook.Color.Text.accent)
                        }
                        
                        Text(title)
                            .font(titleFont)
                            .foregroundColor(DesignBook.Color.Text.primary)
                    }
                    
                    Spacer()
                    
                    chevronIcon
                }
                
                if let description {
                    Text(description)
                        .font(descriptionFont)
                        .foregroundColor(DesignBook.Color.Text.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }

    var chevronIcon: some View {
        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
            .font(DesignBook.Font.headline)
            .foregroundColor(DesignBook.Color.Text.accent)
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

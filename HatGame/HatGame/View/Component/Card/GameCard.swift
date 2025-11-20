//
//  GameCard.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct GameCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(DesignBook.Spacing.md)
            .frame(maxWidth: .infinity)
            .background(DesignBook.Color.Background.card)
            .cornerRadius(DesignBook.Size.cardCornerRadius)
            .shadow(.large)
    }
}

// MARK: - Preview
#Preview {
    GameCard {
        Text("Card Content")
            .foregroundColor(DesignBook.Color.Text.primary)
    }
    .padding()
    .background(DesignBook.Color.Background.primary)
}

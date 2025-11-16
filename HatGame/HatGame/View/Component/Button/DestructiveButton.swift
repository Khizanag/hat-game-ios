//
//  DestructiveButton.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct DestructiveButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DesignBook.Font.headline)
                .padding(8)
                .frame(maxWidth: .infinity)
                .cornerRadius(DesignBook.Size.smallCardCornerRadius)
        }
        .buttonStyle(.glassProminent)
        .tint(DesignBook.Color.Status.error)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: DesignBook.Spacing.md) {
        DestructiveButton(title: "Cancel") {}
        DestructiveButton(title: "Delete") {}
    }
    .padding()
    .background(DesignBook.Color.Background.primary)
}


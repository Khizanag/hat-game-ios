//
//  SecondaryButton.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DesignBook.Font.headline)
                .foregroundColor(DesignBook.Color.Text.primary)
                .frame(maxWidth: .infinity)
                .frame(height: DesignBook.Size.buttonHeight)
                .background(DesignBook.Color.Button.secondary)
                .cornerRadius(DesignBook.Size.smallCardCornerRadius)
        }
        .applyShadow(DesignBook.Shadow.small)
    }
}

#Preview {
    SecondaryButton(title: "Cancel") {}
        .padding()
        .background(DesignBook.Color.Background.primary)
}


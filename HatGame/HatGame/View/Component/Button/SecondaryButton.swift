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
                .padding(8)
                .frame(maxWidth: .infinity)
                .cornerRadius(DesignBook.Size.smallCardCornerRadius)
        }
        .buttonStyle(.glass)
    }
}

#Preview {
    SecondaryButton(title: "Cancel") {}
        .padding()
        .background(DesignBook.Color.Background.primary)
}


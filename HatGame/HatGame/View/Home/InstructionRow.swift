//
//  InstructionRow.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI
import DesignBook

struct InstructionRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: DesignBook.Spacing.md) {
            ZStack {
                Circle()
                    .fill(DesignBook.Color.Text.accent.opacity(0.2))
                    .frame(width: 24, height: 24)

                Image(systemName: icon)
                    .font(DesignBook.Font.smallCaption)
                    .foregroundColor(DesignBook.Color.Text.accent)
            }

            Text(text)
                .font(DesignBook.Font.body)
                .foregroundColor(DesignBook.Color.Text.secondary)

            Spacer()
        }
    }
}

// MARK: - Preview
#Preview {
    InstructionRow(icon: "person.2", text: "Create teams and add players")
        .padding()
}

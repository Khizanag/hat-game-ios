//
//  DesignBook+Typography.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 20.11.25.
//

import SwiftUI

extension DesignBook {
    enum Font {
        static let largeTitle = SwiftUI.Font.system(size: 56, weight: .bold, design: .rounded)
        static let title = SwiftUI.Font.system(size: 42, weight: .bold, design: .rounded)
        static let title2 = SwiftUI.Font.system(size: 32, weight: .bold, design: .rounded)
        static let title3 = SwiftUI.Font.system(size: 28, weight: .semibold, design: .rounded)
        static let headline = SwiftUI.Font.system(size: 20, weight: .semibold, design: .rounded)
        static let body = SwiftUI.Font.system(size: 17, weight: .regular, design: .rounded)
        static let bodyBold = SwiftUI.Font.system(size: 17, weight: .semibold, design: .rounded)
        static let caption = SwiftUI.Font.system(size: 15, weight: .regular, design: .rounded)
        static let captionBold = SwiftUI.Font.system(size: 15, weight: .semibold, design: .rounded)
        static let smallCaption = SwiftUI.Font.system(size: 12, weight: .semibold, design: .rounded)
        static let subheadline = SwiftUI.Font.system(size: 18, weight: .semibold, design: .rounded)
        static let subheadlineBold = SwiftUI.Font.system(size: 18, weight: .bold, design: .rounded)
        static let footnote = SwiftUI.Font.system(size: 14, weight: .semibold, design: .rounded)
        static let footnoteBold = SwiftUI.Font.system(size: 14, weight: .bold, design: .rounded)
        static let callout = SwiftUI.Font.system(size: 22, weight: .semibold, design: .rounded)
    }

    enum IconFont {
        static let small = SwiftUI.Font.system(size: 20, weight: .regular, design: .rounded)
        static let medium = SwiftUI.Font.system(size: 24, weight: .regular, design: .rounded)
        static let large = SwiftUI.Font.system(size: 32, weight: .regular, design: .rounded)
        static let extraLarge = SwiftUI.Font.system(size: 48, weight: .regular, design: .rounded)
        static let emoji = SwiftUI.Font.system(size: 80, weight: .regular, design: .rounded)
    }
}

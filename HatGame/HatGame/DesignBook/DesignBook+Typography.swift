//
//  DesignBook+Typography.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 20.11.25.
//

import SwiftUI

extension DesignBook {
    enum Font {
        static let title = SwiftUI.Font.system(size: 42, weight: .bold, design: .rounded)
        static let title2 = SwiftUI.Font.system(size: 32, weight: .bold, design: .rounded)
        static let title3 = SwiftUI.Font.system(size: 28, weight: .semibold, design: .rounded)
        static let headline = SwiftUI.Font.system(size: 20, weight: .semibold, design: .rounded)
        static let body = SwiftUI.Font.system(size: 17, weight: .regular, design: .rounded)
        static let bodyBold = SwiftUI.Font.system(size: 17, weight: .semibold, design: .rounded)
        static let caption = SwiftUI.Font.system(size: 15, weight: .regular, design: .rounded)
        static let captionBold = SwiftUI.Font.system(size: 15, weight: .semibold, design: .rounded)
        static let largeTitle = SwiftUI.Font.system(size: 56, weight: .bold, design: .rounded)
    }
}


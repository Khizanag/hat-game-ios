//
//  Color+Comparison.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 20.11.25.
//

import SwiftUI

extension Color {
    func isApproximatelyEqual(to other: Color, tolerance: CGFloat = 0.01) -> Bool {
        let resolved1 = self.resolve(in: EnvironmentValues())
        let resolved2 = other.resolve(in: EnvironmentValues())
        
        let cgColor1 = resolved1.cgColor
        let cgColor2 = resolved2.cgColor
        
        guard let components1 = cgColor1.components,
              let components2 = cgColor2.components else {
            return false
        }
        
        let colorSpace1 = cgColor1.colorSpace
        let colorSpace2 = cgColor2.colorSpace
        
        guard colorSpace1?.model == colorSpace2?.model else {
            return false
        }
        
        let componentCount = min(components1.count, components2.count)
        guard componentCount >= 3 else { return false }
        
        let r1 = components1[0]
        let g1 = components1.count > 1 ? components1[1] : 0
        let b1 = components1.count > 2 ? components1[2] : 0
        
        let r2 = components2[0]
        let g2 = components2.count > 1 ? components2[1] : 0
        let b2 = components2.count > 2 ? components2[2] : 0
        
        return abs(r1 - r2) < tolerance &&
               abs(g1 - g2) < tolerance &&
               abs(b1 - b2) < tolerance
    }
}


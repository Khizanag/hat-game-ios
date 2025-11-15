//
//  Navigator.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI
import Observation

@Observable
final class Navigator {
    var navigationPath = NavigationPath()
    
    // MARK: - Navigation Methods
    
    func push(_ page: Page) {
        navigationPath.append(page)
    }
    
    func present(_ page: Page) {
        // For modal presentation, we'll use sheets/fullScreenCovers in views
        // This method can be extended for modal presentation if needed
        push(page)
    }
    
    func dismiss() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
    
    func dismissToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
    
    func popToRoot() {
        dismissToRoot()
    }
    
    func replace(with page: Page) {
        // Replace current page by removing last and adding new
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
        push(page)
    }
}


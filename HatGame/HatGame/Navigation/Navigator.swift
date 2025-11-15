//
//  Navigator.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import Combine
import SwiftUI
import Observation

@Observable
final class Navigator {
    var navigationPath: [Page] = []
    var presentedPage: Page?

    private var pleaseDismissViewSubject = PassthroughSubject<Void, Never>()

    var pleaseDismissViewPublisher: AnyPublisher<Void, Never> {
        pleaseDismissViewSubject.eraseToAnyPublisher()
    }

    // MARK: - Navigation Methods
    
    func push(_ page: Page) {
        navigationPath.append(page)
    }
    
    func present(_ page: Page) {
        presentedPage = page
    }
    
    func dismiss() {
        pleaseDismissViewSubject.send()
    }
    
    func dismissPresented() {
        presentedPage = nil
    }
    
    func dismissToRoot() {
        navigationPath = []
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


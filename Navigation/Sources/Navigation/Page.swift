//
//  Page.swift
//  Navigation Package
//
//  Created by Giga Khizanishvili on 29.11.24.
//

import SwiftUI

public struct Page<Content: View>: Hashable, Identifiable {
    public let id: String
    @ViewBuilder private let content: () -> Content

    public init(id: String, @ViewBuilder view: @escaping @MainActor () -> Content) {
        self.id = id
        self.content = view
    }

    @MainActor @ViewBuilder
    public func view() -> Content {
        content()
    }

    // Hashable conformance
    public static func == (lhs: Page<Content>, rhs: Page<Content>) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // Convert to type-erased version for storage
    internal func eraseToAnyPage() -> AnyPage {
        AnyPage(id: id, viewBuilder: { AnyView(self.view()) })
    }
}

// Internal type-erased page for storage in Navigator
internal struct AnyPage: Hashable, Identifiable {
    let id: String
    private let viewBuilder: @MainActor () -> AnyView

    init(id: String, viewBuilder: @escaping @MainActor () -> AnyView) {
        self.id = id
        self.viewBuilder = viewBuilder
    }

    @MainActor @ViewBuilder
    func view() -> some View {
        viewBuilder()
    }

    static func == (lhs: AnyPage, rhs: AnyPage) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

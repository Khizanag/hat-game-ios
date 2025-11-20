//
//  SegmentedSelectionItem.swift
//  HatGame
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import SwiftUI

struct SegmentedSelectionItem<ID: Hashable> {
    let id: ID
    let title: String
    let subtitle: String?
    let icon: Image
}

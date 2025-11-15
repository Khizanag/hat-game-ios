//
//  Item.swift
//  Hat Game
//
//  Created by Giga Khizanishvili on 15.11.25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

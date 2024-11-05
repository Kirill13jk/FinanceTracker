//
//  Item.swift
//  FinanceTracker
//
//  Created by prom1 on 05.11.2024.
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

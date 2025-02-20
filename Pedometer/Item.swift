//
//  Item.swift
//  Pedometer
//
//  Created by Karina Kedo on 2/17/25.
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

//
//  Item.swift
//  Childcare_crew
//
//  Created by 안혜민 on 3/29/25.
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

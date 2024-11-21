// Goal.swift

import Foundation
import SwiftData

@Model
class Goal: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    var targetAmount: Double
    var currentAmount: Double = 0.0
    var startDate: Date
    var endDate: Date
    var colorName: String = "blue" // Новое свойство с значением по умолчанию

    init(title: String, targetAmount: Double, startDate: Date, endDate: Date, colorName: String = "blue") {
        self.title = title
        self.targetAmount = targetAmount
        self.startDate = startDate
        self.endDate = endDate
        self.colorName = colorName
    }
}

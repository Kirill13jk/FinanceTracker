import Foundation
import SwiftData

@Model
class Goal {
    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    var targetAmount: Double
    var currentAmount: Double = 0.0
    var startDate: Date
    var endDate: Date

    init(title: String, targetAmount: Double, startDate: Date, endDate: Date) {
        self.title = title
        self.targetAmount = targetAmount
        self.startDate = startDate
        self.endDate = endDate
    }
}

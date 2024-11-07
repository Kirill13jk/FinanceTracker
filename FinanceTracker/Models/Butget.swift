import Foundation
import SwiftData

@Model
class Budget: Identifiable {
    @Attribute(.unique) var id: UUID
    var amount: Double
    var startDate: Date
    var endDate: Date

    init(amount: Double, startDate: Date, endDate: Date) {
        self.id = UUID()
        self.amount = amount
        self.startDate = startDate
        self.endDate = endDate
    }
}

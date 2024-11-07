import Foundation
import SwiftData

@Model
class Transaction: Identifiable {
    @Attribute(.unique) var id: UUID
    var amount: Double
    var category: String
    var date: Date
    var note: String?
    var isExpense: Bool

    init(amount: Double, category: String, date: Date, note: String? = nil, isExpense: Bool = true) {
        self.id = UUID()
        self.amount = amount
        self.category = category
        self.date = date
        self.note = note
        self.isExpense = isExpense
    }
}

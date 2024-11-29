import Foundation

struct CategoryData: Identifiable {
    let id = UUID()
    let category: String
    let amount: Double
    let percentage: Double
}

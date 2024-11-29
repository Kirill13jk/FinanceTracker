import Foundation

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let income: Double
    let expense: Double
}

import Foundation

extension Date {
    func endOfDay() -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: Calendar.current.startOfDay(for: self))!
    }
}

extension DateInterval {
    var datesInRange: [Date] {
        var dates: [Date] = []
        var currentDate = start

        while currentDate <= end {
            dates.append(currentDate)
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return dates
    }
}

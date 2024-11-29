import SwiftUI
import Charts
import SwiftData

struct AnalyticsView: View {
    @Query private var transactions: [Transaction]
    @State private var selectedStartDate: Date = {
        Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    }()
    @State private var selectedEndDate: Date = Date()
    @AppStorage("titleOn") private var titleOn: Bool = true
    @AppStorage("selectedCurrency") private var selectedCurrency: String = "USD"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                DatePicker("Start Date", selection: $selectedStartDate, displayedComponents: .date)
                    .padding(.horizontal)

                DatePicker("End Date", selection: $selectedEndDate, displayedComponents: .date)
                    .padding(.horizontal)

                TransactionCountView(count: filteredTransactions.count)

                CategoryLegendView(categories: categoriesInfo)

                TransactionChartView(groupedTransactions: groupedTransactions, colorForCategory: colorForCategory, currencySymbol: currencySymbol())
            }
            .padding(.top)
        }
        .navigationTitle(titleOn ? "Analytics" : "")
    }

    private var filteredTransactions: [Transaction] {
        transactions.filter { $0.date >= selectedStartDate && $0.date <= selectedEndDate }
    }

    private var groupedTransactions: [(key: String, value: Double)] {
        categoriesInfo.map { category in
            let total = transactions.filter { $0.category == category.name && $0.date >= selectedStartDate && $0.date <= selectedEndDate }
                                   .reduce(0.0) { $0 + ($1.isExpense ? -$1.amount : $1.amount) }
            return (key: category.name, value: total)
        }
    }

    private func colorForCategory(_ categoryName: String) -> Color {
        return categoriesInfo.first { $0.name == categoryName }?.color ?? Color.gray.opacity(0.5)
    }

    private func currencySymbol() -> String {
        switch selectedCurrency {
        case "USD":
            return "$"
        case "EUR":
            return "€"
        case "RUB":
            return "₽"
        case "UZS":
            return "UZS "
        case "GBP":
            return "£"
        case "JPY":
            return "¥"
        case "CNY":
            return "¥"
        default:
            return "$"
        }
    }
}

struct TransactionCountView: View {
    let count: Int

    var body: some View {
        Text("Number of transactions: \(count)")
            .font(.headline)
            .padding(.horizontal)
    }
}

struct CategoryLegendView: View {
    let categories: [CategoryInfo]

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ForEach(categories) { category in
                HStack {
                    Circle()
                        .fill(category.color)
                        .frame(width: 10, height: 10)
                    Text(category.name)
                        .font(.caption)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct TransactionChartView: View {
    let groupedTransactions: [(key: String, value: Double)]
    let colorForCategory: (String) -> Color
    let currencySymbol: String

    private var yDomain: ClosedRange<Double> {
        let minValue = groupedTransactions.map { $0.value }.min() ?? 0.0
        let maxValue = groupedTransactions.map { $0.value }.max() ?? 0.0
        let lowerBound = (minValue * 1.2).rounded(.down)
        let upperBound = (maxValue * 1.2).rounded(.up)
        return lowerBound...upperBound
    }

    var body: some View {
        if !groupedTransactions.isEmpty {
            Chart {
                ForEach(groupedTransactions, id: \.key) { category, total in
                    BarMark(
                        x: .value("Category", category),
                        y: .value("Amount", total)
                    )
                    .foregroundStyle(colorForCategory(category))
                }
            }
            .chartYScale(domain: yDomain)
            .chartPlotStyle { plotArea in
                plotArea
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(15)
            }
            .padding(.horizontal)
        } else {
            Text("No transactions in the selected period.")
                .foregroundColor(.gray)
                .padding(.horizontal)
        }
    }
}

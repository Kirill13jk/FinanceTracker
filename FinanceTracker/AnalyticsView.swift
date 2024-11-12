import SwiftUI
import Charts
import SwiftData

struct AnalyticsView: View {
    @State private var selectedStartDate: Date = {
        Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    }()
    @State private var selectedEndDate: Date = Date()
    @AppStorage("titleOn") private var titleOn: Bool = true
    @AppStorage("selectedCurrency") private var selectedCurrency: String = "USD"

    // Указываем тип модели в ключевом пути
    @Query(sort: \Transaction.date, order: .reverse) private var allTransactions: [Transaction]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                DatePicker("Start Date", selection: $selectedStartDate, displayedComponents: .date)
                    .padding(.horizontal)

                DatePicker("End Date", selection: $selectedEndDate, displayedComponents: .date)
                    .padding(.horizontal)

                TransactionCountView(count: transactions.count)

                CategoryLegendView(categories: categoriesInfo)

                TransactionChartView(
                    groupedTransactions: groupedTransactions,
                    colorForCategory: colorForCategory,
                    currencySymbol: currencySymbol()
                )
            }
            .padding(.top)
        }
        .navigationTitle(titleOn ? "Analytics" : "")
        .onAppear {
            print("Total transactions fetched: \(allTransactions.count)")
            print("Transactions after date filter: \(transactions.count)")
        }
    }

    // Используем вычисляемое свойство для фильтрации транзакций по выбранным датам
    private var transactions: [Transaction] {
        allTransactions.filter { transaction in
            transaction.date >= selectedStartDate && transaction.date <= selectedEndDate.endOfDay()
        }
    }

    private var groupedTransactions: [(category: String, income: Double, expense: Double)] {
        let grouped = Dictionary(grouping: transactions) { $0.category }
        let result = grouped.map { (category: $0.key,
                                    income: $0.value.filter { !$0.isExpense }.reduce(0) { $0 + $1.amount },
                                    expense: $0.value.filter { $0.isExpense }.reduce(0) { $0 + $1.amount })
        }
        print("Grouped Transactions: \(result)")
        return result
    }

    private func colorForCategory(_ categoryName: String) -> Color {
        categoriesInfo.first { $0.name == categoryName }?.color ?? Color.gray.opacity(0.5)
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

extension Date {
    func endOfDay() -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: Calendar.current.startOfDay(for: self))!
    }
}

// Подвид для отображения количества транзакций
struct TransactionCountView: View {
    let count: Int

    var body: some View {
        Text("Number of transactions: \(count)")
            .font(.headline)
            .padding(.horizontal)
    }
}

// Подвид для отображения легенды категорий
struct CategoryLegendView: View {
    let categories: [CategoryInfo]

    var body: some View {
        let columns = [GridItem(.adaptive(minimum: 80), spacing: 8)]
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(categories) { category in
                HStack(spacing: 4) {
                    Circle()
                        .fill(category.color)
                        .frame(width: 10, height: 10)
                    Text(category.name)
                        .font(.caption)
                }
                .padding(4)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(.horizontal)
    }
}

// Подвид для отображения графика транзакций
struct TransactionChartView: View {
    let groupedTransactions: [(category: String, income: Double, expense: Double)]
    let colorForCategory: (String) -> Color
    let currencySymbol: String

    private var yDomain: ClosedRange<Double> {
        let maxIncome = groupedTransactions.map { $0.income }.max() ?? 0.0
        let maxExpense = groupedTransactions.map { $0.expense }.max() ?? 0.0
        let upperBound = (maxIncome * 1.2).rounded(.up)
        let lowerBound = -(maxExpense * 1.2).rounded(.up)
        return lowerBound...upperBound
    }

    var body: some View {
        if !groupedTransactions.isEmpty {
            Chart {
                ForEach(groupedTransactions, id: \.category) { data in
                    if data.income > 0 {
                        BarMark(
                            x: .value("Category", data.category),
                            y: .value("Income", data.income)
                        )
                        .foregroundStyle(colorForCategory(data.category))
                    }
                    if data.expense > 0 {
                        BarMark(
                            x: .value("Category", data.category),
                            y: .value("Expense", -data.expense)
                        )
                        .foregroundStyle(colorForCategory(data.category))
                    }
                }
            }
            .chartYScale(domain: yDomain)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartPlotStyle { plotArea in
                plotArea
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(15)
            }
            .padding(.horizontal)
            .frame(height: 300)
        } else {
            Text("No transactions in the selected period.")
                .foregroundColor(.gray)
                .padding(.horizontal)
        }
    }
}

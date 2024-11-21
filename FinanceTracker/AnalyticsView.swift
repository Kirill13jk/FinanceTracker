// AnalyticsView.swift

import SwiftUI
import Charts
import SwiftData


struct AnalyticsView: View {
    @State private var selectedStartDate: Date = {
        Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date()
    }()
    @State private var selectedEndDate: Date = Date()
    @AppStorage("titleOn") private var titleOn: Bool = true
    @AppStorage("selectedCurrency") private var selectedCurrency: String = "USD"

    @Query(sort: \Transaction.date, order: .reverse) private var allTransactions: [Transaction]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Выбор дат
                HStack {
                    VStack(alignment: .leading) {
                        Text("Start Date")
                            .font(.caption)
                        DatePicker("", selection: $selectedStartDate, displayedComponents: .date)
                            .labelsHidden()
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading) {
                        Text("End Date")
                            .font(.caption)
                        DatePicker("", selection: $selectedEndDate, displayedComponents: .date)
                            .labelsHidden()
                    }
                    .padding(.horizontal)
                }

                // Отображение общей суммы баланса
                TotalBalanceView(totalBalance: totalBalance(), currencySymbol: currencySymbol())

                // Отображение количества транзакций
                TransactionCountView(count: transactions.count)

                // График месячных трендов
                MonthlyTrendsChartView(monthlyData: monthlyData(), currencySymbol: currencySymbol())

                // Легенда категорий
                CategoryLegendView(categories: categoriesInfo)

                // График транзакций по категориям
                TransactionChartView(
                    groupedTransactions: groupedTransactions,
                    colorForCategory: colorForCategory,
                    currencySymbol: currencySymbol()
                )
            }
            .padding(.top)
        }
        .navigationTitle(titleOn ? "Analytics" : "")
    }

    // Фильтрация транзакций по выбранным датам
    private var transactions: [Transaction] {
        allTransactions.filter { transaction in
            transaction.date >= selectedStartDate && transaction.date <= selectedEndDate.endOfDay()
        }
    }

    // Группировка транзакций по категориям
    private var groupedTransactions: [(category: String, income: Double, expense: Double)] {
        let grouped = Dictionary(grouping: transactions) { $0.category }
        return grouped.map { (category: $0.key,
                              income: $0.value.filter { !$0.isExpense }.reduce(0) { $0 + $1.amount },
                              expense: $0.value.filter { $0.isExpense }.reduce(0) { $0 + $1.amount })
        }
    }

    // Вычисление общего баланса
    private func totalBalance() -> Double {
        let incomes = transactions.filter { !$0.isExpense }.reduce(0) { $0 + $1.amount }
        let expenses = transactions.filter { $0.isExpense }.reduce(0) { $0 + $1.amount }
        return incomes - expenses
    }

    // Подготовка данных для месячных трендов
    private func monthlyData() -> [MonthlyData] {
        let calendar = Calendar.current

        guard let startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedStartDate)),
              let endDate = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedEndDate)) else {
            return []
        }

        var date = startDate
        var months: [Date] = []
        while date <= endDate {
            months.append(date)
            date = calendar.date(byAdding: .month, value: 1, to: date)!
        }

        var monthlyData: [MonthlyData] = []
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"

        for month in months {
            let monthTransactions = transactions.filter {
                calendar.isDate($0.date, equalTo: month, toGranularity: .month)
            }
            let income = monthTransactions.filter { !$0.isExpense }.reduce(0) { $0 + $1.amount }
            let expense = monthTransactions.filter { $0.isExpense }.reduce(0) { $0 + $1.amount }

            monthlyData.append(MonthlyData(month: month, income: income, expense: expense))
        }

        return monthlyData
    }

    // Определение цвета для категории
    private func colorForCategory(_ categoryName: String) -> Color {
        categoriesInfo.first { $0.name == categoryName }?.color ?? Color.gray.opacity(0.5)
    }

    // Получение символа валюты
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

    // Вычисляемое свойство для информации о категориях
    private var categoriesInfo: [CategoryInfo] {
        let categories = transactions.map { $0.category }
        let uniqueCategories = Set(categories)
        return uniqueCategories.map { category in
            CategoryInfo(name: category, color: assignColor(for: category))
        }
    }

    // Функция для присвоения цвета категории
    private func assignColor(for category: String) -> Color {
        // Можно расширить список категорий и цветов по необходимости
        switch category.lowercased() {
        case "food":
            return .blue
        case "transport":
            return .green
        case "entertainment":
            return .purple
        case "health":
            return .red
        case "shopping":
            return .orange
        case "utilities":
            return .pink
        default:
            return .gray
        }
    }
}

// Расширение Date для получения конца дня
extension Date {
    func endOfDay() -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: Calendar.current.startOfDay(for: self))!
    }
}

// Подвид для отображения общего баланса
struct TotalBalanceView: View {
    let totalBalance: Double
    let currencySymbol: String

    var body: some View {
        VStack(alignment: .leading) {
            Text("Total Balance for the Period")
                .font(.headline)
            Text("\(currencySymbol)\(totalBalance, specifier: "%.2f")")
                .font(.largeTitle)
                .foregroundColor(totalBalance >= 0 ? .green : .red)
        }
        .padding(.horizontal)
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

// Подвид для отображения графика транзакций по категориям
struct TransactionChartView: View {
    let groupedTransactions: [(category: String, income: Double, expense: Double)]
    let colorForCategory: (String) -> Color
    let currencySymbol: String

    private var yDomain: ClosedRange<Double> {
        let maxIncome = groupedTransactions.map { $0.income }.max() ?? 0.0
        let maxExpense = groupedTransactions.map { $0.expense }.max() ?? 0.0
        let upperBound = (max(maxIncome, abs(maxExpense)) * 1.2).rounded(.up)
        return -upperBound...upperBound
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
            .chartYScale(domain: yDomain) // Синхронизация оси Y
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartXAxis {
                AxisMarks(position: .bottom)
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

// Структура для месячных данных
struct MonthlyData: Identifiable {
    let id = UUID()
    let month: Date
    let income: Double
    let expense: Double
}

// Подвид для отображения графика месячных трендов
struct MonthlyTrendsChartView: View {
    let monthlyData: [MonthlyData]
    let currencySymbol: String

    var body: some View {
        if !monthlyData.isEmpty {
            Chart {
                ForEach(monthlyData) { data in
                    LineMark(
                        x: .value("Month", data.month),
                        y: .value("Income", data.income)
                    )
                    .foregroundStyle(Color.green)
                    .symbol(Circle())
                    .interpolationMethod(.catmullRom)

                    LineMark(
                        x: .value("Month", data.month),
                        y: .value("Expense", data.expense)
                    )
                    .foregroundStyle(Color.red)
                    .symbol(Circle())
                    .interpolationMethod(.catmullRom)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartXAxis {
                AxisMarks(format: .dateTime.month().year()) // Форматирование оси X для отображения месяцев и годов
            }
            .padding(.horizontal)
            .frame(height: 300)
            .chartLegend {
                HStack {
                    Circle().fill(Color.green).frame(width: 10, height: 10)
                    Text("Income")
                    Circle().fill(Color.red).frame(width: 10, height: 10)
                    Text("Expense")
                }
            }
        } else {
            Text("No data for the selected period.")
                .foregroundColor(.gray)
                .padding(.horizontal)
        }
    }
}

// Расширение для форматирования дат (опционально)
extension DateFormatter {
    static var shortDate: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
}

import SwiftUI
import Charts
import SwiftData

struct AnalyticsView: View {
    // MARK: - State Variables
    @State private var selectedStartDate: Date = {
        Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date()
    }()
    @State private var selectedEndDate: Date = Date()
    @AppStorage("selectedCurrency") private var selectedCurrency: String = "USD"

    @Query(sort: \Transaction.date, order: .reverse) private var allTransactions: [Transaction]

    @Environment(\.verticalSizeClass) var verticalSizeClass

    // MARK: - CategoryInfo Structure
    struct CategoryInfo: Identifiable {
        let id = UUID()
        let name: String
        let color: Color
    }

    // MARK: - Categories Information
    let categoriesInfo: [CategoryInfo] = [
        // Доходы (Income)
        CategoryInfo(name: "Work", color: Color.blue.opacity(0.5)),
        CategoryInfo(name: "Business", color: Color.green.opacity(0.5)),
        CategoryInfo(name: "Deposit", color: Color.purple.opacity(0.5)),
        CategoryInfo(name: "Friend", color: Color.orange.opacity(0.5)),
        // Расходы (Expenses)
        CategoryInfo(name: "Food", color: Color.red.opacity(0.5)),
        CategoryInfo(name: "Transport", color: Color.blue.opacity(0.5)),
        CategoryInfo(name: "Housing", color: Color.green.opacity(0.5)),
        CategoryInfo(name: "Entertainment", color: Color.purple.opacity(0.5)),
        CategoryInfo(name: "Health", color: Color.orange.opacity(0.5)),
        CategoryInfo(name: "Other", color: Color.gray.opacity(0.5))
    ]

    // MARK: - Selected Category for Detail View
    @State private var selectedCategory: CategoryData? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: verticalSizeClass == .compact ? 10 : 20) {
                // Date Pickers
                datePickers

                // Total Balance View
                TotalBalanceView(totalBalance: totalBalance(), currencySymbol: currencySymbol())

                // Transaction Count View
                TransactionCountView(count: transactions.count)

                // Line Chart View
                LineChartView(dataPoints: lineChartData(), currencySymbol: currencySymbol())
                    .frame(height: chartHeight())
                    .padding(.horizontal)

                // Donut Charts for Income and Expenses
                if !incomeCategoryData().isEmpty {
                    Text("Income Breakdown")
                        .font(.headline)
                        .padding(.horizontal)

                    DonutChartView(
                        data: incomeCategoryData(),
                        totalAmount: totalIncome(),
                        categoriesInfo: categoriesInfo
                    ) { category in
                        selectedCategory = category
                    }
                    .frame(height: chartHeight())
                } else {
                    Text("No income data for the selected period.")
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }

                if !expenseCategoryData().isEmpty {
                    Text("Expense Breakdown")
                        .font(.headline)
                        .padding(.horizontal)

                    DonutChartView(
                        data: expenseCategoryData(),
                        totalAmount: totalExpense(),
                        categoriesInfo: categoriesInfo
                    ) { category in
                        selectedCategory = category
                    }
                    .frame(height: chartHeight())
                } else {
                    Text("No expense data for the selected period.")
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
            }
            .padding(.top)
            .padding(.horizontal)
        }
        .navigationTitle("Analytics")
        // Sheet for Transaction Details
        .sheet(item: $selectedCategory) { category in
            TransactionDetailView(category: category, transactions: transactionsForCategory(category))
        }
    }

    // MARK: - Date Pickers View
    private var datePickers: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Start Date")
                    .font(.caption)
                DatePicker("", selection: $selectedStartDate, in: ...selectedEndDate, displayedComponents: .date)
                    .labelsHidden()
            }

            Spacer()

            VStack(alignment: .leading) {
                Text("End Date")
                    .font(.caption)
                DatePicker("", selection: $selectedEndDate, in: selectedStartDate..., displayedComponents: .date)
                    .labelsHidden()
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Filtered Transactions
    private var transactions: [Transaction] {
        allTransactions.filter { transaction in
            transaction.date >= selectedStartDate && transaction.date <= selectedEndDate.endOfDay()
        }
    }

    // MARK: - Total Balance Calculation
    private func totalBalance() -> Double {
        let incomes = transactions.filter { !$0.isExpense }.reduce(0) { $0 + $1.amount }
        let expenses = transactions.filter { $0.isExpense }.reduce(0) { $0 + $1.amount }
        return incomes - expenses
    }

    // MARK: - Total Income
    private func totalIncome() -> Double {
        transactions.filter { !$0.isExpense }.reduce(0) { $0 + $1.amount }
    }

    // MARK: - Total Expense
    private func totalExpense() -> Double {
        transactions.filter { $0.isExpense }.reduce(0) { $0 + $1.amount }
    }

    // MARK: - Line Chart Data Preparation
    private func lineChartData() -> [ChartDataPoint] {
        let calendar = Calendar.current
        var dataPoints: [ChartDataPoint] = []

        let dateRange = DateInterval(start: selectedStartDate, end: selectedEndDate)
        let dates = dateRange.datesInRange

        for date in dates {
            let dayTransactions = transactions.filter {
                calendar.isDate($0.date, inSameDayAs: date)
            }
            let income = dayTransactions.filter { !$0.isExpense }.reduce(0) { $0 + $1.amount }
            let expense = dayTransactions.filter { $0.isExpense }.reduce(0) { $0 + $1.amount }

            dataPoints.append(ChartDataPoint(date: date, income: income, expense: expense))
        }

        return dataPoints
    }

    // MARK: - Income Category Data Preparation
    private func incomeCategoryData() -> [CategoryData] {
        let incomes = transactions.filter { !$0.isExpense }
        let grouped = Dictionary(grouping: incomes, by: { $0.category })
        let totalIncome = incomes.reduce(0) { $0 + $1.amount }
        return grouped.map { (category, transactions) in
            let total = transactions.reduce(0) { $0 + $1.amount }
            let percentage = total / totalIncome
            return CategoryData(category: category, amount: total, percentage: percentage)
        }
    }

    // MARK: - Expense Category Data Preparation
    private func expenseCategoryData() -> [CategoryData] {
        let expenses = transactions.filter { $0.isExpense }
        let grouped = Dictionary(grouping: expenses, by: { $0.category })
        let totalExpense = expenses.reduce(0) { $0 + $1.amount }
        return grouped.map { (category, transactions) in
            let total = transactions.reduce(0) { $0 + $1.amount }
            let percentage = total / totalExpense
            return CategoryData(category: category, amount: total, percentage: percentage)
        }
    }

    // MARK: - Currency Symbol Helper
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

    // MARK: - Chart Height Helper
    private func chartHeight() -> CGFloat {
        if verticalSizeClass == .compact {
            return 200
        } else {
            return 300
        }
    }

    // MARK: - Transactions for Selected Category
    private func transactionsForCategory(_ category: CategoryData) -> [Transaction] {
        transactions.filter { $0.category == category.category }
    }
}


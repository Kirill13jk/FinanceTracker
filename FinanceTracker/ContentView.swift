import SwiftUI
import Charts
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var transactions: [Transaction]
    @AppStorage("titleOn") private var titleOn: Bool = true
    @AppStorage("selectedCurrency") private var selectedCurrency: String = "USD"

    @State private var selectedType: String = "All"
    @State private var selectedMonth: String = "All"

    var body: some View {
        VStack(spacing: 20) {
            VStack {
                Text("Total Balance")
                    .font(.headline)
                    .foregroundColor(.gray)
                Text("\(currencySymbol())\(totalBalance(), specifier: "%.2f")")
                    .font(.largeTitle)
                    .bold()
            }

            HStack(spacing: 20) {
                Picker("Type", selection: $selectedType) {
                    Text("All").tag("All")
                    Text("Expenses").tag("Expenses")
                    Text("Income").tag("Income")
                }
                .pickerStyle(SegmentedPickerStyle())

                Picker("Month", selection: $selectedMonth) {
                    Text("All").tag("All")
                    ForEach(months(), id: \.self) { month in
                        Text(month).tag(month)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            .padding(.horizontal)

            Chart {
                ForEach(groupedTransactions(), id: \.key) { day, amount in
                    BarMark(
                        x: .value("Day", day),
                        y: .value("Amount", amount)
                    )
                    .foregroundStyle(Color.blue)
                }
            }
            .chartYAxis(.hidden)
            .frame(height: 150)
            .padding(.horizontal)

            HStack(spacing: 20) {
                SummaryView(title: "Today", amount: totalForPeriod(.today))
                SummaryView(title: "Week", amount: totalForPeriod(.week))
                SummaryView(title: "Month", amount: totalForPeriod(.month))
            }

            List {
                ForEach(filteredTransactions()) { transaction in
                    HStack {
                        Circle()
                            .fill(colorForCategory(transaction.category))
                            .frame(width: 10, height: 10)
                        VStack(alignment: .leading) {
                            Text(transaction.category)
                                .font(.headline)
                            Text(transaction.note ?? "")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("\(currencySymbol())\(transaction.amount, specifier: "%.2f")")
                                .font(.headline)
                                .foregroundColor(transaction.isExpense ? .red : .green)
                            Text(transaction.date, style: .date)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .onDelete(perform: deleteTransaction)
            }
            .listStyle(PlainListStyle())
        }
        .navigationTitle(titleOn ? NSLocalizedString("main_title", comment: "") : "")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: AddTransactionView()) {
                    Image(systemName: "plus")
                }
            }
        }
        .padding(.top)
    }

    private func totalBalance() -> Double {
        let incomes = transactions.filter { !$0.isExpense }.reduce(0) { $0 + $1.amount }
        let expenses = transactions.filter { $0.isExpense }.reduce(0) { $0 + $1.amount }
        return incomes - expenses
    }

    private func filteredTransactions() -> [Transaction] {
        var filtered = transactions

        if selectedType != "All" {
            let isExpense = selectedType == "Expenses"
            filtered = filtered.filter { $0.isExpense == isExpense }
        }

        if selectedMonth != "All" {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM"
            filtered = filtered.filter {
                dateFormatter.string(from: $0.date) == selectedMonth
            }
        }

        return filtered.sorted(by: { $0.date > $1.date })
    }

    private func months() -> [String] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        let months = Set(transactions.map { dateFormatter.string(from: $0.date) })
        return months.sorted()
    }

    private func groupedTransactions() -> [(key: Int, value: Double)] {
        let calendar = Calendar.current
        let filtered = filteredTransactions()
        let grouped = Dictionary(grouping: filtered) { transaction in
            calendar.component(.day, from: transaction.date)
        }
        return grouped.map { (key: $0.key, value: $0.value.reduce(0) { $0 + $1.amount }) }
    }

    private func totalForPeriod(_ period: Period) -> Double {
        let calendar = Calendar.current
        let filtered: [Transaction]
        switch period {
        case .today:
            filtered = transactions.filter {
                calendar.isDateInToday($0.date)
            }
        case .week:
            filtered = transactions.filter {
                calendar.isDate($0.date, equalTo: Date(), toGranularity: .weekOfYear)
            }
        case .month:
            filtered = transactions.filter {
                calendar.isDate($0.date, equalTo: Date(), toGranularity: .month)
            }
        }
        return filtered.reduce(0) { $0 + ($1.isExpense ? -$1.amount : $1.amount) }
    }

    private func deleteTransaction(at offsets: IndexSet) {
        for index in offsets {
            let transaction = filteredTransactions()[index]
            modelContext.delete(transaction)
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

    enum Period {
        case today, week, month
    }
}

struct SummaryView: View {
    let title: String
    let amount: Double
    @AppStorage("selectedCurrency") private var selectedCurrency: String = "USD"

    var body: some View {
        VStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Text("\(currencySymbol())\(abs(amount), specifier: "%.0f")")
                .font(.headline)
                .bold()
                .foregroundColor(amount >= 0 ? .green : .red)
        }
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

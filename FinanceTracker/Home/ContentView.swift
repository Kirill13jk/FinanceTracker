import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var transactions: [Transaction]
    @AppStorage("titleOn") private var titleOn: Bool = true
    @AppStorage("selectedCurrency") private var selectedCurrency: String = "USD"

    @State private var selectedType: String = "All"
    @State private var selectedMonth: String = "All"

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack {
                    Text("Total Balance")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("\(currencySymbol(selectedCurrency: selectedCurrency))\(totalBalance(), specifier: "%.2f")")
                        .font(.largeTitle)
                        .bold()
                }

                VStack(spacing: 10) {
                    Picker("Type", selection: $selectedType) {
                        Text("All").tag("All")
                        Text("Expenses").tag("Expenses")
                        Text("Income").tag("Income")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    Picker("Month", selection: $selectedMonth) {
                        Text("All").tag("All")
                        ForEach(months(), id: \.self) { month in
                            Text(month).tag(month)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.horizontal)
                }

                let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

                LazyVGrid(columns: columns, spacing: 20) {
                    SummaryView(title: "Today", amount: totalForPeriod(.today))
                    SummaryView(title: "Week", amount: totalForPeriod(.week))
                    SummaryView(title: "Month", amount: totalForPeriod(.month))
                }
                .padding(.horizontal)

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
                            Text("\(currencySymbol(selectedCurrency: selectedCurrency))\(transaction.amount, specifier: "%.2f")")
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
            .padding(.top)
            .padding(.horizontal)
        }
        .navigationTitle(titleOn ? NSLocalizedString("main_title", comment: "") : "")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: AddTransactionView()) {
                    Image(systemName: "plus")
                }
            }
        }
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

    private var categoriesInfo: [CategoryInfo] {
        let categories = transactions.map { $0.category }
        let uniqueCategories = Set(categories)
        return uniqueCategories.map { category in
            CategoryInfo(name: category, color: assignColor(for: category))
        }
    }
}

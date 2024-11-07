import SwiftUI
import Charts
import SwiftData

struct AnalyticsView: View {
    @Query private var transactions: [Transaction]
    @State private var selectedStartDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
    @State private var selectedEndDate: Date = Date()
    @AppStorage("titleOn") private var titleOn: Bool = true

    var body: some View {
        VStack {
            DatePicker(NSLocalizedString("start_period", comment: ""), selection: $selectedStartDate, displayedComponents: .date)
                .padding()
            DatePicker(NSLocalizedString("end_period", comment: ""), selection: $selectedEndDate, displayedComponents: .date)
                .padding()
            
            Text(String(format: NSLocalizedString("number_of_transactions_in_period", comment: ""), filteredTransactions.count))
                .padding()
            
            HStack {
                Circle()
                    .fill(Color.red)
                    .frame(width: 10, height: 10)
                Text(NSLocalizedString("expenses", comment: ""))
                    .font(.caption)
                Circle()
                    .fill(Color.green)
                    .frame(width: 10, height: 10)
                Text(NSLocalizedString("incomes", comment: ""))
                    .font(.caption)
            }
            .padding(.bottom, 5)
            
            Chart {
                ForEach(groupedExpenses, id: \.key) { category, total in
                    BarMark(
                        x: .value(NSLocalizedString("category", comment: ""), category),
                        y: .value(NSLocalizedString("amount", comment: ""), total)
                    )
                    .foregroundStyle(Color.red)
                }
                ForEach(groupedIncomes, id: \.key) { category, total in
                    BarMark(
                        x: .value(NSLocalizedString("category", comment: ""), category),
                        y: .value(NSLocalizedString("amount", comment: ""), total)
                    )
                    .foregroundStyle(Color.green)
                }
            }
            .chartPlotStyle { plotArea in
                plotArea
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(15)
                    .shadow(radius: 5)
            }
            .padding()
        }
        .navigationTitle(titleOn ? NSLocalizedString("analytics", comment: "") : "")
        .onAppear {
            print("Grouped Expenses: \(groupedExpenses)")
            print("Grouped Incomes: \(groupedIncomes)")
        }
    }

    private var filteredTransactions: [Transaction] {
        transactions.filter { $0.date >= selectedStartDate && $0.date <= selectedEndDate }
    }

    private var groupedExpenses: [(key: String, value: Double)] {
        let expenses = filteredTransactions.filter { $0.isExpense }
        let grouped = Dictionary(grouping: expenses) { $0.category }
        return grouped.map { (key: $0.key, value: $0.value.reduce(0) { $0 + $1.amount }) }
    }

    private var groupedIncomes: [(key: String, value: Double)] {
        let incomes = filteredTransactions.filter { !$0.isExpense }
        let grouped = Dictionary(grouping: incomes) { $0.category }
        return grouped.map { (key: $0.key, value: $0.value.reduce(0) { $0 + $1.amount }) }
    }
}

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var transactions: [Transaction]
    @Query private var budgets: [Budget]
    @AppStorage("titleOn") private var titleOn: Bool = true

    var body: some View {
        VStack {
            if let currentBudget = budgets.first(where: { $0.startDate <= Date() && $0.endDate >= Date() }) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(String(format: NSLocalizedString("budget_for_period", comment: ""), currentBudget.amount))
                        .font(.headline)
                    Text(String(format: NSLocalizedString("remaining_budget", comment: ""), remainingBudget(currentBudget)))
                        .font(.subheadline)
                }
                .padding()
            }
            
            Text(String(format: NSLocalizedString("number_of_transactions", comment: ""), transactions.count))
                .padding()

            Button(NSLocalizedString("add_test_transaction", comment: "")) {
                let testTransaction = Transaction(
                    amount: 100.0,
                    category: NSLocalizedString("test", comment: ""),
                    date: Date(),
                    note: NSLocalizedString("test_transaction_note", comment: ""),
                    isExpense: true
                )
                modelContext.insert(testTransaction)
                print(NSLocalizedString("test_transaction_added", comment: ""))
            }
            .padding()
            
            List {
                ForEach(transactions) { transaction in
                    TransactionRow(transaction: transaction)
                }
                .onDelete(perform: deleteTransaction)
            }
            .listStyle(PlainListStyle())
            .navigationTitle(titleOn ? NSLocalizedString("main_title", comment: "") : "")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddTransactionView()) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .onChange(of: transactions) { oldValue, newValue in
            print(String(format: NSLocalizedString("number_of_transactions_updated", comment: ""), newValue.count))
        }
    }

    private func deleteTransaction(at offsets: IndexSet) {
        for index in offsets {
            let transaction = transactions[index]
            modelContext.delete(transaction)
        }
    }
    
    private func remainingBudget(_ budget: Budget) -> Double {
        let expenses = transactions
            .filter { $0.date >= budget.startDate && $0.date <= budget.endDate && $0.isExpense }
            .reduce(0) { $0 + $1.amount }
        let incomes = transactions
            .filter { $0.date >= budget.startDate && $0.date <= budget.endDate && !$0.isExpense }
            .reduce(0) { $0 + $1.amount }
        return budget.amount - expenses + incomes
    }
}

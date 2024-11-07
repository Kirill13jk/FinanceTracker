import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var transactions: [Transaction]
    @Query private var budgets: [Budget]

    var body: some View {
        VStack {
            if let currentBudget = budgets.first(where: { $0.startDate <= Date() && $0.endDate >= Date() }) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Бюджет на период: \(currentBudget.amount, specifier: "%.2f") UZS")
                        .font(.headline)
                    Text("Оставшийся бюджет: \(remainingBudget(currentBudget), specifier: "%.2f") UZS")
                        .font(.subheadline)
                }
                .padding()
            }
            
            Text("Количество транзакций: \(transactions.count)")
                .padding()

            Button("Добавить тестовую транзакцию") {
                let testTransaction = Transaction(
                    amount: 100.0,
                    category: "Тест",
                    date: Date(),
                    note: "Тестовая транзакция",
                    isExpense: true
                )
                modelContext.insert(testTransaction)
                print("Тестовая транзакция добавлена")
            }
            .padding()
            
            List {
                ForEach(transactions) { transaction in
                    TransactionRow(transaction: transaction)
                }
                .onDelete(perform: deleteTransaction)
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Мои финансы")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddTransactionView()) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .onChange(of: transactions) { oldValue, newValue in
            print("Обновлено количество транзакций: \(newValue.count)")
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

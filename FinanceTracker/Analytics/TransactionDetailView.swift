import SwiftUI

struct TransactionDetailView: View {
    let category: CategoryData
    let transactions: [Transaction]

    var body: some View {
        NavigationView {
            List(transactions) { transaction in
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(transaction.category)
                            .font(.headline)
                        Spacer()
                        Text("\(transaction.isExpense ? "-" : "+")\(transaction.amount, specifier: "%.2f")")
                            .foregroundColor(transaction.isExpense ? .red : .green)
                    }
                    Text("\(transaction.date, formatter: dateFormatter)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    if let note = transaction.note, !note.isEmpty {
                        Text(note)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("\(category.category) Transactions")
            .navigationBarItems(trailing: Button("Done") {
                // Automatic dismissal
            })
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

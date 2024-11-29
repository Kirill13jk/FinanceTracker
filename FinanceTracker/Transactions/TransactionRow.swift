import SwiftUI

struct TransactionRow: View {
    var transaction: Transaction

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(transaction.category)
                    .font(.headline)
                if let note = transaction.note {
                    Text(note)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            Text("\(transaction.isExpense ? "-" : "+")\(transaction.amount, specifier: "%.2f") UZS")
                .font(.headline)
                .foregroundColor(transaction.isExpense ? .red : .green)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}

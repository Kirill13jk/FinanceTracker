import SwiftUI
import SwiftData

struct AddTransactionView: View {
    private let categories = NSLocalizedString("categories", comment: "").components(separatedBy: ",")

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var amount: String = ""
    @State private var category: String = ""
    @State private var date: Date = Date()
    @State private var note: String = ""
    @State private var isExpense: Bool = true

    var body: some View {
        Form {
            Section(header: Text(NSLocalizedString("transaction_type", comment: ""))) {
                Picker(NSLocalizedString("select_type", comment: ""), selection: $isExpense) {
                    Text(NSLocalizedString("expense", comment: "")).tag(true)
                    Text(NSLocalizedString("income", comment: "")).tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            Section(header: Text(NSLocalizedString("amount", comment: ""))) {
                TextField(NSLocalizedString("enter_amount", comment: ""), text: $amount)
                    .keyboardType(.decimalPad)
            }
            Section(header: Text(NSLocalizedString("category", comment: ""))) {
                Picker(NSLocalizedString("select_category", comment: ""), selection: $category) {
                    ForEach(categories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
            }
            Section(header: Text(NSLocalizedString("date", comment: ""))) {
                DatePicker(NSLocalizedString("select_date", comment: ""), selection: $date, displayedComponents: .date)
            }
            Section(header: Text(NSLocalizedString("note", comment: ""))) {
                TextField(NSLocalizedString("add_note_optional", comment: ""), text: $note)
            }
        }
        .navigationTitle(NSLocalizedString("new_transaction", comment: ""))
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(NSLocalizedString("cancel", comment: "")) {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(NSLocalizedString("save", comment: "")) {
                    saveTransaction()
                }
            }
        }
    }

    private func saveTransaction() {
        print(NSLocalizedString("save_transaction_called", comment: ""))

        guard let amountValue = Double(amount), !category.isEmpty else {
            print(String(format: NSLocalizedString("invalid_input", comment: ""), amount, category))
            return
        }

        let newTransaction = Transaction(
            amount: amountValue,
            category: category,
            date: date,
            note: note.isEmpty ? nil : note,
            isExpense: isExpense
        )
        modelContext.insert(newTransaction)

        print(NSLocalizedString("transaction_added", comment: ""))

        dismiss()
    }
}

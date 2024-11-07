import SwiftUI
import SwiftData

struct BudgetView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var amount: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date())!

    var body: some View {
        Form {
            Section(header: Text(NSLocalizedString("budget_amount", comment: ""))) {
                TextField(NSLocalizedString("enter_amount", comment: ""), text: $amount)
                    .keyboardType(.decimalPad)
            }
            Section(header: Text(NSLocalizedString("period", comment: ""))) {
                DatePicker(NSLocalizedString("start_date", comment: ""), selection: $startDate, displayedComponents: .date)
                DatePicker(NSLocalizedString("end_date", comment: ""), selection: $endDate, displayedComponents: .date)
            }
            Button(NSLocalizedString("save", comment: "")) {
                saveBudget()
            }
        }
        .navigationTitle(NSLocalizedString("set_budget", comment: ""))
    }

    private func saveBudget() {
        guard let amountValue = Double(amount) else { return }
        let budget = Budget(amount: amountValue, startDate: startDate, endDate: endDate)
        modelContext.insert(budget)
    }
}

import SwiftUI
import SwiftData

struct BudgetView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var amount: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date())!

    var body: some View {
        Form {
            Section(header: Text("Сумма бюджета")) {
                TextField("Введите сумму", text: $amount)
                    .keyboardType(.decimalPad)
            }
            Section(header: Text("Период")) {
                DatePicker("Начало", selection: $startDate, displayedComponents: .date)
                DatePicker("Конец", selection: $endDate, displayedComponents: .date)
            }
            Button("Сохранить") {
                saveBudget()
            }
        }
        .navigationTitle("Установка бюджета")
    }

    private func saveBudget() {
        guard let amountValue = Double(amount) else { return }
        let budget = Budget(amount: amountValue, startDate: startDate, endDate: endDate)
        modelContext.insert(budget)
    }
}

import SwiftUI
import SwiftData

struct AddGoalView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage("selectedCurrency") private var selectedCurrency: String = "USD"

    @State private var title: String = ""
    @State private var targetAmount: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Calendar.current.date(byAdding: .month, value: 6, to: Date())!

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Goal Details")) {
                    TextField("Title", text: $title)
                    TextField("Target Amount", text: $targetAmount)
                        .keyboardType(.decimalPad)
                }

                Section(header: Text("Timeframe")) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                }

                Button("Save") {
                    saveGoal()
                }
            }
            .navigationTitle("Add New Goal")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }

    private func saveGoal() {
        guard let amount = Double(targetAmount), !title.isEmpty else {
            print("Invalid input")
            return
        }

        let newGoal = Goal(
            title: title,
            targetAmount: amount,
            startDate: startDate,
            endDate: endDate
        )
        modelContext.insert(newGoal)

        do {
            try modelContext.save()
            print("Goal saved: \(newGoal)")
            dismiss()
        } catch {
            print("Error saving goal: \(error)")
        }
    }
}

// AddGoalView.swift

import SwiftUI
import SwiftData

struct AddGoalView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var targetAmount: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Calendar.current.date(byAdding: .month, value: 6, to: Date())!
    @State private var selectedColorName: String = "blue" // Цвет по умолчанию

    let availableColors: [String] = ["red", "blue", "green", "purple", "orange", "gray"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Детали цели")) {
                    TextField("Название", text: $title)
                    TextField("Желаемая сумма", text: $targetAmount)
                        .keyboardType(.decimalPad)

                    Picker("Выберите цвет", selection: $selectedColorName) {
                        ForEach(availableColors, id: \.self) { color in
                            HStack {
                                Circle()
                                    .fill(colorFromName(color))
                                    .frame(width: 20, height: 20)
                                Text(color.capitalized)
                            }
                            .tag(color)
                        }
                    }
                }

                Section(header: Text("Период")) {
                    DatePicker("Дата начала", selection: $startDate, displayedComponents: .date)
                    DatePicker("Дата окончания", selection: $endDate, displayedComponents: .date)
                }

                Button("Сохранить") {
                    saveGoal()
                }
            }
            .navigationTitle("Новая цель")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Отмена") {
                dismiss()
            })
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("Ошибка"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    private func saveGoal() {
        guard let amount = Double(targetAmount), !title.isEmpty else {
            errorMessage = "Пожалуйста, введите корректные данные."
            showErrorAlert = true
            return
        }

        let newGoal = Goal(
            title: title,
            targetAmount: amount,
            startDate: startDate,
            endDate: endDate,
            colorName: selectedColorName
        )
        modelContext.insert(newGoal)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = "Ошибка сохранения цели: \(error.localizedDescription)"
            showErrorAlert = true
        }
    }

    private func colorFromName(_ name: String) -> Color {
        switch name {
        case "red":
            return .red
        case "blue":
            return .blue
        case "green":
            return .green
        case "purple":
            return .purple
        case "orange":
            return .orange
        case "gray":
            return .gray
        default:
            return .blue
        }
    }
}

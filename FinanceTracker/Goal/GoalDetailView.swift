// GoalDetailView.swift

import SwiftUI
import SwiftData

struct GoalDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var goal: Goal

    @State private var addAmount: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text(goal.title)
                .font(.title2)
                .bold()
                .padding()

            ProgressView(value: goalProgress())
                .progressViewStyle(LinearProgressViewStyle(tint: colorFromName(goal.colorName)))
                .scaleEffect(x: 1, y: 4, anchor: .center) // Увеличиваем высоту
                .padding()

            HStack(alignment: .center, spacing: 8) {
                Image(systemName: "target")
                    .foregroundColor(.blue)
                Text("Цель: \(goal.targetAmount, specifier: "%.2f")")
                    .font(.headline)
            }
            .padding(.horizontal)

            HStack(alignment: .center, spacing: 8) {
                Image(systemName: "dollarsign.circle")
                    .foregroundColor(.green)
                Text("Текущая сумма: \(goal.currentAmount, specifier: "%.2f")")
                    .font(.headline)
            }
            .padding(.horizontal)

            TextField("Добавить сумму", text: $addAmount)
                .keyboardType(.decimalPad)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)

            Button("Обновить прогресс") {
                updateProgress()
            }
            .padding()
            .buttonStyle(DefaultButtonStyle())

            Spacer()
        }
        .navigationTitle("Детали цели")
        .alert(isPresented: $showErrorAlert) {
            Alert(title: Text("Ошибка"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }

    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    private func goalProgress() -> Double {
        return min(goal.currentAmount / goal.targetAmount, 1.0)
    }

    private func updateProgress() {
        guard let amount = Double(addAmount) else {
            errorMessage = "Пожалуйста, введите корректную сумму."
            showErrorAlert = true
            return
        }
        goal.currentAmount += amount
        addAmount = ""
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

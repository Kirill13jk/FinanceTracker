import SwiftUI
import SwiftData

struct GoalDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var goal: Goal
    @AppStorage("selectedCurrency") private var selectedCurrency: String = "USD"

    @State private var addAmount: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text(goal.title)
                .font(.largeTitle)
                .bold()
                .padding()

            ProgressView(value: goalProgress())
                .progressViewStyle(LinearProgressViewStyle())
                .padding()

            Text("Target Amount: \(currencySymbol())\(goal.targetAmount, specifier: "%.2f")")
                .font(.headline)

            Text("Current Amount: \(currencySymbol())\(goal.currentAmount, specifier: "%.2f")")
                .font(.headline)

            TextField("Add Amount", text: $addAmount)
                .keyboardType(.decimalPad)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)

            Button("Update Progress") {
                updateProgress()
            }
            .padding()
            .buttonStyle(DefaultButtonStyle())

            Spacer()
        }
        .navigationTitle("Goal Details")
    }

    private func goalProgress() -> Double {
        return min(goal.currentAmount / goal.targetAmount, 1.0)
    }

    private func updateProgress() {
        guard let amount = Double(addAmount) else { return }
        goal.currentAmount += amount
        addAmount = ""
    }

    private func currencySymbol() -> String {
        switch selectedCurrency {
        case "USD":
            return "$"
        case "EUR":
            return "€"
        case "RUB":
            return "₽"
        case "UZS":
            return "UZS "
        case "GBP":
            return "£"
        case "JPY":
            return "¥"
        case "CNY":
            return "¥"
        default:
            return "$"
        }
    }
}

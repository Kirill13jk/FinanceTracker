import SwiftUI
import SwiftData

struct GoalsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Goal.endDate, order: .forward) private var goals: [Goal]
    @AppStorage("selectedCurrency") private var selectedCurrency: String = "USD"

    @State private var showAddGoalSheet = false

    var body: some View {
        NavigationView {
            List {
                ForEach(goals) { goal in
                    NavigationLink(destination: GoalDetailView(goal: goal)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(goal.title)
                                    .font(.headline)
                                Text("Target: \(currencySymbol())\(goal.targetAmount, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            ProgressView(value: goalProgress(goal))
                                .progressViewStyle(LinearProgressViewStyle())
                                .frame(width: 100)
                        }
                    }
                }
                .onDelete(perform: deleteGoal)
            }
            .navigationTitle("Financial Goals")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddGoalSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddGoalSheet) {
                AddGoalView()
            }
        }
    }

    private func goalProgress(_ goal: Goal) -> Double {
        return min(goal.currentAmount / goal.targetAmount, 1.0)
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

    private func deleteGoal(at offsets: IndexSet) {
        for index in offsets {
            let goal = goals[index]
            modelContext.delete(goal)
        }
    }
}

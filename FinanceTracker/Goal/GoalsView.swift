// GoalsView.swift

import SwiftUI
import SwiftData

struct GoalsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Goal.endDate, order: .forward) private var goals: [Goal]

    @State private var showAddGoalSheet = false

    var body: some View {
        List {
            ForEach(goals) { goal in
                NavigationLink(destination: GoalDetailView(goal: goal)) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(goal.title)
                                .font(.headline)
                            Text("Цель: \(goal.targetAmount, specifier: "%.2f")")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        ProgressView(value: goalProgress(goal))
                            .progressViewStyle(LinearProgressViewStyle(tint: colorFromName(goal.colorName)))
                            .scaleEffect(x: 1, y: 2, anchor: .center) // Увеличиваем высоту
                            .frame(width: 100)
                    }
                }
            }
            .onDelete(perform: deleteGoal)
        }
        .navigationTitle("Цели")
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

    private func goalProgress(_ goal: Goal) -> Double {
        return min(goal.currentAmount / goal.targetAmount, 1.0)
    }

    private func deleteGoal(at offsets: IndexSet) {
        for index in offsets {
            let goal = goals[index]
            modelContext.delete(goal)
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

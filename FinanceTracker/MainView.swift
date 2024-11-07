import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView {
            NavigationView {
                ContentView()
            }
            .tabItem {
                Label("Транзакции", systemImage: "creditcard")
            }
            NavigationView {
                AnalyticsView()
            }
            .tabItem {
                Label("Аналитика", systemImage: "chart.bar.xaxis")
            }
            NavigationView {
                PostsView()
            }
            .tabItem {
                Label("Советы", systemImage: "lightbulb")
            }
        }
        .onAppear {
            initializeData()
        }
    }

    private func initializeData() {
        DataInitializer.initializeData(modelContext: modelContext)
    }
}

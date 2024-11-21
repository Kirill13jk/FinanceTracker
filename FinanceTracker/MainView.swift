import SwiftUI

struct MainView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Первый таб: Главная
            NavigationView {
                ContentView()
                    .navigationTitle("Home")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(0)

            // Второй таб: Аналитика
            NavigationView {
                AnalyticsView()
                    .navigationTitle("Analytics")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Analytics", systemImage: "chart.pie")
            }
            .tag(1)

            // Третий таб: Цели
            NavigationView {
                GoalsView()
                    .navigationTitle("Goals")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Goals", systemImage: "target")
            }
            .tag(2)
            
            // Четвертый таб: Настройки
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(3)
        }
        .accentColor(.blue)
    }
}

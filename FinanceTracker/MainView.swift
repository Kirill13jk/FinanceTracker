import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView {
            NavigationView {
                ContentView()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            NavigationLink(destination: SettingsView()) {
                                Image(systemName: "gearshape")
                                    .imageScale(.large)
                            }
                        }
                    }
            }
            .tabItem {
                Label(NSLocalizedString("transactions", comment: ""), systemImage: "creditcard")
            }
            
            NavigationView {
                AnalyticsView()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            NavigationLink(destination: SettingsView()) {
                                Image(systemName: "gearshape")
                                    .imageScale(.large)
                            }
                        }
                    }
            }
            .tabItem {
                Label(NSLocalizedString("analytics", comment: ""), systemImage: "chart.bar.xaxis")
            }
            
            NavigationView {
                PostsView()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            NavigationLink(destination: SettingsView()) {
                                Image(systemName: "gearshape")
                                    .imageScale(.large)
                            }
                        }
                    }
            }
            .tabItem {
                Label(NSLocalizedString("posts", comment: ""), systemImage: "lightbulb")
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

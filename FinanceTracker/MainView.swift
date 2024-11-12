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
                Label("Transactions", systemImage: "creditcard")
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
                    Label("Analytics", systemImage: "chart.bar.xaxis")
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
                    Label("Posts", systemImage: "lightbulb")
                }

            NavigationView {
                GoalsView()
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
                    Label("Goals", systemImage: "target")
                }
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 20)
        }
        .onAppear {
          
        }
    }
}

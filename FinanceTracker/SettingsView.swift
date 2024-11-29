// SettingsView.swift

import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("selectedCurrency") private var selectedCurrency: String = "USD"
    @State private var tempSelectedCurrency: String = "USD"
    
    private let currencies = ["USD", "EUR", "RUB", "UZS", "GBP", "JPY", "CNY"]
    
    var body: some View {
        List {
            // Секция настроек валюты
            Section(header: Text("Валюта")) {
                Picker("Выберите валюту", selection: $tempSelectedCurrency) {
                    ForEach(currencies, id: \.self) { currency in
                        Text(currency).tag(currency)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                Button(action: {
                    selectedCurrency = tempSelectedCurrency
                }) {
                    Text("Применить")
                        .foregroundColor(.blue)
                }
            }
            
            // Секция настроек цветовой схемы
            Section(header: Text("Цветовая схема")) {
                HStack {
                    Text("Текущая тема")
                    Spacer()
                    Text(colorScheme == .light ? "Светлая" : "Тёмная")
                        .foregroundColor(colorScheme == .light ? .blue : .orange)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Settings")
        .onAppear {
            tempSelectedCurrency = selectedCurrency
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
                .preferredColorScheme(.light)
        }
        NavigationView {
            SettingsView()
                .preferredColorScheme(.dark)
        }
    }
}

import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("titleOn") private var titleOn: Bool = true
    @AppStorage("selectedCurrency") private var selectedCurrency: String = "USD"
    @State private var tempSelectedCurrency: String = "USD"
    
    private let currencies = ["USD", "EUR", "RUB", "UZS", "GBP", "JPY", "CNY"]
    
    var body: some View {
        Form {
            Section(header: Text(NSLocalizedString("color_scheme", comment: ""))) {
                Text(colorScheme == .light ? NSLocalizedString("light_theme_enabled", comment: "") : NSLocalizedString("dark_theme_enabled", comment: ""))
                    .font(.headline)
                    .foregroundColor(colorScheme == .light ? .blue : .orange)
            }
            
            Section(header: Text(NSLocalizedString("title_settings", comment: ""))) {
                Toggle(NSLocalizedString("toggle_title", comment: ""), isOn: $titleOn)
                if titleOn {
                    Text(NSLocalizedString("navigation_title_enabled", comment: ""))
                        .foregroundColor(.green)
                } else {
                    Text(NSLocalizedString("navigation_title_disabled", comment: ""))
                        .foregroundColor(.red)
                }
            }
            
            Section(header: Text("Currency")) {
                Picker("Select Currency", selection: $tempSelectedCurrency) {
                    ForEach(currencies, id: \.self) { currency in
                        Text(currency).tag(currency)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .labelsHidden()
                
                Button("Apply") {
                    selectedCurrency = tempSelectedCurrency
                }
                .padding(.top, 10)
            }
        }
        .navigationTitle(NSLocalizedString("settings", comment: ""))
        .onAppear {
            tempSelectedCurrency = selectedCurrency
        }
    }
}

import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("titleOn") private var titleOn: Bool = true

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
        }
        .navigationTitle(NSLocalizedString("settings", comment: ""))
    }
}

import SwiftUI

struct SummaryView: View {
    let title: String
    let amount: Double
    @AppStorage("selectedCurrency") private var selectedCurrency: String = "USD"

    var body: some View {
        VStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Text("\(currencySymbol(selectedCurrency: selectedCurrency))\(abs(amount), specifier: "%.0f")")
                .font(.headline)
                .bold()
                .foregroundColor(amount >= 0 ? .green : .red)
        }
    }
}

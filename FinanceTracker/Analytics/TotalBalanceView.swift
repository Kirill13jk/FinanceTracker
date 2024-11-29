import SwiftUI

struct TotalBalanceView: View {
    let totalBalance: Double
    let currencySymbol: String
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        VStack(alignment: .leading) {
            Text("Total Balance for the Period")
                .font(verticalSizeClass == .compact ? .subheadline : .headline)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Text("\(currencySymbol)\(totalBalance, specifier: "%.2f")")
                .font(verticalSizeClass == .compact ? .title2 : .largeTitle)
                .foregroundColor(totalBalance >= 0 ? .green : .red)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
    }
}

struct TotalBalanceView_Previews: PreviewProvider {
    static var previews: some View {
        TotalBalanceView(totalBalance: 1500.0, currencySymbol: "$")
            .previewLayout(.sizeThatFits)
    }
}

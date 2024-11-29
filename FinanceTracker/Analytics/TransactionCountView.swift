import SwiftUI

struct TransactionCountView: View {
    let count: Int
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        Text("Number of transactions: \(count)")
            .font(verticalSizeClass == .compact ? .subheadline : .headline)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
    }
}

struct TransactionCountView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionCountView(count: 25)
            .previewLayout(.sizeThatFits)
    }
}

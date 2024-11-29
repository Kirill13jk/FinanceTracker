import SwiftUI

func assignColor(for category: String) -> Color {
    switch category.lowercased() {
    case "food":
        return .blue
    case "transport":
        return .green
    case "entertainment":
        return .purple
    case "health":
        return .red
    case "shopping":
        return .orange
    case "utilities":
        return .pink
    default:
        return .gray
    }
}

struct ColorPreview: View {
    let category: String

    var body: some View {
        Rectangle()
            .fill(assignColor(for: category))
            .frame(width: 100, height: 100)
            .cornerRadius(10)
            .overlay(
                Text(category.capitalized)
                    .foregroundColor(.white)
                    .bold()
            )
    }
}

#Preview {
    ColorPreview(category: "food")
}

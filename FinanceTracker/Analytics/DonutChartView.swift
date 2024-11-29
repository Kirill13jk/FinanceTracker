import SwiftUI

struct DonutChartView: View {
    let data: [CategoryData]
    let totalAmount: Double
    let categoriesInfo: [AnalyticsView.CategoryInfo]
    let onSelectCategory: (CategoryData) -> Void
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = size / 2
            let holeRadius = radius * 0.6 

            ZStack {
                ForEach(data.indices, id: \.self) { index in
                    let startAngle = angle(at: index)
                    let endAngle = angle(at: index + 1)

                    Path { path in
                        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                        path.addArc(center: center, radius: holeRadius, startAngle: endAngle, endAngle: startAngle, clockwise: true)
                        path.closeSubpath()
                    }
                    .fill(color(for: data[index].category))
                    .onTapGesture {
                        onSelectCategory(data[index])
                    }

                    // Percentage labels
                    let midAngle = (startAngle + endAngle) / 2
                    let labelRadius = (radius + holeRadius) / 2
                    let x = center.x + labelRadius * cos(midAngle.radians)
                    let y = center.y + labelRadius * sin(midAngle.radians)

                    Text("\(Int(data[index].percentage * 100))%")
                        .font(.caption)
                        .position(x: x, y: y)
                }

                // Total amount in center
                VStack {
                    Text("\(totalAmount, specifier: "%.2f")")
                        .font(.title2)
                        .bold()
                }
                .frame(width: holeRadius * 2, height: holeRadius * 2)
                .position(center)
            }
        }
    }

    // MARK: - Angle Calculation
    private func angle(at index: Int) -> Angle {
        let total = data.reduce(0) { $0 + $1.amount }
        guard total > 0 else { return .degrees(0) }

        let percentage = data.prefix(index).reduce(0) { $0 + $1.amount } / total
        return .degrees(percentage * 360)
    }

    // MARK: - Color Matching
    private func color(for categoryName: String) -> Color {
        if let category = categoriesInfo.first(where: { $0.name.lowercased() == categoryName.lowercased() }) {
            return category.color
        } else {
            return Color.gray
        }
    }
}


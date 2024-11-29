import SwiftUI
import Charts

struct LineChartView: View {
    let dataPoints: [ChartDataPoint]
    let currencySymbol: String
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        if !dataPoints.isEmpty {
            Chart {
                ForEach(dataPoints) { data in
                    if data.income > 0 {
                        LineMark(
                            x: .value("Date", data.date),
                            y: .value("Income", data.income)
                        )
                        .foregroundStyle(Color.green)
                        .interpolationMethod(.catmullRom)
                        .symbol(Circle())
                        .lineStyle(StrokeStyle(lineWidth: 2))
                    }

                    if data.expense > 0 {
                        LineMark(
                            x: .value("Date", data.date),
                            y: .value("Expense", data.expense)
                        )
                        .foregroundStyle(Color.red)
                        .interpolationMethod(.catmullRom)
                        .symbol(Circle())
                        .lineStyle(StrokeStyle(lineWidth: 2))
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: dataPoints.count > 7 ? max(dataPoints.count / 7, 1) : 1)) { value in
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(date, format: .dateTime.month(.abbreviated).day())
                                .font(.caption2)
                                .rotationEffect(.degrees(-45))
                                .fixedSize()
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartLegend {
                HStack {
                    Circle().fill(Color.green).frame(width: 10, height: 10)
                    Text("Income")
                    Circle().fill(Color.red).frame(width: 10, height: 10)
                    Text("Expense")
                }
            }
            .frame(height: chartHeight())
            .frame(maxWidth: .infinity)
        } else {
            Text("No data for the selected period.")
                .foregroundColor(.gray)
        }
    }

    private func chartHeight() -> CGFloat {
        if verticalSizeClass == .compact {
            return 200
        } else {
            return 300
        }
    }
}


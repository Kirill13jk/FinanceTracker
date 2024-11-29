import Foundation
import SwiftUICore

struct CategoryInfo: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
}

let categoriesInfo: [CategoryInfo] = [
    CategoryInfo(name: "Food", color: Color.red.opacity(0.5)),
    CategoryInfo(name: "Transport", color: Color.blue.opacity(0.5)),
    CategoryInfo(name: "Housing", color: Color.green.opacity(0.5)),
    CategoryInfo(name: "Entertainment", color: Color.purple.opacity(0.5)),
    CategoryInfo(name: "Health", color: Color.orange.opacity(0.5)),
    CategoryInfo(name: "Other", color: Color.gray.opacity(0.5))
]

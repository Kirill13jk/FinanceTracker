import SwiftUI

struct CategorySelectionGridView: View {
    let categories: [(String, String)]
    @Binding var selectedCategory: String

    let columns = [GridItem(.adaptive(minimum: 60))]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(categories, id: \.0) { category in
                Button(action: {
                    selectedCategory = category.0
                }) {
                    VStack {
                        Image(systemName: category.1)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(selectedCategory == category.0 ? .blue : .gray)
                        Text(category.0)
                            .font(.caption2)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(8)
                    .background(selectedCategory == category.0 ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal)
    }
}


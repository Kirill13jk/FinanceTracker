import SwiftUI

struct PostDetailView: View {
    var post: Post

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Image(post.imageName)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(10)
                    .padding()

                Text(post.title)
                    .font(.title)
                    .bold()
                    .padding(.horizontal)

                Text(post.content)
                    .font(.body)
                    .padding([.horizontal, .bottom])

                Spacer()
            }
        }
        .navigationTitle(post.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

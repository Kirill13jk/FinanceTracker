import SwiftUI
import SwiftData

struct PostsView: View {
    @Query private var posts: [Post]

    var body: some View {
        NavigationView {
            List(posts) { post in
                NavigationLink(destination: PostDetailView(post: post)) {
                    HStack {
                        Image(post.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipped()
                            .cornerRadius(8)
                        Text(post.title)
                            .font(.headline)
                            .padding(.leading, 8)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Полезные советы")
        }
    }
}

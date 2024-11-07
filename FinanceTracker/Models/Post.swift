import Foundation
import SwiftData

@Model
class Post: Identifiable {
    var id: UUID
    var title: String
    var content: String
    var imageName: String

    init(title: String, content: String, imageName: String) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.imageName = imageName
    }
}

import Foundation
import SwiftData

class DataInitializer {
    static func initializeData(modelContext: ModelContext) {
        let fetchDescriptor = FetchDescriptor<Post>()
        do {
            let posts = try modelContext.fetch(fetchDescriptor)
            if posts.isEmpty {
                print("Нет постов, добавляем данные.")
                let post1 = Post(
                    title: NSLocalizedString("post1_title", comment: ""),
                    content: NSLocalizedString("post1_content", comment: ""),
                    imageName: "finance_tips"
                )

                let post2 = Post(
                    title: NSLocalizedString("post2_title", comment: ""),
                    content: NSLocalizedString("post2_content", comment: ""),
                    imageName: "saving_money"
                )

                modelContext.insert(post1)
                modelContext.insert(post2)

                do {
                    try modelContext.save()
                    print(NSLocalizedString("posts_added", comment: ""))
                } catch {
                    print(String(format: NSLocalizedString("error_saving_data", comment: ""), "\(error)"))
                }
            } else {
                print("Посты уже существуют, не требуется инициализация.")
            }
        } catch {
            print("Ошибка при выборке постов: \(error)")
        }
    }
}

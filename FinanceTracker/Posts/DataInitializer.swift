import Foundation
import SwiftData

class DataInitializer {
    static func initializeData(modelContext: ModelContext) {
        let fetchDescriptor = FetchDescriptor<Post>()
        if let posts = try? modelContext.fetch(fetchDescriptor), posts.isEmpty {
            let post1 = Post(
                title: "5 советов по управлению личными финансами",
                content: "Управление личными финансами важно для достижения финансовой стабильности. Начните с составления бюджета, отслеживайте расходы и ставьте финансовые цели.",
                imageName: "finance_tips"
            )

            let post2 = Post(
                title: "Как эффективно экономить деньги",
                content: "Экономия денег может быть простой, если вы следуете нескольким правилам. Автоматизируйте сбережения, сократите ненужные расходы и инвестируйте в будущее.",
                imageName: "saving_money"
            )

            modelContext.insert(post1)
            modelContext.insert(post2)

            do {
                try modelContext.save()
                print("Посты добавлены")
            } catch {
                print("Ошибка при сохранении данных: \(error)")
            }
        }
    }
}

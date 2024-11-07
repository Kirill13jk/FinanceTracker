import SwiftUI
import SwiftData

struct AddTransactionView: View {
    private let categories = ["Еда", "Транспорт", "Жильё", "Развлечения", "Здоровье", "Другое"]
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var amount: String = ""
    @State private var category: String = ""
    @State private var date: Date = Date()
    @State private var note: String = ""
    @State private var isExpense: Bool = true

    var body: some View {
        Form {
            Section(header: Text("Тип транзакции")) {
                Picker("Выберите тип", selection: $isExpense) {
                    Text("Расход").tag(true)
                    Text("Доход").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            Section(header: Text("Сумма")) {
                TextField("Введите сумму", text: $amount)
                    .keyboardType(.decimalPad)
            }
            Section(header: Text("Категория")) {
                Picker("Выберите категорию", selection: $category) {
                    ForEach(categories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
            }
            Section(header: Text("Дата")) {
                DatePicker("Выберите дату", selection: $date, displayedComponents: .date)
            }
            Section(header: Text("Заметка")) {
                TextField("Добавьте заметку (необязательно)", text: $note)
            }
        }
        .navigationTitle("Новая транзакция")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Отмена") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Сохранить") {
                    saveTransaction()
                }
            }
        }
    }

    private func saveTransaction() {
        print("saveTransaction() вызвана")

        guard let amountValue = Double(amount), !category.isEmpty else {
            print("Некорректный ввод: сумма - \(amount), категория - \(category)")
            return
        }

        let newTransaction = Transaction(
            amount: amountValue,
            category: category,
            date: date,
            note: note.isEmpty ? nil : note,
            isExpense: isExpense
        )
        modelContext.insert(newTransaction)
        print("Транзакция добавлена: \(newTransaction)")
        dismiss()
    }
}

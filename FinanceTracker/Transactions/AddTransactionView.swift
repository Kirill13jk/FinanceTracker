import SwiftUI
import SwiftData

struct AddTransactionView: View {
    // MARK: - Категории
    private let incomeSources = [
        ("Work", "briefcase.fill"),
        ("Business", "building.2.fill"),
        ("Deposit", "banknote.fill"),
        ("Friend", "person.2.fill")
    ]
    private let expenseCategories = [
        ("Food", "fork.knife"),
        ("Transport", "car.fill"),
        ("Housing", "house.fill"),
        ("Entertainment", "gamecontroller.fill"),
        ("Health", "heart.fill"),
        ("Other", "ellipsis")
    ]

    // MARK: - Окружение и состояние
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @AppStorage("selectedCurrency") private var selectedCurrency: String = "USD"
    @State private var isShowingDatePicker = false

    @State private var amount: String = ""
    @State private var selectedCategoryName: String = "Food"
    @State private var selectedPaymentMethod: String = "Work"
    @State private var note: String = ""
    @State private var isExpense: Bool = false
    @State private var totalBalance: Double = 0.0
    @State private var selectedDate: Date = Date()
    @State private var showAlert = false
    @State private var alertMessage = ""
    @FocusState private var noteFieldIsFocused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Общий баланс
                HStack {
                    VStack(alignment: .leading) {
                        Text("Total Balance")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("\(currencySymbol())\(totalBalance, specifier: "%.2f")")
                            .font(.title)
                            .bold()
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .onAppear {
                    totalBalance = calculateTotalBalance()
                }

                // Переключатель типа транзакции
                Picker("Type", selection: $isExpense) {
                    Text("Income").tag(false)
                    Text("Expense").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                // Выбор категории
                if isExpense {
                    CategorySelectionGridView(
                        categories: expenseCategories,
                        selectedCategory: $selectedCategoryName
                    )
                } else {
                    CategorySelectionGridView(
                        categories: incomeSources,
                        selectedCategory: $selectedPaymentMethod
                    )
                }

                // Отображение суммы
                Text("\(currencySymbol())\(amount.isEmpty ? "0.00" : amount)")
                    .font(.system(size: 40))
                    .bold()
                    .padding()
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)

                // Отображение выбранной даты
                HStack {
                    Text("Date:")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(formattedDate(selectedDate))")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .onTapGesture {
                            noteFieldIsFocused = false
                            UIApplication.shared.endEditing()
                            isShowingDatePicker = true
                        }
                }
                .padding(.horizontal)

                // Поле для комментариев
                TextField("Add comment...", text: $note)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .focused($noteFieldIsFocused)

                // Цифровая клавиатура
                NumericKeypad(
                    amount: $amount,
                    onSave: saveTransaction,
                    onDateTap: {
                        noteFieldIsFocused = false
                        UIApplication.shared.endEditing()
                        isShowingDatePicker = true
                    }
                )
                .padding(.bottom, 30)
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .navigationBarTitle("", displayMode: .inline)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Invalid Input"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $isShowingDatePicker) {
            DatePickerView(selectedDate: $selectedDate, isShowing: $isShowingDatePicker)
        }
    }

    // MARK: - Функции

    private func saveTransaction() {
        guard let amountValue = Double(amount), amountValue > 0 else {
            alertMessage = "Please enter a valid amount greater than 0."
            showAlert = true
            return
        }

        let category = isExpense ? selectedCategoryName : selectedPaymentMethod

        let newTransaction = Transaction(
            amount: amountValue, category: category,
            date: selectedDate,
            note: note.isEmpty ? nil : note,
            isExpense: isExpense
        )
        modelContext.insert(newTransaction)
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving transaction: \(error)")
            alertMessage = "Failed to save transaction. Please try again."
            showAlert = true
        }
    }

    private func calculateTotalBalance() -> Double {
        let fetchDescriptor = FetchDescriptor<Transaction>()
        do {
            let allTransactions = try modelContext.fetch(fetchDescriptor)
            let incomes = allTransactions
                .filter { !$0.isExpense }
                .reduce(0.0) { $0 + $1.amount }
            let expenses = allTransactions
                .filter { $0.isExpense }
                .reduce(0.0) { $0 + $1.amount }
            return incomes - expenses
        } catch {
            print("Error fetching transactions: \(error)")
            return 0.0
        }
    }

    private func currencySymbol() -> String {
        switch selectedCurrency {
        case "USD":
            return "$"
        case "EUR":
            return "€"
        case "RUB":
            return "₽"
        case "UZS":
            return "UZS "
        case "GBP":
            return "£"
        case "JPY":
            return "¥"
        case "CNY":
            return "¥"
        default:
            return "$"
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - NumericKeypad
struct NumericKeypad: View {
    @Binding var amount: String
    var onSave: () -> Void
    var onDateTap: () -> Void

    let buttons = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        [".", "0", "⌫"]
    ]

    var body: some View {
        VStack(spacing: 8) {
            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(row, id: \.self) { button in
                        Button(action: {
                            buttonAction(button)
                        }) {
                            Text(button)
                                .font(.title2)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
            }
            .padding(.horizontal)

            HStack(spacing: 8) {
                Button(action: {
                    onDateTap()
                }) {
                    Image(systemName: "calendar")
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                }

                Button(action: {
                    onSave()
                }) {
                    Image(systemName: "checkmark")
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
        }
    }

    private func buttonAction(_ input: String) {
        switch input {
        case "⌫":
            if !amount.isEmpty {
                amount.removeLast()
            }
        case ".":
            if !amount.contains(".") {
                amount.append(".")
            }
        default:
            amount.append(input)
        }
    }
}

// MARK: - UIApplication Extension для закрытия клавиатуры
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

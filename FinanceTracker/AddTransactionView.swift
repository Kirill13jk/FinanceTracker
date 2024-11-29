import SwiftUI
import SwiftData

struct AddTransactionView: View {
    private let paymentMethods = ["Cash", "Card", "Deposit"]

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @AppStorage("selectedCurrency") private var selectedCurrency: String = "USD"

    @State private var amount: String = ""
    @State private var selectedCategoryName: String = categoriesInfo[0].name
    @State private var selectedPaymentMethod: String = "Cash"
    @State private var note: String = ""
    @State private var isExpense: Bool = true
    @State private var totalBalance: Double = 0.0
    @State private var showCategoryPicker = false
    @State private var showPaymentMethodPicker = false

    var body: some View {
        VStack {
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
                Button(action: {}) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title2)
                }
            }
            .padding()
            .onAppear {
                totalBalance = calculateTotalBalance()
            }

            Picker("Type", selection: $isExpense) {
                Text("Expense").tag(true)
                Text("Income").tag(false)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)

            HStack(spacing: 20) {
                Button(action: {
                    showPaymentMethodPicker.toggle()
                }) {
                    HStack {
                        Image(systemName: "creditcard")
                        Text(selectedPaymentMethod)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                }
                .sheet(isPresented: $showPaymentMethodPicker) {
                    VStack {
                        Text("Select Payment Method")
                            .font(.headline)
                            .padding()
                        Picker("Select Payment Method", selection: $selectedPaymentMethod) {
                            ForEach(paymentMethods, id: \.self) { method in
                                Text(method).tag(method)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .labelsHidden()
                        .padding()
                        Button("Done") {
                            showPaymentMethodPicker = false
                        }
                        .padding()
                    }
                }

                Button(action: {
                    showCategoryPicker.toggle()
                }) {
                    HStack {
                        Image(systemName: "tag.fill")
                        Text(selectedCategoryName)
                    }
                    .padding()
                    .background(categoryColor(for: selectedCategoryName))
                    .cornerRadius(10)
                }
                .sheet(isPresented: $showCategoryPicker) {
                    VStack {
                        Text("Select Category")
                            .font(.headline)
                            .padding()
                        Picker("Select Category", selection: $selectedCategoryName) {
                            ForEach(categoriesInfo, id: \.name) { category in
                                HStack {
                                    Circle()
                                        .fill(category.color)
                                        .frame(width: 10, height: 10)
                                    Text(category.name)
                                }
                                .tag(category.name)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .labelsHidden()
                        .padding()
                        Button("Done") {
                            showCategoryPicker = false
                        }
                        .padding()
                    }
                }
            }
            .padding(.horizontal)

            Text("\(currencySymbol())\(amount.isEmpty ? "0.00" : amount)")
                .font(.system(size: 50))
                .bold()
                .padding()

            TextField("Add comment...", text: $note)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)

            Spacer()

            NumericKeypad(amount: $amount, onSave: saveTransaction)
                .padding(.bottom, 30)
                .padding(.horizontal)
        }
        .navigationBarTitle("", displayMode: .inline)
        .padding(.top)
    }

    private func saveTransaction() {
        guard let amountValue = Double(amount), !selectedCategoryName.isEmpty else {
            return
        }

        let newTransaction = Transaction(
            amount: amountValue,
            category: selectedCategoryName,
            date: Date(),
            note: note.isEmpty ? nil : note,
            isExpense: isExpense
        )
        modelContext.insert(newTransaction)
        dismiss()
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

    private func categoryColor(for name: String) -> Color {
        return categoriesInfo.first { $0.name == name }?.color ?? Color.gray.opacity(0.5)
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
}

struct NumericKeypad: View {
    @Binding var amount: String
    var onSave: () -> Void

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
                                .frame(height: 60)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            HStack(spacing: 8) {
                Button(action: {}) {
                    Image(systemName: "tag.fill")
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(8)
                }

                Button(action: {}) {
                    Image(systemName: "calendar")
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                }

                Button(action: {
                    onSave()
                }) {
                    Image(systemName: "checkmark")
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
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

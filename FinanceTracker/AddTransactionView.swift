import SwiftUI
import SwiftData

struct AddTransactionView: View {
    private let incomeSources = ["Work", "Business", "Deposit", "Friend"]
    private let expenseCategories = ["Food", "Transport", "Housing", "Entertainment", "Health", "Other"]

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @AppStorage("selectedCurrency") private var selectedCurrency: String = "USD"

    @State private var amount: String = ""
    @State private var selectedCategoryName: String = "Food"
    @State private var selectedPaymentMethod: String = "Work"
    @State private var note: String = ""
    @State private var isExpense: Bool = false
    @State private var totalBalance: Double = 0.0
    @State private var showCategoryPicker = false
    @State private var showPaymentMethodPicker = false
    @State private var showDatePicker = false
    @State private var selectedDate: Date = Date()
    @State private var showAlert = false
    @State private var alertMessage = ""
    @FocusState private var noteFieldIsFocused: Bool

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
            }
            .padding()
            .onAppear {
                totalBalance = calculateTotalBalance()
            }

            Picker("Type", selection: $isExpense) {
                Text("Income").tag(false)
                Text("Expense").tag(true)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)

            HStack(spacing: 20) {
                if isExpense {
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
                                ForEach(expenseCategories, id: \.self) { category in
                                    Text(category).tag(category)
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
                } else {
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
                            Text("Select Income Source")
                                .font(.headline)
                                .padding()
                            Picker("Select Income Source", selection: $selectedPaymentMethod) {
                                ForEach(incomeSources, id: \.self) { source in
                                    Text(source).tag(source)
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
                .focused($noteFieldIsFocused)

            Spacer()

            NumericKeypad(
                amount: $amount,
                onSave: saveTransaction,
                onCategoryTap: {
                    showCategoryPicker = true
                },
                onDateTap: {
                    showDatePicker = true
                }
            )
            .padding(.bottom, 30)
            .padding(.horizontal)
        }
        .navigationBarTitle("", displayMode: .inline)
        .padding(.top)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Invalid Input"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $showDatePicker) {
            VStack {
                Text("Select Date")
                    .font(.headline)
                    .padding()
                DatePicker("Transaction Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .labelsHidden()
                    .padding()
                Button("Done") {
                    showDatePicker = false
                }
                .padding()
            }
        }
    }

    private func saveTransaction() {
        guard let amountValue = Double(amount), amountValue > 0 else {
            alertMessage = "Please enter a valid amount greater than 0."
            showAlert = true
            return
        }

        if isExpense && selectedCategoryName.isEmpty {
            alertMessage = "Please select a category."
            showAlert = true
            return
        }

        if !isExpense && selectedPaymentMethod.isEmpty {
            alertMessage = "Please select an income source."
            showAlert = true
            return
        }

        let category = isExpense ? selectedCategoryName : selectedPaymentMethod

        let newTransaction = Transaction(
            amount: amountValue,
            category: category,
            date: selectedDate,
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
        categoriesInfo.first { $0.name == name }?.color ?? Color.gray.opacity(0.5)
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
    var onCategoryTap: () -> Void
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
                                .frame(height: 60)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
            }
            .padding(.horizontal)

            HStack(spacing: 8) {
                Button(action: {
                    onCategoryTap()
                }) {
                    Image(systemName: "tag.fill")
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(8)
                }

                Button(action: {
                    onDateTap()
                }) {
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

import SwiftUI

struct DatePickerView: View {
    @Binding var selectedDate: Date
    @Binding var isShowing: Bool

    var body: some View {
        NavigationView {
            VStack {
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                Spacer()
            }
            .navigationBarItems(trailing: Button("Done") {
                isShowing = false
            })
            .navigationBarTitle("Select Date", displayMode: .inline)
        }
    }
}


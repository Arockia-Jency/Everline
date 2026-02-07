import SwiftUI
import SwiftData

struct EditMomentView: View {
    @Bindable var moment: Moment
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $moment.title)
                    DatePicker("Date", selection: $moment.date, displayedComponents: .date)
                }
                
                Section("Mood") {
                    Picker("How was it?", selection: $moment.mood) {
                        ForEach(Mood.allCases, id: \.self) { mood in
                            Text(mood.rawValue).tag(mood.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Notes") {
                    TextEditor(text: $moment.notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Edit Memory")
            .toolbar {
                Button("Done") { dismiss() }
            }
        }
    }
}

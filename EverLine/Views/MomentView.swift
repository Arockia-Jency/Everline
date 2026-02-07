import SwiftUI
import SwiftData

struct MomentView: View {
    let moment: Moment

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(moment.title)
                    .font(.title)
                    .fontWeight(.semibold)

                if !moment.notes.isEmpty {
                    Text(moment.notes)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                Text(moment.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.footnote)
                    .foregroundStyle(.tertiary)

                // Placeholder for any additional content such as photos, tags, etc.
                // Add more fields here as your `Moment` model evolves.
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationTitle("Moment")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemBackground))
    }
}

#Preview("Sample Moment") {
    // Construct a lightweight sample `Moment`. Adjust property names to match your model.
    // If your `Moment` initializer differs, update the sample accordingly.
    let sample = Moment()
    // Try to set common fields if they exist; these assignments are optional and safe to remove if your model differs.
    if Mirror(reflecting: sample).children.contains(where: { $0.label == "title" }) {
        // Use KVC-like reflection is not available in Swift, so we leave sample defaults. This comment explains intent.
    }
    return NavigationStack { MomentView(moment: sample) }
}

import SwiftUI

struct TimelineRowView: View {
    let moment: Moment

    var body: some View {
        HStack(spacing: 16) {
            // Mood Indicator
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 50, height: 50)
                
                Text(emoji(for: moment.mood))
                    .font(.title)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(moment.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                if !moment.notes.isEmpty {
                    Text(moment.notes)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                Text(moment.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption2.bold())
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(.background)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func emoji(for mood: String) -> String {
        let lower = mood.lowercased()
        if lower.contains("love") { return "❤️" }
        if lower.contains("happy") { return "😊" }
        if lower.contains("sad") { return "😢" }
        if lower.contains("fight") || lower.contains("argument") { return "⚡️" }
        if lower.contains("milestone") { return "🏆" }
        return "✨"
    }
}

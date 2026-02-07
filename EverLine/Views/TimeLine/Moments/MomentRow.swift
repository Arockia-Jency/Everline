//
//  MomentRow.swift
//  EverLine
//
//  Created by Jen on 06/02/26.
//

import SwiftUI

struct MomentRow: View {
    let moment: Moment
    let onDelete: () -> Void
    
    @State private var showDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 1. Display the Photo if it exists
            if let data = moment.photoData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(15)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(moment.title)
                        .font(.headline)
                    
                    Text(moment.date.formatted(date: .long, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // 2. Display the Mood Icon
                Text(moment.moodEmoji) // Grabs the Emoji
                    .font(.title2)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            
            if !moment.notes.isEmpty {
                Text(moment.notes)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        .contextMenu {
            Button(role: .destructive) {
                showDeleteAlert = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .alert("Delete this moment?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Yes, we had a fight", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete \"\(moment.title)\"?")
        }
    }
}

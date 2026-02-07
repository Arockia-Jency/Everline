//
//  SettingsView.swift
//  EverLine
//
//  Created by Jen on 07/02/26.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var moments: [Moment]
    
    @State private var showDeleteAllAlert = false
    @State private var showExportSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("About") {
                    HStack {
                        Text("Total Moments")
                        Spacer()
                        Text("\(moments.count)")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section("Data") {
                    Button {
                        showExportSheet = true
                    } label: {
                        Label("Export Moments", systemImage: "square.and.arrow.up")
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        showDeleteAllAlert = true
                    } label: {
                        Label("Delete All Moments", systemImage: "trash.fill")
                    }
                } header: {
                    Text("Danger Zone")
                } footer: {
                    Text("This will permanently delete all your moments. This action cannot be undone.")
                }
                
                Section("Support") {
                    Link(destination: URL(string: "https://apple.com/feedback")!) {
                        Label("Send Feedback", systemImage: "envelope.fill")
                    }
                    
                    Link(destination: URL(string: "https://apple.com/privacy")!) {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Delete All Moments?", isPresented: $showDeleteAllAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete All", role: .destructive) {
                    deleteAllMoments()
                }
            } message: {
                Text("This will permanently delete all \(moments.count) moment(s). This action cannot be undone.")
            }
            .sheet(isPresented: $showExportSheet) {
                ExportView(moments: moments)
            }
        }
    }
    
    private func deleteAllMoments() {
        for moment in moments {
            modelContext.delete(moment)
        }
        try? modelContext.save()
    }
}

// MARK: - Export View
struct ExportView: View {
    @Environment(\.dismiss) private var dismiss
    let moments: [Moment]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "square.and.arrow.up.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.pink)
                
                Text("Export Your Moments")
                    .font(.title2.bold())
                
                Text("Export all your moments as a text file or JSON backup.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    Button {
                        exportAsText()
                    } label: {
                        Label("Export as Text", systemImage: "doc.text.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.pink.opacity(0.1))
                            .foregroundStyle(.pink)
                            .cornerRadius(12)
                    }
                    
                    Button {
                        exportAsJSON()
                    } label: {
                        Label("Export as JSON", systemImage: "doc.badge.gearshape.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .foregroundStyle(.blue)
                            .cornerRadius(12)
                    }
                }
                .padding()
                
                Spacer()
            }
            .padding()
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func exportAsText() {
        var text = "EverLine Moments Export\n"
        text += "Generated: \(Date().formatted())\n"
        text += String(repeating: "=", count: 50) + "\n\n"
        
        for moment in moments.sorted(by: { $0.date > $1.date }) {
            text += "Title: \(moment.title)\n"
            text += "Date: \(moment.date.formatted(date: .long, time: .omitted))\n"
            text += "Mood: \(moment.mood)\n"
            if !moment.notes.isEmpty {
                text += "Notes: \(moment.notes)\n"
            }
            text += "\n" + String(repeating: "-", count: 50) + "\n\n"
        }
        
        shareText(text)
    }
    
    private func exportAsJSON() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        let exportData = moments.map { moment in
            return [
                "id": moment.id.uuidString,
                "title": moment.title,
                "notes": moment.notes,
                "date": ISO8601DateFormatter().string(from: moment.date),
                "mood": moment.mood,
                "hasPhoto": moment.encryptedPhotoData != nil,
                "latitude": moment.latitude as Any,
                "longitude": moment.longitude as Any
            ]
        }
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            shareText(jsonString)
        }
    }
    
    private func shareText(_ text: String) {
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: Moment.self, inMemory: true)
}

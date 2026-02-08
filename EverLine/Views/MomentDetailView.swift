// MomentDetailView.swift
// Everline
// Phase 2: Detail view with share action

import SwiftUI
import MapKit
import SwiftData

struct MomentDetailView: View {
    let moment: Moment
    var securityManager: SecurityManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var isSharing = false
    @State private var shareImage: UIImage?
    @State private var isEditing = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Hero Section (Photo or Mood)
                if moment.encryptedPhotoData != nil {
                    SecureImageView(
                        encryptedData: moment.encryptedPhotoData,
                        securityManager: securityManager,
                        contentMode: .fit,
                        cornerRadius: 24
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.pink.opacity(0.1).gradient)
                        
                        VStack(spacing: 12) {
                            Text(emoji(for: moment.mood))
                                .font(.system(size: 80))
                            Text(moment.mood)
                                .font(.title2.bold())
                                .foregroundStyle(.pink)
                        }
                    }
                    .frame(height: 250)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(moment.date.formatted(date: .long, time: .omitted))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text(moment.title)
                        .font(.largeTitle.bold())
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(nil)
                }
                .padding(.horizontal, 4)
                
                if !moment.notes.isEmpty {
                    Text(moment.notes)
                        .font(.body)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(nil)
                        .padding(.horizontal, 4)
                }
                
                if let lat = moment.latitude, let lon = moment.longitude {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Location", systemImage: "mappin.circle.fill")
                            .font(.headline)
                        
                        Map(initialPosition: .region(MKCoordinateRegion(
                            center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        ))) {
                            Marker(moment.title, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
                        }
                        .frame(height: 150)
                        .cornerRadius(16)
                        .allowsHitTesting(false)
                    }
                    .padding(.top, 10)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            .padding(.bottom, 40) // Add bottom padding for safe area
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 20)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    withAnimation {
                        moment.isFavorite.toggle()
                        try? modelContext.save()
                    }
                } label: {
                    Image(systemName: moment.isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(moment.isFavorite ? .pink : .primary)
                }
                
                Button {
                    let renderer = ShareImageRenderer(securityManager: securityManager)
                    shareImage = renderer.render(moment: moment)
                    isSharing = shareImage != nil
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                
                Button("Edit") {
                    isEditing = true
                }
            }
        }
        .sheet(isPresented: $isSharing) {
            if let img = shareImage { ShareSheet(items: [img]) }
        }
        .sheet(isPresented: $isEditing) {
            EditMomentView(moment: moment)
        }
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

#Preview {
    let m = Moment(title: "Sample", notes: "Notes", mood: "happy")
    NavigationStack {
        MomentDetailView(moment: m, securityManager: SecurityManager())
    }
}
